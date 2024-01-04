#!/bin/sh

Xvfb :1.0 -screen 0 1920x1080x24 &
fly-wm --display :1.0 &
x11vnc -display :1 -forever -passwd ${X11VNC_PASSWORD:-password} 