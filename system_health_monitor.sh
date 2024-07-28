#!/bin/bash

# Log file location
LOG_FILE="/var/opt/system_health.log"

# Thresholds
CPU_USAGE_THRESHOLD=80
MEMORY_USAGE_THRESHOLD=80
DISK_USAGE_THRESHOLD=80
PROCESS_COUNT_THRESHOLD=200

# Function to check CPU usage
check_cpu_usage() {
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/., *\([0-9.]\)%* id.*/\1/" | awk '{print 100 - $1}')
    if (( $(echo "$cpu_usage > $CPU_USAGE_THRESHOLD" | bc -l) )); then
        alert_message="High CPU usage detected: ${cpu_usage}%"
        echo "$alert_message"
        echo "$(date) - WARNING - $alert_message" >> "$LOG_FILE"
    fi
}

# Function to check memory usage
check_memory_usage() {
    local memory_usage
    memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    if (( $(echo "$memory_usage > $MEMORY_USAGE_THRESHOLD" | bc -l) )); then
        alert_message="High memory usage detected: ${memory_usage}%"
        echo "$alert_message"
        echo "$(date) - WARNING - $alert_message" >> "$LOG_FILE"
    fi
}

# Function to check disk usage
check_disk_usage() {
    local disk_usage
    disk_usage=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
    if (( disk_usage > DISK_USAGE_THRESHOLD )); then
        alert_message="High disk usage detected: ${disk_usage}%"
        echo "$alert_message"
        echo "$(date) - WARNING - $alert_message" >> "$LOG_FILE"
    fi
}

# Function to check process count
check_process_count() {
    local process_count
    process_count=$(ps aux | wc -l)
    if (( process_count > PROCESS_COUNT_THRESHOLD )); then
        alert_message="High number of processes detected: ${process_count}"
        echo "$alert_message"
        echo "$(date) - WARNING - $alert_message" >> "$LOG_FILE"
    fi
}

# Main monitoring loop
while true; do
    check_cpu_usage
    check_memory_usage
    check_disk_usage
    check_process_count
    sleep 60  # Check every minute
done