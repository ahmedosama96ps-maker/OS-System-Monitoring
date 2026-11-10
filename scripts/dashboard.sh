#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
REPORT_DIR="$PROJECT_ROOT/reports"
LOG_FILE="$PROJECT_ROOT/logs/monitor.log"
MONITOR_SCRIPT="$SCRIPT_DIR/monitor.sh"

while true; do
    CHOICE=$(whiptail --title "OS Project Monitoring Dashboard" --menu "Choose an option:" 15 60 6 \
    "1" "Run System Monitoring" \
    "2" "View Latest Markdown Report" \
    "3" "View Log File" \
    "4" "Open Reports Folder in Windows" \
    "5" "Show Project Files" \
    "6" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1)
            bash "$MONITOR_SCRIPT"
            read -p "Press Enter to continue..."
            ;;
        2)
            LATEST_REPORT=$(ls -t "$REPORT_DIR"/*.md 2>/dev/null | head -1)
            if [ -n "$LATEST_REPORT" ]; then
                less "$LATEST_REPORT"
            else
                whiptail --msgbox "No Markdown reports found. Run monitoring first." 10 50
            fi
            ;;
        3)
            if [ -f "$LOG_FILE" ]; then
                less "$LOG_FILE"
            else
                whiptail --msgbox "No log file found. Run monitoring first." 10 50
            fi
            ;;
        4)
            if command -v explorer.exe > /dev/null 2>&1; then
                explorer.exe "$(wslpath -w "$REPORT_DIR")"
            else
                whiptail --msgbox "Explorer is only available in WSL on Windows." 10 50
            fi
            ;;
        5)
            clear
            find "$PROJECT_ROOT" -maxdepth 2 -type f
            read -p "Press Enter to continue..."
            ;;
        6)
            clear
            echo "Exiting dashboard..."
            exit 0
            ;;
        *)
            exit 1
            ;;
    esac
done
