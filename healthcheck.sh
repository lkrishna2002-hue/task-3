nano healthcheck.sh
#!/bin/bash
#
# healthcheck.sh - collect basic system health info and append to healthlog.txt
#

LOG_FILE="healthlog.txt"
TIMESTAMP="$(date +"%Y-%m-%d %H:%M:%S")"

# Header for the report
printf "%s\n" "==========================================" >> "$LOG_FILE"
printf "Health Check Report - %s\n" "$TIMESTAMP" >> "$LOG_FILE"
printf "%s\n\n" "==========================================" >> "$LOG_FILE"

# 1) System date and time
printf "System Date and Time:\n" >> "$LOG_FILE"
date >> "$LOG_FILE"
printf "\n" >> "$LOG_FILE"

# 2) Uptime
printf "Uptime:\n" >> "$LOG_FILE"
# -p gives pretty uptime if available, fallback to uptime
if uptime -p >/dev/null 2>&1; then
  uptime -p >> "$LOG_FILE"
else
  uptime >> "$LOG_FILE"
fi
printf "\n" >> "$LOG_FILE"

# 3) CPU load
printf "CPU Load (from uptime):\n" >> "$LOG_FILE"
uptime >> "$LOG_FILE"
printf "\n" >> "$LOG_FILE"

# 4) Memory usage
printf "Memory Usage (free -m):\n" >> "$LOG_FILE"
free -m >> "$LOG_FILE"
printf "\n" >> "$LOG_FILE"

# 5) Disk usage
printf "Disk Usage (df -h):\n" >> "$LOG_FILE"
df -h >> "$LOG_FILE"
printf "\n" >> "$LOG_FILE"

# 6) Top 5 memory-consuming processes (header + 5 processes => head -n 6)
printf "Top 5 Memory-Consuming Processes (ps aux --sort=-%%mem | head -n 6):\n" >> "$LOG_FILE"
ps aux --sort=-%mem | head -n 6 >> "$LOG_FILE"
printf "\n" >> "$LOG_FILE"

# 7) Check services (nginx and ssh) — try systemctl, fallback to pgrep/service
printf "Service Status:\n" >> "$LOG_FILE"

check_service() {
  svc="$1"
  if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet "$svc"; then
      printf "%s is running\n" "$svc" >> "$LOG_FILE"
    else
      printf "%s is NOT running\n" "$svc" >> "$LOG_FILE"
    fi
  else
    # fallback: check with pgrep then 'service' command
    if pgrep -x "$svc" >/dev/null 2>&1; then
      printf "%s is running (found by pgrep)\n" "$svc" >> "$LOG_FILE"
    else
      if command -v service >/dev/null 2>&1; then
        if service "$svc" status >/dev/null 2>&1; then
          printf "%s is running (service status)\n" "$svc" >> "$LOG_FILE"
        else
          printf "%s is NOT running\n" "$svc" >> "$LOG_FILE"
        fi
      else
        printf "%s status unknown (no systemctl/service/pgrep available)\n" "$svc" >> "$LOG_FILE"
      fi
    fi
  fi
}

# Add or remove service names as needed
for S in nginx ssh; do
  check_service "$S"
done

printf "\nReport generated at %s\n" "$TIMESTAMP" >> "$LOG_FILE"
printf "%s\n\n" "------------------------------------------" >> "$LOG_FILE"

# Optional: brief console confirmation
echo "Health check complete. Appended report to $LOG_FILE"
