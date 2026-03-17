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
