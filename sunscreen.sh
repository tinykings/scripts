#!/bin/bash
# Switch to sunshine virtual monitor when connecting Moonlight

case "$1" in
  on|ON)
    echo "🟢 Sunshine virtual monitor on"
    hyprctl keyword monitor sunshine,1920x1200@60,auto,1.2
    hyprctl keyword monitor HDMI-A-1,disable
    ;;

  off|OFF)
    echo "🔴 Sunshine virtual monitor off"
    hyprctl keyword monitor HDMI-A-1,1920x1200@60,auto,1.2
    hyprctl keyword monitor sunshine,disable
    hyprctl reload
    sleep 5
    # fix lockscreen crash
    hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'
    hyprctl --instance 0 'dispatch exec hyprlock'
    sleep 5
    # sleep on moonlight end.
    systemctl suspend
    ;;

  *)
    echo "Usage: $0 {on|off}"
    exit 1
    ;;
esac

