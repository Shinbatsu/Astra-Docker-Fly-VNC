# Includes SMD directory for current user

CONFIG_FILE="$HOME/.config/rusbitech/fly-fm-vfs.conf"
if [ -f "$CONFIG_FILE" ] ; then

IP="192.168.20.18"

STRING1="[Network Place 1003]"
STRING2="Name=upl18"
STRING3="Url=smb://$IP/upload"
STRING6="Url=smb://127.0.0.1/builds/"

if ! grep -q "$IP" "$CONFIG_FILE"; then
{
echo ""
echo "$STRING1:$STRING2:$STRING3"
} >> "$CONFIG_FILE"
fi

