1. Create a Table for Storing Login Logs
Create a table to store user login details:
[
CREATE TABLE user_login_log (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
]
2. Custom Function for Logging User Logins
Create a function to insert login records into the user_login_log table:
[
CREATE OR REPLACE FUNCTION log_user_login()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    IF current_user NOT IN ('postgres') THEN
        INSERT INTO user_login_log (username, login_time)
        VALUES (current_user, current_timestamp);
    END IF;
END;
$$;
]
This function excludes the postgres user but can be customized to fit your needs.

3. Manually Trigger the Logging
PostgreSQL does not have a built-in "login event" trigger, so you need to call this function manually in your application's connection logic. For example, in your application, execute:
[
SELECT log_user_login();
]
This ensures the logging function is invoked when a user logs in.
