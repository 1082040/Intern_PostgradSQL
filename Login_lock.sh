#!/bin/bash

# Constants
PGPASSWORD="123!@#"
DATABASE="postgres"
MAX_FAILED_ATTEMPTS=3
DB_HOST="xxx.xxx.xxx.xxx"
DB_PORT="xxxx"
DB_USER="postgres"

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Function: Execute SQL safely
execute_sql() {
    local sql="$1"
    PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DATABASE -tAc "$sql" 2>/dev/null || handle_error "Failed to execute: $sql"
}

# Function: Update user's failed login attempts
update_failed_attempts() {
    local user="$1"
    local count="$2"
    execute_sql "UPDATE locktable SET failedattempts = $count WHERE username = '$user';"
}

# Function: Record lock or login time
record_time() {
    local user="$1"
    local column="$2"
    local log_condition="$3"

    # Fetch log time
    local log_time
    log_time=$(execute_sql "SELECT log_time FROM postgres_log WHERE username = '$user' $log_condition ORDER BY log_time DESC LIMIT 1;")
    
    if [ -n "$log_time" ]; then
        local epoch_time
        epoch_time=$(date -d "$log_time" +%s)
        execute_sql "UPDATE locktable SET $column = '$epoch_time' WHERE username = '$user';"
    fi
}

# Function: Process users with failed login attempts
process_failed_attempts() {
    local users
    users=$(execute_sql "SELECT DISTINCT username FROM postgres_log WHERE command_tag = 'authentication' AND error_severity = 'FATAL' AND username LIKE 'iti%';")

    for user in $users; do
        local user_exists
        user_exists=$(execute_sql "SELECT 1 FROM locktable WHERE username = '$user';")

        if [ "$user_exists" == "1" ]; then
            local last_time
            last_time=$(execute_sql "SELECT lastlocktime FROM locktable WHERE username = '$user';")

            if [ -n "$last_time" ]; then
                local failed_attempts
                failed_attempts=$(execute_sql "SELECT COUNT(*) FROM postgres_log WHERE log_time > TO_TIMESTAMP($last_time) AND username = '$user' AND command_tag = 'authentication' AND error_severity = 'FATAL';")
                
                if [ "$failed_attempts" -ge $MAX_FAILED_ATTEMPTS ]; then
                    execute_sql "ALTER USER $user NOLOGIN;"
                    update_failed_attempts "$user" 0
                    record_time "$user" "lastlocktime" "AND command_tag = 'authentication' AND error_severity = 'FATAL'"
                else
                    update_failed_attempts "$user" "$failed_attempts"
                fi
            fi
        else
            execute_sql "INSERT INTO locktable (username, lastlocktime, failedattempts) VALUES ('$user', NULL, 1);"
        fi
    done
}

# Function: Process successful logins
process_successful_logins() {
    local users
    users=$(execute_sql "SELECT DISTINCT username FROM postgres_log WHERE command_tag = 'authentication' AND error_severity = 'LOG' AND username LIKE 'iti%' AND message LIKE '%connection authorized%';")

    for user in $users; do
        update_failed_attempts "$user" 0
        record_time "$user" "lastlogintime" "AND command_tag = 'authentication' AND error_severity = 'LOG' AND message LIKE '%connection authorized%'"
    done
}

# Main Script Execution
process_failed_attempts
process_successful_logins
