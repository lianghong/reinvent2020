import json
import logging
import boto3
import botocore
import os
import tflite_runtime.interpreter as tflite
import numpy as np
from PIL import Image


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

    # load the image
    image = Image.open(tmp_image)

    # load the labels
    with open('labels.txt', 'r') as f:
        labels = {i: line.strip() for i, line in enumerate(f.readlines())}

    # load the model
    interpreter = tflite.Interpreter(model_path='model.tflite')
    interpreter.allocate_tensors()

    # get model input details and resize image
    input_details = interpreter.get_input_details()
    iw = input_details[0]['shape'][2]
    ih = input_details[0]['shape'][1]
    image = image.resize((iw, ih)).convert(mode='RGB')

    # set model input and invoke
    input_data = np.array(image).reshape((ih, iw, 3))[None, :, :, :]
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()

    # read output and dequantize
    output_details = interpreter.get_output_details()[0]
    output = np.squeeze(interpreter.get_tensor(output_details['index']))
    if output_details['dtype'] == np.uint8:
        scale, zero_point = output_details['quantization']
        output = scale * (output - zero_point)

    # return the top label and its score
    ordered = np.argpartition(-output, 1)
    label_i = ordered[0]
    result = {'label': labels[label_i], 'score': output[label_i]}

    return {
        "statusCode": 200,
        "body": {
            "message": json.dumps(result)
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
