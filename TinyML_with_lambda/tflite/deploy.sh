#!/bin/bash

# Create the Lambda function:
REGION="ap-northeast-1"
ACCOUNT_ID=$(aws sts get-caller-identity --output text | cut -f1)
ROLE="lambda_reinvent2020"

PYTHON="python3.8"
FUNCTION_NAME='tflite_classification'

BUCKET_NAME='reinvent2020-project'
S3_KEY='tflite/cat.jpg'
ZIPFILE='tflite_classification.zip'
MEMORY="3008"

if [ ! -f ${ZIPFILE} ]; then
	exho "${ZIPFILE} not exist."
	exit 1
fi

echo "Upload $ZIPFILE to s3://$BUCKET_NAME"
aws s3 cp "$ZIPFILE" s3://$BUCKET_NAME

aws lambda get-function --function-name ${FUNCTION_NAME} --region ${REGION} > /dev/null 2>&1
if [ 0 -eq $? ]; then
	echo "Lambda ${FUNCTION_NAME} exists"
	aws lambda delete-function --function-name ${FUNCTION_NAME} --region ${REGION}
fi

echo "Deploy fuction of ${FUNCTION_NAME}"
aws lambda create-function --function-name ${FUNCTION_NAME} --timeout 20 --memory-size ${MEMORY} --role arn:aws:iam::${ACCOUNT_ID}:role/${ROLE} --handler app.lambda_handler --region ${REGION} --runtime ${PYTHON} --environment "Variables={BUCKET_NAME=${BUCKET_NAME},S3_KEY=$S3_KEY}" --code S3Bucket="${BUCKET_NAME}",S3Key="${ZIPFILE}"

echo "Done."
