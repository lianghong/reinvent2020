#!/bin/bash
set -e

sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo systemctl enable docker
sudo groupadd docker
sudo usermod -a -G docker ec2-user
docker ps

echo "Done."




