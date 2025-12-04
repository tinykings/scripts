#!/bin/bash


hyprctl keyword monitor HDMI-A-1,1920x1200@60,auto,1.2
hyprctl keyword monitor sunshine,disable
hyprctl reload
sleep 5
hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'
hyprctl --instance 0 'dispatch exec hyprlock'
sleep 5
systemctl suspend
