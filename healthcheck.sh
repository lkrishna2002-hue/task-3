#!/bin/bash
# ------------------------------------------
# System Health Check Script
# File: healthcheck.sh
# ------------------------------------------

# Log file
LOG_FILE="healthlog.txt"

# Timestamp
echo "----------------------------------------" >> "$LOG_FILE"
echo "System Health Check - $(date)" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

# 1. System date and time
echo "🕒 Date & Time: $(date)" >> "$LOG_FILE"

# 2. System Uptime
echo -e "\n⏱️ Uptime:" >> "$LOG_FILE"
uptime >> "$LOG_FILE"

# 3. CPU Load
echo -e "\n💻 CPU Load (from uptime):" >> "$LOG_FILE"
uptime | awk -F'load average:' '{ print $2 }' >> "$LOG_FILE"

# 4. Memory Usage
echo -e "\n🧠 Memory Usage (MB):" >> "$LOG_FILE"
free -m >> "$LOG_FILE"

# 5. Disk Usage
echo -e "\n💾 Disk Usage:" >> "$LOG_FILE"
df -h >> "$LOG_FILE"

# 6. Top 5 Memory-Consuming Processes
echo -e "\n🔥 Top 5 Memory-Consuming Processes:" >> "$LOG_FILE"
ps aux --sort=-%mem | head -n 6 >> "$LOG_FILE"

# 7. Check Services
echo -e "\n🔍 Service Status:" >> "$LOG_FILE"
for service in ssh nginx
do
    if systemctl is-active --quiet $service
    then
        echo "$service is RUNNING ✅" >> "$LOG_FILE"
    else
        echo "$service is NOT RUNNING ❌" >> "$LOG_FILE"
    fi
done

echo -e "\n✅ Health check completed successfully!\n" >> "$LOG_FILE"
