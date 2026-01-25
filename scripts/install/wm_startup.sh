#!/bin/bash
### every exit != 0 fails the script
set -e

echo -e "\n------------------ startup of fly window manager ------------------"
echo "Using DISPLAY: $DISPLAY"

### disable screensaver and power management
xset -dpms
xset s noblank
xset s off

### start fly window manager
echo "Starting fly-wm..."
exec fly-wm --display $DISPLAY