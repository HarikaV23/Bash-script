#!/bin/bash

# Configuration
URL="http://172.31.21.217:4499"  # Replace with your application's URL
EXPECTED_STATUS_CODE=200  # Expected HTTP status code for 'up' status
LOG_FILE="/var/opt/application_status.log"  # Log file to record the results

# Function to check application status
check_status() {
    local status_code
    status_code=$(curl -o /dev/null -s -w "%{http_code}" "$URL")

    if [ "$status_code" -eq "$EXPECTED_STATUS_CODE" ]; then
        status="UP"
    else
        status="DOWN"
    fi

    # Log the result
    echo "$(date) - Application status: $status (HTTP Status Code: $status_code)" >> "$LOG_FILE"
    echo "Application status: $status (HTTP Status Code: $status_code)"
}

# Run the status check
check_status