#!/bin/bash
set -e

REGION="ap-northeast-1"
FUNCTION_NAME='darknet_imgdetect'

BUCKET_NAME='reinvent2020-project'
S3_KEY='darknet/dog.jpg'

# Get function configuration
aws lambda get-function-configuration \
	--function-name $FUNCTION_NAME \
	--region ${REGION} --output json

# invoke function 
start=$(date +%s%N)
aws lambda invoke \
	--function-name $FUNCTION_NAME \
	--region ${REGION} --log-type Tail outputfile.txt \
	--out text
end=$(date +%s%N)
runtime_ns=$((end-start))
runtime_ms=$((${runtime_ns}/1000000))
runtime_s=$(echo "scale=3;${runtime_ns}/1000000000" | bc)

echo Execution time was ${runtime_ns} nanoseconds.
echo Execution time was ${runtime_ms} milliseconds.
echo Execution time was ${runtime_s} seconds.

cat outputfile.txt | jq

echo "Done."
