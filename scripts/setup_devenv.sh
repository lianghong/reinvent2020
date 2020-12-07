#!/bin/bash
set -e

sudo yum -y update

#enable amazon-linux-extras
sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras enable python3.8

#python3.8
sudo yum install python3.8 -y
sudo yum install python38-devel python38-pip python38-wheel -y

# Development tools
sudo yum -y groupinstall "Development Tools"
sudo yum -y install openssl-devel bzip2-devel libffi-devel git wget cmake3

# enable EEPL
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo amazon-linux-extras enable epel

echo "Done."

