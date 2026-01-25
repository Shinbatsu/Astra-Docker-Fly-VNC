#!/usr/bin/env bash
set -e

echo "Install some common tools for further installation"

apt-get update
apt-get install -y vim wget net-tools locales bzip2 procps apt-utils python3-numpy
apt-get clean -y

echo "generate locales für en_US.UTF-8"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen