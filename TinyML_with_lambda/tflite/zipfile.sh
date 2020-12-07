#!/bin/bash
set -e

ZIPFILE=tflite_classification.zip
PROJECTDIR=tflite_project

if [ ! -d "$PROJECTDIR/numpy" ]; then
        pip3.8 install --target ./$PROJECTDIR numpy -U
	pip3.8 install --target ./$PROJECTDIR Pillow -U
	pip3.8 install --target ./$PROJECTDIR $HOME/Downloads/tflite_runtime-2.4.0-cp38-cp38-linux_x86_64.whl
fi

pushd $PROJECTDIR
if [ -f $ZIPFILE ]; then
	/bin/rm -f $ZIPFILE
fi

if [ -d "__pycache__" ]; then
	/bin/rm -rf __pycache__
fi

zip -r9 $ZIPFILE .

if [ -f $ZIPFILE ]; then
	mv $ZIPFILE ..
fi
popd

echo "Done."

