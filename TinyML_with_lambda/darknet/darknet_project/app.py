import json
import logging
import boto3
import botocore
import os
import numpy
import darknet
import cv2


def lambda_handler(event, context):
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.info('event parameter: {}'.format(event))
    tmp_image='/tmp/image.jpg'
    result_image='result.jpg'
    
    s3 = boto3.resource('s3')
    BUCKET_NAME = os.environ.get("BUCKET_NAME")
    S3_KEY = os.environ.get("S3_KEY")

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

    # load darkent configuration
    network, class_names, class_colors = darknet.load_network(
            "cfg/yolov4-tiny.cfg",
            "cfg/coco.data",
            "weights/yolov4-tiny.weights",
            batch_size=1
    )

    # call image detaction
    image, detections = image_detection(
            tmp_image, network, class_names, class_colors, 0.1
            )

    results = output_detections(detections, True)
    cv2.imwrite('/tmp/result.jpg', image)
    s3 = boto3.client('s3')
    s3.upload_file('/tmp/result.jpg', BUCKET_NAME, result_image)
    return {
        "statusCode": 200,
        "body": {
            "message": "The results is {}".format(results),
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }


def image_detection(image_path, network, class_names, class_colors, thresh):
    width = darknet.network_width(network)
    height = darknet.network_height(network)
    darknet_image = darknet.make_image(width, height, 3)

    image = cv2.imread(image_path)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image_resized = cv2.resize(image_rgb, (width, height),
                               interpolation=cv2.INTER_LINEAR)

    darknet.copy_image_from_bytes(darknet_image, image_resized.tobytes())
    detections = darknet.detect_image(network, class_names, darknet_image, thresh=thresh)
    darknet.free_image(darknet_image)
    image = darknet.draw_boxes(detections, image_resized, class_colors)
    return cv2.cvtColor(image, cv2.COLOR_BGR2RGB), detections

def output_detections(detections, coordinates=False):
    message=[]
    for label, confidence, bbox in detections:
        x, y, w, h = bbox
        if coordinates:
            message.append("{}: {}%    (left_x: {:.0f}   top_y:  {:.0f}   width:   {:.0f}   height:  {:.0f})".format(label, confidence, x, y, w, h))
        else:
            message.append("{}: {}%".format(label, confidence))
    return message
