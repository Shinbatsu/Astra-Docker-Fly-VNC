#!/bin/bash

source $HOME/.bashrc

# add `--skip` to startup args, to skip the VNC startup procedure
if [[ $1 =~ -s|--skip ]]; then
    echo -e "\n\n------------------ SKIP VNC STARTUP -----------------"
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '${@:2}'"
    exec "${@:2}"
fi
if [[ $1 =~ -d|--debug ]]; then
    echo -e "\n\n------------------ DEBUG VNC STARTUP -----------------"
    export DEBUG=true
fi

## correct forwarding of shutdown signal
cleanup () {
    kill -s SIGTERM $!
    exit 0
}
trap cleanup SIGINT SIGTERM

$STARTUPDIR/chrome-init.sh
source $HOME/.chromium-browser.init

## resolve_vnc_connection
VNC_IP=$(hostname -i)

echo -e "\n------------------ VNC без пароля ------------------"
echo "Running x11vnc without password authentication"

echo -e "\n------------------ start Xvfb (virtual display) ------------------"

# Убиваем старые процессы Xvfb если есть
pkill -f "Xvfb.*$DISPLAY" 2>/dev/null || true

# Запускаем Xvfb
XVFB_CMD="Xvfb $DISPLAY -screen 0 ${VNC_RESOLUTION}x${VNC_COL_DEPTH} -ac +extension GLX +render -noreset"
if [[ $DEBUG == true ]]; then echo "Command: $XVFB_CMD"; fi
$XVFB_CMD > $STARTUPDIR/xvfb_startup.log 2>&1 &

# Ждем запуска Xvfb
echo "Waiting for Xvfb to start on display $DISPLAY..."
for i in {1..10}; do
    if xdpyinfo -display $DISPLAY >/dev/null 2>&1; then
        echo "Xvfb started successfully on display $DISPLAY"
        break
    fi
    sleep 1
    echo -n "."
done
echo ""

# Проверяем, запустился ли Xvfb
if ! xdpyinfo -display $DISPLAY >/dev/null 2>&1; then
    echo "ERROR: Xvfb failed to start on display $DISPLAY"
    echo "Xvfb startup log:"
    cat $STARTUPDIR/xvfb_startup.log
    exit 1
fi

# Экспортируем DISPLAY для всех последующих команд
export DISPLAY

## start window manager (fly-wm)
echo -e "\n------------------ start window manager ------------------"
if [[ $DEBUG == true ]]; then echo "Command: $HOME/wm_startup.sh"; fi
$INST_SCRIPTS/wm_startup.sh > $INST_SCRIPTS/wm_startup.log 2>&1 &

# Ждем запуска оконного менеджера
echo "Waiting for window manager to start..."
sleep 3

# Проверяем, запустился ли fly-wm
if ! ps aux | grep -q "[f]ly-wm.*$DISPLAY"; then
    echo "WARNING: fly-wm may have failed to start"
    echo "Window manager log:"
    tail -20 $STARTUPDIR/wm_startup.log
    echo "Trying to start xterm as fallback..."
    xterm -geometry 80x24+0+0 -e "echo 'Fallback terminal'" &
fi


echo -e "\n------------------ start x11vnc server ------------------"
X11VNC_CMD="x11vnc -display $DISPLAY -forever -shared -rfbport $VNC_PORT -nopw -noxdamage -xrandr"
if [[ $DEBUG == true ]]; then echo "Command: $X11VNC_CMD"; fi
$X11VNC_CMD > $STARTUPDIR/x11vnc_startup.log 2>&1 &

echo "Waiting for x11vnc to start on port $VNC_PORT..."
for i in {1..10}; do
    if netstat -tulpn 2>/dev/null | grep -q ":$VNC_PORT"; then
        echo "x11vnc started successfully on port $VNC_PORT"
        break
    fi
    sleep 1
    echo -n "."
done
echo ""

if ! netstat -tulpn 2>/dev/null | grep -q ":$VNC_PORT"; then
    echo "ERROR: x11vnc failed to start on port $VNC_PORT"
    echo "x11vnc startup log:"
    cat $STARTUPDIR/x11vnc_startup.log
    exit 1
fi

## start noVNC webclient
echo -e "\n------------------ start noVNC webclient ------------------"
if [[ $DEBUG == true ]]; then echo "Command: $NO_VNC_HOME/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT"; fi
$NO_VNC_HOME/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT > $STARTUPDIR/no_vnc_startup.log 2>&1 &
PID_SUB=$!

## log connect options
echo -e "\n\n------------------ VNC environment started ------------------"
echo -e "\nXvfb started on DISPLAY= $DISPLAY"
echo -e "\nx11vnc server started on port $VNC_PORT"
echo -e "\t=> connect via VNC viewer with $VNC_IP:$VNC_PORT"
echo -e "\nnoVNC HTML client started:"
echo -e "\t=> connect via http://$VNC_IP:$NO_VNC_PORT/vnc.html?password=$VNC_PW"
echo -e "\t=> or http://$VNC_IP:$NO_VNC_PORT/vnc_lite.html?password=$VNC_PW"
echo -e "\nTo connect from host machine:"
echo -e "\tVNC viewer: localhost:$VNC_PORT"
echo -e "\tWeb browser: http://localhost:$NO_VNC_PORT/vnc.html?password=$VNC_PW\n"

# Test with a simple window (опционально)
if [[ $DEBUG == true ]]; then
    echo "Opening test window..."
    xterm -geometry 80x24+100+100 -e "echo 'VNC test window'; sleep 5" &
fi

if [[ $DEBUG == true ]] || [[ $1 =~ -t|--tail-log ]]; then
    echo -e "\n------------------ startup logs ------------------"
    tail -f $STARTUPDIR/*.log
fi

if [ -z "$1" ] || [[ $1 =~ -w|--wait ]]; then
    echo -e "\nVNC environment is running. Press Ctrl+C to stop."
    wait $PID_SUB
else
    # unknown option ==> call command
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '$@'"
    exec "$@"
fi