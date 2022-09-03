
ARG BASE_IMAGE=nvcr.io/nvidia/deepstream:6.0.1-triton
FROM ${BASE_IMAGE}

ARG DSL_BRANCH=master
ARG ROOT_NAME=/opt/dsl

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

WORKDIR /tmp

RUN apt install wget -y
RUN apt-key del 7fa2af80

# fix for the key issue - lmm
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/7fa2af80.pub

RUN sed -i '/developer\.download\.nvidia\.com\/compute\/cuda\/repos/d' /etc/apt/sources.list.d/*
RUN sed -i '/developer\.download\.nvidia\.com\/compute\/machine-learning\/repos/d' /etc/apt/sources.list.d/*
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb
RUN dpkg -i cuda-keyring_1.0-1_all.deb

RUN	apt-get update && \
    apt-get install -y --no-install-recommends \
        libgeos-dev \
		libapr1-dev \
		libaprutil1-dev \
		software-properties-common

RUN add-apt-repository --yes ppa:deadsnakes/ppa
RUN apt-get update && \
	apt-get install -y python3.6 python3.6-distutils python3.6-dev

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
RUN	update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
RUN	update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
RUN	update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2

RUN python -m pip install --upgrade pip
RUN python3 -m pip install --upgrade pip 
 
RUN mkdir ${ROOT_NAME}
WORKDIR ${ROOT_NAME}

RUN git clone https://github.com/youngjae-avikus/deepstream-services-library.git
WORKDIR ${ROOT_NAME}/deepstream-services-library

RUN if [ "$DSL_BRANCH" != "master" ] ; then git checkout ${DSL_BRANCH} ; fi

RUN wget https://github.com/NVIDIA-AI-IOT/deepstream_python_apps/releases/download/v1.1.1/pyds-1.1.1-py3-none-linux_x86_64.whl
RUN make -j$(nproc)
RUN make install
RUN python -m pip install pyds-1.1.1-py3-none-linux_x86_64.whl
RUN python3 -m pip install pyds-1.1.1-py3-none-linux_x86_64.whl

WORKDIR /deepstream_python_apps
COPY . /deepstream_python_apps
ENTRYPOINT [ "/bin/bash" ]
#RUN python3 /deepstream_python_apps/test.py
