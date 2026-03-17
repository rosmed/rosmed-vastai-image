ARG VAST_BASE=vastai/linux-desktop:cuda-13.1-ubuntu24.04-2026-02-05

FROM ${VAST_BASE}

ARG UBUNTU_VERSION=24.04

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
