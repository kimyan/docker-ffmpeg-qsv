FROM ubuntu:20.04 AS ffmpeg-qsv-build

# tzdata taisaku
ENV DEBIAN_FRONTEND=noninteractive

# install build tools
RUN apt-get update
RUN apt-get -y install build-essential git cmake pkg-config

# for debug
RUN apt-get -y install vainfo

# intstall libva
RUN apt-get -y install meson libdrm-dev automake libtool && \
    git clone https://github.com/intel/libva.git && \
    cd libva && ./autogen.sh && \
    make && \
    make install && \
    sh -c "echo /usr/local/lib >> /etc/ld.so.conf.d/local.conf" && \
    ldconfig

# install Intel Graphics Memory Management Library
RUN apt-get -y install libpciaccess-dev && \
    cd && \
    git clone https://github.com/intel/gmmlib && \
    cd gmmlib/ && \
    mkdir build && cd build && \
    cmake .. && \
    make && \
    make install

# install VA-API
RUN cd && \
    git clone https://github.com/intel/media-driver && \
    mkdir build_media && \
    cd build_media/ && \
    cmake ../media-driver && \
    make && \
    make install

# install Intel Media SDK
RUN cd && \
    git clone https://github.com/Intel-Media-SDK/MediaSDK msdk && \
    cd msdk && \
    mkdir build && cd build && \
    cmake .. && \
    make && \
    make install && \
    sh -c "echo /opt/intel/mediasdk/lib/ >> /etc/ld.so.conf.d/mediasdk.conf" && \
    ldconfig

RUN cd && \
    apt-get -y install software-properties-common && \
    apt-get update -qq && apt-get -y install \
    autoconf \
    automake \
    build-essential \
    cmake \
    git-core \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libsdl2-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    pkg-config \
    texinfo \
    wget \
    yasm \
    zlib1g-dev \
    nasm \
    libx264-dev \
    libx265-dev libnuma-dev \
    libvpx-dev \
    libfdk-aac-dev \
    libmp3lame-dev \
    libopus-dev \
    libaom-dev && \
    export PKG_CONFIG_PATH=/opt/intel/mediasdk/lib/pkgconfig:$PKG_CONFIG_PATH && \
    wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
    tar xjvf ffmpeg-snapshot.tar.bz2 && \
    cd ffmpeg && \
    ./configure \
    --extra-libs="-lpthread -lm" \
    --enable-libmfx \
    --enable-gpl \
    --enable-gnutls \
    --enable-libaom \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree && \
    make && \
    make install
