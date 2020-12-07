import json
import logging
import boto3
import botocore
import os

def lambda_handler(event, context):
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.info('event parameter: {}'.format(event))
    tmp_image='/tmp/image.jpg'
    result_image='result.jpg'

    s3 = boto3.resource('s3')
    BUCKET_NAME = os.environ.get("BUCKET_NAME")
    S3_KEY = os.environ.get("S3_KEY")
    
    try:
        s3.Bucket(BUCKET_NAME).download_file(S3_KEY, tmp_image)
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            print("The image file does not exist: s3://{}/{}".format(BUCKET_NAME, S3_KEY))
        else:
            raise
    
    import numpy
    import cv2

    # Load the cascade
    face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')

    # Read the input image
    img = cv2.imread(tmp_image)
    # Convert into grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Detect faces
    faces = face_cascade.detectMultiScale(gray, 1.1, 4)

    # Draw rectangle around the faces
    counter = 0
    for (x, y, w, h) in faces:
        cv2.rectangle(img, (x, y), (x+w, y+h), (255, 0, 0), 2)
        counter += 1
    cv2.imwrite('/tmp/result.jpg', img)

    s3 = boto3.client('s3')
    s3.upload_file('/tmp/result.jpg', BUCKET_NAME, result_image)

    return {
        "statusCode": 200,
        "body": {
            "message": "Find {} face(s),image saved to s3://{}/{}".format(counter, BUCKET_NAME, result_image),
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
