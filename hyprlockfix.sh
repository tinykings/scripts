#!/bin/bash
#hyprlock not work in omarchy after a monitor swap + sleep

# Run hyprlock
hyprlock

# After hyprlock exits (user unlocked)
# Kill any leftover hyprlock processes just in case
killall -q hyprlock

