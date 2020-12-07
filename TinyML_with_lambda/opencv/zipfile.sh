#!/bin/bash
set -e

ZIPFILE="opencv_facedetect.zip"
PROJECTDIR="opencv_project"

if [ ! -d "$PROJECTDIR/numpy" ]; then
	pip3.8 install --target ./$PROJECTDIR numpy
fi

pushd ${PROJECTDIR}
if [ -f ${ZIPFILE} ]; then
	/bin/rm -f ${ZIPFILE}
fi

if [ -d "__pycache__" ]; then
        /bin/rm -rf __pycache__
fi

zip -r9 ../$ZIPFILE .

popd

echo "Done."


