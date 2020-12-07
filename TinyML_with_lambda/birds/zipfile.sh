#!/bin/bash
set -e

ZIPFILE="birds_classification.zip"
PROJECTDIR="birds_project"

if [ ! -d "$PROJECTDIR/numpy" ]; then
	#pip3.8 install -q --target ./$PROJECTDIR Pillow -U
  	 pip3.8 install -q --target ./$PROJECTDIR $HOME/Downloads/Pillow_SIMD-7.0.0.post3-cp38-cp38-linux_x86_64.whl
fi

pushd $PROJECTDIR
find . -type d -name "tests" -exec rm -rf {} +
find . -type d -name "__pycache__" -exec rm -rf {} +
rm -rf ./{bin,pybind,caffe2,wheel,wheel-*,pkg_resources,boto*,aws*,pip,pip-*,pipenv,setuptools}
rm -rf ./{*.egg-info,*.dist-info}
find . -name \*.pyc -delete

zip -q -r9 ../$ZIPFILE .
popd

echo "Done."

