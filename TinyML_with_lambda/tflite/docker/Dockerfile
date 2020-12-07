FROM amazonlinux

WORKDIR /tflite

RUN yum groupinstall -y development
RUN yum install -y amazon-linux-extras
RUN amazon-linux-extras enable python3.8
RUN yum -y install python3.8
RUN ln -s /usr/bin/python3.8 /usr/bin/python3

RUN yum install -y python38-wheel python38-setuptools python38-pip python38-devel
RUN python3.8 -m pip install numpy wheel pybind11

RUN git clone --branch master https://github.com/tensorflow/tensorflow.git
RUN sh ./tensorflow/tensorflow/lite/tools/make/download_dependencies.sh
RUN sh ./tensorflow/tensorflow/lite/tools/pip_package/build_pip_package.sh
RUN python3.8 -m pip install tensorflow/tensorflow/lite/tools/pip_package/gen/tflite_pip/python3/dist/tflite_runtime-2.4.0-cp38-cp38-linux_x86_64.whl

CMD tail -f /dev/null
