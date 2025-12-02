# NVIDIA/CUDA enabled FFmpeg Dockerfile
# Copyright (C) 2020-2025  Chelsea E. Manning
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# $ docker build --network=host -t xychelsea/ffmpeg-nvidia:latest -f Dockerfile .
# $ docker run --gpus all --rm -it xychelsea/ffmpeg-nvidia:latest /bin/bash
# $ docker push xychelsea/ffmpeg-nvidia:latest

# Stage 1: Builder - Compile FFmpeg from source
FROM nvidia/cuda:12.5.1-devel-ubuntu22.04 AS builder

ARG FFMPEG_VERSION="8.0"
ENV FFMPEG_VERSION="${FFMPEG_VERSION}"
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies in a single layer
RUN apt-get update --fix-missing && \
    apt-get -y install --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    cleancss \
    cmake \
    debhelper-compat \
    doxygen \
    flite1-dev \
    frei0r-plugins-dev \
    git \
    ladspa-sdk \
    libaom-dev \
    libaribb24-dev \
    libass-dev \
    libbluray-dev \
    libbs2b-dev \
    libbz2-dev \
    libcaca-dev \
    libcdio-paranoia-dev \
    libchromaprint-dev \
    libcodec2-dev \
    libdc1394-dev \
    libdrm-dev \
    libfdk-aac-dev \
    libffmpeg-nvenc-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libgl1-mesa-dev \
    libgme-dev \
    libgnutls28-dev \
    libgsm1-dev \
    libiec61883-dev \
    libavc1394-dev \
    libjack-jackd2-dev \
    liblensfun-dev \
    liblilv-dev \
    liblzma-dev \
    libmp3lame-dev \
    libmysofa-dev \
    libopenal-dev \
    libomxil-bellagio-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libopenjp2-7-dev \
    libopenmpt-dev \
    libopus-dev \
    libpulse-dev \
    librubberband-dev \
    librsvg2-dev \
    libsctp-dev \
    libsdl2-dev \
    libshine-dev \
    libsnappy-dev \
    libsoxr-dev \
    libspeex-dev \
    libssh-gcrypt-dev \
    libtesseract-dev \
    libtheora-dev \
    libtwolame-dev \
    libva-dev \
    libvdpau-dev \
    libvidstab-dev \
    libvo-amrwbenc-dev \
    libvorbis-dev \
    libvpx-dev \
    libwavpack-dev \
    libwebp-dev \
    libx264-dev \
    libx265-dev \
    libxcb-shape0-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    libxml2-dev \
    libxv-dev \
    libxvidcore-dev \
    libxvmc-dev \
    libzmq3-dev \
    libzvbi-dev \
    nasm \
    node-less \
    ocl-icd-opencl-dev \
    pkg-config \
    tar \
    texinfo \
    wget \
    yasm \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Download and extract FFmpeg source (try .tar.xz first, fallback to .tar.bz2)
RUN if wget -q --spider https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz 2>/dev/null; then \
    wget -q https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz && \
    tar -xJf ffmpeg-${FFMPEG_VERSION}.tar.xz && \
    rm ffmpeg-${FFMPEG_VERSION}.tar.xz; \
    else \
    wget -q https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 && \
    tar -xjf ffmpeg-${FFMPEG_VERSION}.tar.bz2 && \
    rm ffmpeg-${FFMPEG_VERSION}.tar.bz2; \
    fi

# Install nv-codec-headers (required for cuvid)
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /tmp/nv-codec-headers && \
    cd /tmp/nv-codec-headers && \
    make && \
    make install && \
    rm -rf /tmp/nv-codec-headers

WORKDIR /tmp/ffmpeg-${FFMPEG_VERSION}

# Configure and build FFmpeg
RUN ./configure \
    --prefix=/usr/local/ffmpeg-nvidia \
    --extra-cflags="-I/usr/local/cuda/include" \
    --extra-ldflags="-L/usr/local/cuda/lib64" \
    --toolchain=hardened \
    --enable-gpl \
    --disable-stripping \
    --disable-filter=resample \
    --enable-cuvid \
    --enable-gnutls \
    --enable-ladspa \
    --enable-libaom \
    --enable-libass \
    --enable-libbluray \
    --enable-libbs2b \
    --enable-libcaca \
    --enable-libcdio \
    --enable-libcodec2 \
    --enable-libfdk-aac \
    --enable-libflite \
    --enable-libfontconfig \
    --enable-libfreetype \
    --enable-libfribidi \
    --enable-libgme \
    --enable-libgsm \
    --enable-libjack \
    --enable-libmp3lame \
    --enable-libmysofa \
    --enable-libnpp \
    --enable-libopenjpeg \
    --enable-libopenmpt \
    --enable-libopus \
    --enable-libpulse \
    --enable-librsvg \
    --enable-librubberband \
    --enable-libshine \
    --enable-libsnappy \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libssh \
    --enable-libtheora \
    --enable-libtwolame \
    --enable-libvorbis \
    --enable-libvidstab \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxml2 \
    --enable-libxvid \
    --enable-libzmq \
    --enable-libzvbi \
    --enable-lv2 \
    --enable-nvenc \
    --enable-nonfree \
    --enable-omx \
    --enable-openal \
    --enable-opencl \
    --enable-opengl \
    --enable-sdl2 && \
    make -j$(nproc) && \
    make install

# Stage 2: Runtime - Minimal image with only FFmpeg binaries
FROM nvidia/cuda:12.5.1-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/ffmpeg-nvidia/bin:${PATH}"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,video,utility

# Create non-root user
RUN groupadd -r ffmpeg && \
    useradd -r -g ffmpeg -m -d /home/ffmpeg -s /bin/bash ffmpeg && \
    mkdir -p /home/ffmpeg/workspace && \
    chown -R ffmpeg:ffmpeg /home/ffmpeg

# Install only runtime dependencies (use package names without version numbers for apt to resolve)
RUN apt-get update --fix-missing && \
    apt-get -y install --no-install-recommends \
    ca-certificates \
    libaom3 \
    libaribb24-0 \
    libass9 \
    libbluray2 \
    libbs2b0 \
    libbz2-1.0 \
    libcaca0 \
    libcdio19 \
    libcdio-paranoia2 \
    libchromaprint1 \
    libcodec2-1.0 \
    libdc1394-25 \
    libdrm2 \
    libfdk-aac2 \
    libfontconfig1 \
    libfreetype6 \
    libfribidi0 \
    libflite1 \
    libgl1 \
    libgme0 \
    libgnutls30 \
    libgsm1 \
    libiec61883-0 \
    libavc1394-0 \
    libjack-jackd2-0 \
    liblensfun1 \
    liblilv-0-0 \
    liblzma5 \
    libmp3lame0 \
    libmysofa1 \
    libopenal1 \
    libomxil-bellagio0 \
    libopencore-amrnb0 \
    libopencore-amrwb0 \
    libopenjp2-7 \
    libopenmpt0 \
    libopus0 \
    libpulse0 \
    librubberband2 \
    librsvg2-2 \
    libsctp1 \
    libsdl2-2.0-0 \
    libshine3 \
    libsnappy1v5 \
    libsoxr0 \
    libspeex1 \
    libssh-gcrypt-4 \
    libtesseract4 \
    libtheora0 \
    libtwolame0 \
    libva2 \
    libvdpau1 \
    libvidstab1.1 \
    libvo-amrwbenc0 \
    libvorbis0a \
    libvpx7 \
    libwavpack1 \
    libwebp7 \
    libx264-163 \
    libx265-199 \
    libxcb-shape0 \
    libxcb-shm0 \
    libxcb-xfixes0 \
    libxml2 \
    libxv1 \
    libxvidcore4 \
    libxvmc1 \
    libzmq5 \
    libzvbi0 \
    ocl-icd-libopencl1 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy FFmpeg binaries and libraries from builder
COPY --from=builder /usr/local/ffmpeg-nvidia /usr/local/ffmpeg-nvidia

# Copy required CUDA NPP libraries from builder (needed for --enable-libnpp)
COPY --from=builder /usr/local/cuda/lib64/libnpp*.so* /usr/local/cuda/lib64/

# Update library cache
RUN ldconfig

# Verify FFmpeg installation (as root before switching users)
RUN /usr/local/ffmpeg-nvidia/bin/ffmpeg -version && \
    /usr/local/ffmpeg-nvidia/bin/ffmpeg -codecs 2>/dev/null | grep -q cuvid && \
    /usr/local/ffmpeg-nvidia/bin/ffmpeg -codecs 2>/dev/null | grep -q nvenc

# Switch to non-root user
USER ffmpeg
WORKDIR /home/ffmpeg

# Default command
CMD ["/bin/bash"]
