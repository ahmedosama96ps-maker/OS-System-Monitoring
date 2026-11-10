#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
REPORT_DIR="$PROJECT_ROOT/reports"
LOG_DIR="$PROJECT_ROOT/logs"
ALERT_DIR="$PROJECT_ROOT/alerts"

DATE=$(date +"%Y-%m-%d_%H-%M-%S")

REPORT_FILE="$REPORT_DIR/system_report_$DATE.md"
HTML_FILE="$REPORT_DIR/system_report_$DATE.html"
LOG_FILE="$LOG_DIR/monitor.log"
ALERT_FILE="$ALERT_DIR/alerts_$DATE.log"

CPU_LIMIT=80
MEMORY_LIMIT=80
DISK_LIMIT=80

mkdir -p "$REPORT_DIR" "$LOG_DIR" "$ALERT_DIR"

log_message() {
    echo "[$(date)] $1" >> "$LOG_FILE"
}

alert_message() {
    echo "[$(date)] ALERT: $1" >> "$ALERT_FILE"
    echo "[$(date)] ALERT: $1" >> "$LOG_FILE"
}

check_command() {
    if ! command -v "$1" > /dev/null 2>&1; then
        log_message "Error: Required command '$1' is not installed."
        echo "Error: Required command '$1' is not installed."
        exit 1
    fi
}

check_command top
check_command free
check_command df
check_command ip
check_command uptime
check_command ps
check_command awk

log_message "Monitoring script started."\n

# Take two top samples so the second reflects an actual interval.
# Unknown measurements are never silently reported as 0% utilization.
CPU_USAGE=$(LC_ALL=C top -bn2 -d 0.2 | awk '
/Cpu\\(s\\)/ {
    for (i = 1; i <= NF; i++) {
        if ($i ~ /^id,?$/ && i > 1) {
            idle = $(i-1)
            gsub(",", "", idle)
            if (idle ~ /^[0-9]+(\\.[0-9]+)?$/) usage = sprintf("%.1f", 100 - idle)
        }
    }
}
END { if (usage != "") print usage; else print "N/A" }
')

MEMORY_USAGE=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')

DISK_USAGE=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

if [ "$CPU_USAGE" != "N/A" ] && awk "BEGIN {exit !($CPU_USAGE > $CPU_LIMIT)}"; then
    alert_message "High CPU usage detected: ${CPU_USAGE}%"
fi

if [ "$MEMORY_USAGE" -gt "$MEMORY_LIMIT" ]; then
    alert_message "High memory usage detected: ${MEMORY_USAGE}%"
fi

if [ "$DISK_USAGE" -gt "$DISK_LIMIT" ]; then
    alert_message "High disk usage detected: ${DISK_USAGE}%"
fi

{
echo "# OS Project - System Monitoring Report"
echo ""
echo "**Generated at:** $(date)"
echo ""

echo "## 1. System Information"
echo '```'
hostnamectl 2>/dev/null || uname -a
echo '```'
echo ""

echo "## 2. CPU Usage"
echo '```'
top -bn1 | grep "Cpu" || echo "CPU information is not available."
echo ""
echo "Calculated CPU Usage: ${CPU_USAGE}%"
echo '```'
echo ""

echo "## 3. CPU Temperature"
echo '```'
if command -v sensors > /dev/null 2>&1; then
    sensors 2>/dev/null || echo "CPU temperature data is not available in this environment."
else
    echo "sensors command is not installed."
fi
echo '```'
echo ""

echo "## 4. GPU Utilization and Health"
echo '```'
if command -v nvidia-smi > /dev/null 2>&1; then
    nvidia-smi
elif command -v rocm-smi > /dev/null 2>&1; then
    rocm-smi
elif command -v lspci > /dev/null 2>&1; then
    echo "GPU monitoring tool is not available, but detected GPU/display hardware:"
    lspci | grep -i -E "vga|3d|display" || echo "No GPU/display hardware detected."
    echo ""
    echo "Full GPU utilization and health require GPU-specific tools such as nvidia-smi for NVIDIA GPUs or rocm-smi for AMD GPUs."
else
    echo "GPU monitoring tools are not available in this environment."
fi
echo '```'
echo ""

echo "## 5. Memory Usage"
echo '```'
free -h
echo ""
echo "Calculated Memory Usage: ${MEMORY_USAGE}%"
echo '```'
echo ""

echo "## 6. Disk Usage"
echo '```'
df -h
echo ""
echo "Root Disk Usage: ${DISK_USAGE}%"
echo '```'
echo ""

echo "## 7. Disk SMART Status"
echo '```'
if command -v smartctl > /dev/null 2>&1; then
    smartctl -H /dev/sda 2>/dev/null || echo "SMART status is not available in this environment."
else
    echo "smartctl command is not installed."
fi
echo '```'
echo ""

echo "## 8. Network Interfaces"
echo '```'
ip -s link
echo '```'
echo ""

echo "## 9. System Load"
echo '```'
uptime
echo '```'
echo ""

echo "## 10. Running Processes"
echo '```'
ps aux --sort=-%mem | head -10
echo '```'
echo ""

echo "## 11. Alerts"
echo '```'
if [ -s "$ALERT_FILE" ]; then
    cat "$ALERT_FILE"
else
    echo "No critical alerts detected."
fi
echo '```'
echo ""

} > "$REPORT_FILE"

if [ -f "$REPORT_FILE" ]; then
    log_message "Markdown report generated successfully: $REPORT_FILE"
    echo "Markdown report generated successfully:"
    echo "$REPORT_FILE"

    if command -v pandoc > /dev/null 2>&1; then
        pandoc "$REPORT_FILE" -o "$HTML_FILE"

        if [ -f "$HTML_FILE" ]; then
            log_message "HTML report generated successfully: $HTML_FILE"
            echo "HTML report generated successfully:"
            echo "$HTML_FILE"
        else
            log_message "Error: Failed to generate HTML report."
            echo "Error: Failed to generate HTML report."
        fi
    else
        log_message "Pandoc is not installed. HTML report was not generated."
        echo "Pandoc is not installed. HTML report was not generated."
    fi

    if [ -s "$ALERT_FILE" ]; then
        echo "Alerts were detected:"
        cat "$ALERT_FILE"
    else
        echo "No alerts detected."
        rm -f "$ALERT_FILE"
    fi
else
    log_message "Error: Failed to generate Markdown report."
    echo "Error: Failed to generate Markdown report."
    exit 1
fi
