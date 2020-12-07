#!/bin/bash
set -e

sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras enable python3.8
sudo yum -y install python3.8

sudo yum install -y python38-wheel python38-setuptools python38-pip python38-devel

python3.8 --version
echo "Done."


