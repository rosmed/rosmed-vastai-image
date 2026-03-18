ARG VAST_BASE=vastai/linux-desktop:cuda-13.1-ubuntu24.04-2026-02-05

FROM ${VAST_BASE}

ARG UBUNTU_VERSION=24.04

################################################################################
# Install ROS2 Jazzy Jalisco
# See https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
################################################################################

WORKDIR /home/user
#
# Set locale
#
RUN apt update && apt install -y locales \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && export LANG=en_US.UTF-8

#
# Enable required repositories
#
RUN apt install -y software-properties-common \
    && add-apt-repository universe \
    && apt update && apt install curl -y \
    && export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}') \
    && curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" \
    && dpkg -i /tmp/ros2-apt-source.deb

#
# Install development tools
#
RUN apt update && apt install -y ros-dev-tools

#
# Install ROS
#
RUN apt update \
    && apt install -y ros-dev-tools \
    && apt upgrade -y \
    && apt install -y ros-jazzy-desktop \
    && apt install -y ros-jazzy-ros-base


################################################################################
# Libraries for ISMR 2021 Tutorial
################################################################################

WORKDIR /home/user
RUN mkdir igtl \
    && cd igtl \
    && git clone https://github.com/openigtlink/OpenIGTLink \
    && mkdir OpenIGTLink-build \
    && cd OpenIGTLink-build \
    && cmake -DBUILD_SHARED_LIBS:BOOL=OFF -DBUILD_EXAMPLES:BOOL=ON ../OpenIGTLink \
    && make

#
# Prerequisite for 3D Slicer
#
RUN apt update \
    && apt install -y git subversion build-essential cmake-curses-gui cmake-qt-gui \
    && apt install -y qtmultimedia5-dev qttools5-dev libqt5xmlpatterns5-dev libqt5svg5-dev qtwebengine5-dev qtscript5-dev \
    && apt install -y qtbase5-private-dev libqt5x11extras5-dev \
    && apt install -y libxt-dev libssl-dev


################################################################################
# 3D Slicer for ISMR 2021 Tutorial
################################################################################

WORKDIR /home/user

#
# Build 3D Slicer
#
RUN mkdir /home/user/slicer \
    && cd /home/user/slicer \
    && git clone --branch v5.8.1 https://github.com/slicer/Slicer \
    && mkdir Slicer-SuperBuild-Release \
    && cd Slicer-SuperBuild-Release \
    && cmake -DCMAKE_BUILD_TYPE:STRING=Release -DSlicer_USE_SYSTEM_OpenSSL=ON ../Slicer \
    && make -j4


################################################################################
# Slicer Extensions for ISMR2025
################################################################################

WORKDIR /home/user

#
# SlicerOpenIGTLink
#
RUN mkdir -p /home/user/slicer/modules \
    && cd /home/user/slicer/modules \
    && git clone https://github.com/openigtlink/SlicerOpenIGTLink \
    && mkdir SlicerOpenIGTLink-build \
    && cd SlicerOpenIGTLink-build \
    && cmake -DCMAKE_BUILD_TYPE:STRING=Release -DSlicer_DIR:PATH=/home/user/slicer/Slicer-SuperBuild-Release/Slicer-build ../SlicerOpenIGTLink \
    && make -j4

#
# SlicerIGSIO
#

# NOTE: GPU volume reconstruction is turned off temporarily because CL/cl.hpp is not available anymore on Ubuntu 24.04

#RUN apt update \
#    && apt install -y opencl-clhpp-headers \
#    && apt install -y opencl-headers \
#    && apt install -y ocl-icd-libopencl1 \
#    && apt install -y ocl-icd-opencl-dev
#RUN apt update && apt install -y nvidia-opencl-dev

RUN mkdir -p /home/user/slicer/modules \
    && cd /home/user/slicer/modules \
    && git clone https://github.com/IGSIO/SlicerIGSIO\
    && mkdir SlicerIGSIO-build \
    && cd SlicerIGSIO-build \
    && cmake -DCMAKE_BUILD_TYPE:STRING=Release -DSlicer_DIR:PATH=/home/user/slicer/Slicer-SuperBuild-Release/Slicer-build -DIGSIO_USE_GPU_RECONSTRUCT=OFF ../SlicerIGSIO \
    && make -j4

#
# SlicerIGT
#
RUN mkdir -p /home/user/slicer/modules \
    && cd /home/user/slicer/modules \
    && git clone https://github.com/SlicerIGT/SlicerIGT\
    && mkdir SlicerIGT-build \
    && cd SlicerIGT-build \
    && cmake -DCMAKE_BUILD_TYPE:STRING=Release -DSlicer_DIR:PATH=/home/user/slicer/Slicer-SuperBuild-Release/Slicer-build -DSlicerIGSIO_DIR:PATH=/home/user/slicer/modules/SlicerIGSIO-build/inner-build ../SlicerIGT \
    && make -j4

#
# SlicerDevelopmentToolbox
#
RUN mkdir -p /home/user/slicer/modules \
    && cd /home/user/slicer/modules \
    && git clone https://github.com/QIICR/SlicerDevelopmentToolbox \
    && mkdir SlicerDevelopmentToolbox-build \
    && cd SlicerDevelopmentToolbox-build \
    && cmake -DCMAKE_BUILD_TYPE:STRING=Release -DSlicer_DIR:PATH=/home/user/slicer/Slicer-SuperBuild-Release/Slicer-build ../SlicerDevelopmentToolbox \
    && make -j4


################################################################################
# Build packages
################################################################################

#
# Slicer Package
#
RUN cd /home/user/slicer/Slicer-SuperBuild-Release/Slicer-build \
    && make package \
    && mkdir -p /home/user/slicer/packages \
    && mv _CPack_Packages/linux-amd64/TGZ/Slicer*.tar.gz /home/user/slicer/packages

#
# SlicerOpenIGTLink
#
RUN cd /home/user/slicer/modules \
    && cd SlicerOpenIGTLink-build \
    && cd inner-build \
    && make package \
    && mkdir -p /home/user/slicer/packages \
    && mv *.tar.gz /home/user/slicer/packages

#
# SlicerIGSIO
#
RUN cd /home/user/slicer/modules \
    && cd SlicerIGSIO-build \
    && cd inner-build \
    && make package \
    && mkdir -p /home/user/slicer/packages \
    && mv *.tar.gz /home/user/slicer/packages


#
# SlicerIGT
#
RUN cd /home/user/slicer/modules \
    && cd SlicerIGT-build \
    && make package \
    && mkdir -p /home/user/slicer/packages \
    && mv *.tar.gz /home/user/slicer/packages

#
# SlicerDevelopmentToolbox
#
RUN cd /home/user/slicer/modules \
    && cd SlicerDevelopmentToolbox-build \
    && make package \
    && mkdir -p /home/user/slicer/packages \
    && mv *.tar.gz /home/user/slicer/packages


#
# Additional ROS2 packages
#

RUN apt update \
    && apt-get install -y python3-vcstool python3-colcon-common-extensions \
    && apt-get install -y python3-pykdl \
    && apt-get install -y libxml2-dev libraw1394-dev libncurses5-dev qtcreator \
    && apt-get install -y swig sox espeak cmake-curses-gui cmake-qt-gui git \
    && apt-get install -y subversion gfortran libcppunit-dev libqt5xmlpatterns5-dev libbluetooth-dev \
    && apt-get install -y ros-jazzy-joint-state-publisher* ros-jazzy-xacro \
    && apt-get install -y ros-jazzy-object-recognition-msgs ros-jazzy-moveit

RUN apt update \
    && apt-get install -y libxcursor-dev \
    && apt-get install -y libxinerama-dev \
    && apt-get install -y libasound2-dev libgl1-mesa-dev xorg-dev \
    && apt-get install -y libusb-1.0.0-dev

## Following will address an issue related to deprecated pkg_resources
#RUN apt install -y python3-pip \
#    && pip install --upgrade --break-system-packages setuptools==66.1.1
#
#WORKDIR /home/user
#RUN mkdir -p /home/user/ros2_ws/src \
#    && cd /home/user/ros2_ws/src \
#    && /bin/bash -c 'source /opt/ros/jazzy/setup.sh; vcs import --input https://raw.githubusercontent.com/jhu-dvrk/dvrk_robot_ros2/main/dvrk.vcs --recursive'

#
# Build SlicerROS2
#
WORKDIR /home/user
RUN mkdir -p /home/user/ros2_ws/src \
    && mkdir -p /home/user/ros2_ws/src \
    && cd /home/user/ros2_ws/src \
    #&& git clone https://github.com/jhu-cisst/ros2_cisst_msgs.git cisst_msgs \ # Installed as part of dVRK/ciasst
    && git clone https://github.com/jhu-saw/ros2_sensable_omni_model \
    && git clone https://github.com/rosmed/slicer_ros2_module \
    && cd /home/user/ros2_ws \
    && /bin/bash -c 'source /opt/ros/jazzy/setup.sh; colcon build --cmake-args -DSlicer_DIR:PATH=/home/user/slicer/Slicer-SuperBuild-Release/Slicer-build -DCMAKE_BUILD_TYPE=Release'

#
# Package SlicerROS2
#
WORKDIR /home/user
RUN mkdir -p /home/user/slicer/ \
    && mkdir -p /home/user/slicer/packages \
    && cd /home/user//slicer/packages \
    && /bin/bash -c 'source /opt/ros/jazzy/setup.sh; python /home/user/ros2_ws/src/slicer_ros2_module/do-release.py -b /home/user/slicer/Slicer-SuperBuild-Release/Slicer-build -v 1.0'


##
## Install 3D Slicer Extensions
##
WORKDIR /home/user
COPY slicer/install-extension.py /home/user/slicer
COPY slicer/install-module.py /home/user/slicer
COPY slicer/start-slicer-ros2.bash /home/user
RUN mkdir -p /home/user/slicer/packages
COPY packages/* /home/user/slicer/packages

WORKDIR /home/user
RUN cd /home/user \
    && chmod 755 start-slicer-ros2.bash

RUN /bin/bash -c "export EXTENSION_DIR=/home/user/slicer/packages; xvfb-run --auto-servernum /home/user/slicer/Slicer-SuperBuild-Release/Slicer-build/Slicer --no-main-window --no-splash --python-script /home/user/slicer/install-extension.py" \
