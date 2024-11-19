# Intern_PostgradSQL
---

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Setup Instructions](#setup-instructions)
- [Notes](#notes)

---
# PostgreSQL Login Management and Tracking

This project automates user login tracking, failed login attempt monitoring, and dynamic log data loading in PostgreSQL.

## Features
- Tracks user login events and logs them in a custom table.
- Monitors failed login attempts and locks users after three consecutive failures.
- Dynamically loads log data from daily CSV files.
- Provides optimized PostgreSQL configurations.

## Requirements
- PostgreSQL 12 or higher
- Access to PostgreSQL configuration files
- Bash (for utility scripts)

## Setup Instructions
### 1. Clone the Repository
```bash
git clone https://github.com/1082040/Intern_PostgradSQL.git
```

### 2. Navigate to the Project Directory
Change into the project directory
```bash
cd Intern_PostgradSQL
```

### 3. Review and Modify Configuration Files
- postgresql.conf: This file contains PostgreSQL configuration settings. Ensure that the parameters align with your system's requirements. For instance, adjust logging_collector to enable or disable logging.
- passwordcheck.c: This C file is designed to enforce password policies. Review the code to ensure it meets your organization's security standards.

### 4. Compile the Password Check Module
To enforce custom password policies, compile the passwordcheck.c file
```bash
gcc -fPIC -c passwordcheck.c
gcc -shared -o passwordcheck.so passwordcheck.o
```

### 5. Update PostgreSQL Configuration
Edit the postgresql.conf file to include the password check module
```bash
shared_preload_libraries = 'passwordcheck'
```

### 6. Set Up Login Tracking
The Login_lock.sh script is designed to monitor user login attempts and lock accounts after a specified number of failed attempts. Ensure this script has execute permissions
```bash
chmod +x Login_lock.sh
```
You can schedule this script to run at regular intervals using cron jobs or another scheduling tool to automate the monitoring process.

### 7. Restart PostgreSQL
After making the above changes, restart the PostgreSQL service to apply the new configurations
```bash
sudo systemctl restart postgresql
```
Replace systemctl with the appropriate command if you're using a different init system.

### 8. Verify the Setup
Test the setup by attempting to log in with valid and invalid credentials to ensure that
- Successful logins are tracked appropriately.
- Failed login attempts are monitored, and accounts are locked after the defined threshold.
- Password policies are enforced as specified.

## Notes
Always back up your current configurations before making changes. Ensure that you have the necessary permissions to modify PostgreSQL configurations and that these changes comply with your organization's security policies.
