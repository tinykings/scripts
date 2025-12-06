#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${SCRIPT_DIR}/.citrixalive.pid"
LOG_FILE="${SCRIPT_DIR}/citrixalive.log"
INTERVAL=200  # seconds
MOUSE_MOVE_DISTANCE=200

echo "Running..."

while true; do
        # Move mouse 1px right
        if ydotool mousemove --relative -- "$MOUSE_MOVE_DISTANCE" 0 2>/dev/null; then
            sleep 0.2
            # Move mouse 1px left (back to original position)
            ydotool mousemove --relative -- -$MOUSE_MOVE_DISTANCE 0 2>/dev/null
        fi
        
        # Sleep for the interval
        sleep "$INTERVAL"
    done
