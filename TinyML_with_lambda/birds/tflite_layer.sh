#!/bin/bash

REGION="ap-northeast-1"
ACCOUNT_ID=$(aws sts get-caller-identity --output text | cut -f1)
ROLE="lambda_reinvent2020"

BUCKET_NAME='reinvent2020-project'
PYTHON="python3.8"
LAYER_NAME="tflite"
ZIPFILE="tflite_layer.zip"
PROJECTDIR="layer/python"

if [ ! -d ${PROJECTDIR} ]; then
	mkdir -p ${PROJECTDIR}
else
	/bin/rm -rf ${PROJECTDIR}/*
fi

if [ ! -d "${PROJECTDIR}/numpy" ]; then
        pip3.8 install -q --target ./${PROJECTDIR} numpy -U
	#pip3.8 install -q --target ./${PROJECTDIR} ntel-numpy -U
        pip3.8 install -q --target ./${PROJECTDIR} $HOME/Downloads/tflite_runtime-2.4.0-cp38-cp38-linux_x86_64.whl
fi

pushd ${PROJECTDIR}
find . -type d -name "tests" -exec rm -rf {} +
find . -type d -name "__pycache__" -exec rm -rf {} +
rm -rf ./{bin,pybind*,caffe2,wheel,wheel-*,pkg_resources,boto*,aws*,pip,pip-*,pipenv,setuptools}
rm -rf ./{*.egg-info,*.dist-info}
find . -name \*.pyc -delete
popd

pushd layer
zip -q -r9 ../$ZIPFILE .
popd

echo "Upload ${ZIPFILE} to s3://${BUCKET_NAME}"
aws s3 cp ${ZIPFILE} s3://${BUCKET_NAME}

#result=$(aws lambda list-layers --output text --query 'Layers[0].{Name:LayerName,Ver:LatestMatchingVersion.Version}')

LAYER_VER=$(aws lambda list-layer-versions --layer-name ${LAYER_NAME} --query "LayerVersions[].Version" --region ${REGION})
echo "LAYER_VER is $LAYER_VER"

if [[ ! -z ${LAYER_VER} ]]; then
	echo "Lambda layer of ${LAYER_NAME} exist, version is ${LAYER_VER}."
	for v in ${LAYER_VER}; do
		aws lambda delete-layer-version \
			--layer-name ${LAYER_NAME}  \
			--version-number ${v} \
			--region ${REGION} \
			--output json
	done
fi

aws lambda publish-layer-version \
	--layer-name ${LAYER_NAME} \
	--description "Tensorflow Lite 2.4" \
	--content S3Bucket=${BUCKET_NAME},S3Key=${ZIPFILE} \
	--compatible-runtimes ${PYTHON} \
	--output json

#/bin/rm -rf ${PROJECTDIR}

echo "Done."
