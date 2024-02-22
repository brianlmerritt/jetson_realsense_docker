## Jetson Realsense Docker

From dustynv:jetson-containers

### Base Image

l4t-ros2:humble

From Atinfinity CUDA drivers with ROS Humble installed

### Build output Image

```
docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t l4t-ros2:humble-realsense .
```
## Launch docker container

```
xhost +
docker run -it --rm --net=host --runtime nvidia -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix l4t-ros2:humble-realsense /bin/bash
```