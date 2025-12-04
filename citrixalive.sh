#!/bin/bash

# Citrix Keep-Alive Script for Hyprland/Wayland
# Moves mouse every 5 minutes to prevent Citrix session timeout

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${SCRIPT_DIR}/.citrixalive.pid"
LOG_FILE="${SCRIPT_DIR}/citrixalive.log"
INTERVAL=300  # 5 minutes in seconds
MOUSE_MOVE_DISTANCE=1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    echo -e "${timestamp} [${level}] ${message}"
}

check_dependencies() {
    if ! command -v ydotool &> /dev/null; then
        echo -e "${RED}Error: ydotool is not installed.${NC}"
        echo "Install it with: sudo pacman -S ydotool"
        echo "Then enable the user service: systemctl --user enable --now ydotool"
        exit 1
    fi
    
    # Check if ydotool daemon is running
    if ! systemctl --user is-active --quiet ydotool 2>/dev/null; then
        echo -e "${YELLOW}Warning: ydotool service is not running.${NC}"
        echo "Starting ydotool service..."
        if systemctl --user start ydotool 2>/dev/null; then
            echo -e "${GREEN}ydotool service started successfully${NC}"
        else
            echo -e "${RED}Failed to start ydotool service.${NC}"
            echo "Try enabling it with: systemctl --user enable --now ydotool"
            exit 1
        fi
    fi
}

stop_script() {
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE")
        if ps -p "$old_pid" > /dev/null 2>&1; then
            kill "$old_pid" 2>/dev/null
            log "INFO" "Stopped existing instance (PID: $old_pid)"
        fi
        rm -f "$PID_FILE"
    fi
}

start_script() {
    # Check if already running
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE")
        if ps -p "$old_pid" > /dev/null 2>&1; then
            echo -e "${YELLOW}Script is already running (PID: $old_pid)${NC}"
            exit 1
        else
            rm -f "$PID_FILE"
        fi
    fi

    # Write PID file
    echo $$ > "$PID_FILE"
    
    # Trap signals for clean exit
    trap 'log "INFO" "Received stop signal, exiting..."; rm -f "$PID_FILE"; exit 0' SIGTERM SIGINT
    
    log "INFO" "Starting Citrix keep-alive script (PID: $$)"
    log "INFO" "Mouse will move every ${INTERVAL} seconds"
    
    while true; do
        # Move mouse 1px right
        if ydotool mousemove --relative -- "$MOUSE_MOVE_DISTANCE" 0 2>/dev/null; then
            sleep 0.2
            # Move mouse 1px left (back to original position)
            ydotool mousemove --relative -- -$MOUSE_MOVE_DISTANCE 0 2>/dev/null
            log "INFO" "Mouse moved to keep session alive"
        else
            log "ERROR" "Failed to move mouse. Is ydotool service running?"
            log "ERROR" "Try: systemctl --user status ydotool"
        fi
        
        # Sleep for the interval
        sleep "$INTERVAL"
    done
}

case "${1:-start}" in
    start)
        check_dependencies
        start_script
        ;;
    stop)
        stop_script
        echo -e "${GREEN}Citrix keep-alive stopped${NC}"
        ;;
    restart)
        stop_script
        sleep 1
        check_dependencies
        start_script
        ;;
    status)
        if [ -f "$PID_FILE" ]; then
            local pid=$(cat "$PID_FILE")
            if ps -p "$pid" > /dev/null 2>&1; then
                echo -e "${GREEN}Citrix keep-alive is running (PID: $pid)${NC}"
                exit 0
            else
                echo -e "${YELLOW}PID file exists but process is not running${NC}"
                rm -f "$PID_FILE"
                exit 1
            fi
        else
            echo -e "${RED}Citrix keep-alive is not running${NC}"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the keep-alive script"
        echo "  stop    - Stop the keep-alive script"
        echo "  restart - Restart the keep-alive script"
        echo "  status  - Check if the script is running"
        exit 1
        ;;
esac
