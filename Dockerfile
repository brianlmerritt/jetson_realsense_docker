#---
# name: realsense
# group: sensors
# depends: [python, cmake]
# from: dustynv/jetson-containers:base-l4t
# notes: https://github.com/IntelRealSense/librealsense/blob/master/doc/installation_jetson.md
#---
FROM l4t-ros2:humble
ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME jetson
ENV HOME /home/$USERNAME
USER $USERNAME
WORKDIR /home/$USERNAME
SHELL ["/bin/bash", "-l", "-c"]

RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
		  libssl-dev \
		  libusb-1.0-0-dev \
            libgtk-3-dev \
            libglfw3-dev \
		  libgl1-mesa-dev \
		  libglu1-mesa-dev \
		  qtcreator && \
    if [ $(lsb_release -cs) = "bionic" ]; then \
        sudo apt-get install -y --no-install-recommends python-dev; \
    else \
        sudo apt-get install -y --no-install-recommends python2-dev; \
    fi \
    && sudo rm -rf /var/lib/apt/lists/* \
    && sudo apt-get clean

# https://github.com/IntelRealSense/librealsense/issues/11931
ARG LIBREALSENSE_VERSION=master

RUN git clone --branch ${LIBREALSENSE_VERSION} --depth=1 https://github.com/IntelRealSense/librealsense && \
    cd librealsense && \
    mkdir build && \
    cd build && \
    cmake \
       -DBUILD_EXAMPLES=true \
	   -DFORCE_RSUSB_BACKEND=true \
	   -DBUILD_WITH_CUDA=true \
       -DCUDA_HOME=/usr/local/cuda \
       -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc \
	   -DCMAKE_BUILD_TYPE=release \
	   -DBUILD_PYTHON_BINDINGS=bool:true \
	   -DPYTHON_EXECUTABLE=/usr/bin/python3 \
	   -DPYTHON_INSTALL_DIR=$(python3 -c 'import sys; print(f"/usr/lib/python{sys.version_info.major}.{sys.version_info.minor}/dist-packages")') \
	   ../ -LAH && \
    make -j$(($(nproc)-1)) && \
    sudo make install && \
    cd ../ && \
    sudo cp ./config/99-realsense-libusb.rules /etc/udev/rules.d/ && \
    sudo rm -rf librealsense

# Test that the install worked
RUN python3 -c 'import pyrealsense2'

#RUN udevadm control --reload-rules && udevadm trigger
