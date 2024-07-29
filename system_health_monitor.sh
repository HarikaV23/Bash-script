#!/bin/bash

# Define thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
LOG_FILE="/var/log/system_health.log"

# Function to get current CPU usage
get_cpu_usage() {
  top -bn1 | grep "Cpu(s)" | \
  sed "s/., *\([0-9.]\)%* id.*/\1/" | \
  awk '{print 100 - $1}'
}

# Function to get current memory usage
get_memory_usage() {
  free | grep Mem | awk '{print $3/$2 * 100.0}'
}

# Function to get current disk usage
get_disk_usage() {
  df / | grep / | awk '{ print $5 }' | sed 's/%//g'
}

# Function to get number of running processes
get_running_processes() {
  ps aux | wc -l
}

# Function to log and alert
log_alert() {
  MESSAGE=$1
  echo "$MESSAGE" | tee -a $LOG_FILE
}

# Monitor system health
monitor_health() {
  CPU_USAGE=$(get_cpu_usage)
  MEMORY_USAGE=$(get_memory_usage)
  DISK_USAGE=$(get_disk_usage)
  RUNNING_PROCESSES=$(get_running_processes)

  if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    log_alert "ALERT: CPU usage is above threshold: $CPU_USAGE%"
  fi

  if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
    log_alert "ALERT: Memory usage is above threshold: $MEMORY_USAGE%"
  fi

  if (( $(echo "$DISK_USAGE > $DISK_THRESHOLD" | bc -l) )); then
    log_alert "ALERT: Disk usage is above threshold: $DISK_USAGE%"
  fi

  # You can define a threshold for running processes if needed
  # if (( RUNNING_PROCESSES > PROCESS_THRESHOLD )); then
  #   log_alert "ALERT: Number of running processes is above threshold: $RUNNING_PROCESSES"
  # fi
}

# Run the monitor function
monitor_health