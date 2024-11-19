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
