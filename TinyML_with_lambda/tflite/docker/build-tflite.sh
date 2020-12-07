#!/usr/bin/bash
set -e

docker build -t tflite_amazonlinux .
docker run -d --name=tflite_amazonlinux tflite_amazonlinux
docker cp tflite_amazonlinux:/usr/local/lib64/python3.8/site-packages ./python
cp -r ./python/site-packages/* ./python && rm -rf ./python/site-packages
docker stop tflite_amazonlinux

echo "Done."

