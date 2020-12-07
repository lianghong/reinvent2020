#!/bin/bash
set -e

if  [ -x "$(command -v aws)" ]; then
	sudo yum remove awscli -y
fi

if [ ! -d "$HOME/Downloads" ]; then
	mkdir -p $HOME/Downloads
fi
wget --quiet "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "$HOME/Downloads/awscliv2.zip"

cd $HOME/Downloads
unzip awscliv2.zip
sudo ./aws/install

echo "Done."


