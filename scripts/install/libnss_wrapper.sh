#!/usr/bin/env bash
set -e

echo "Install nss-wrapper to be able to execute image as non-root user"
apt-get update
apt-get install -y libnss-wrapper gettext
apt-get clean -y

echo "add 'source generate_container_user' to .bashrc"
echo 'source $STARTUPDIR/generate_container_user' >> $HOME/.bashrc