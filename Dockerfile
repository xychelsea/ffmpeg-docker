# DeepFaceLab Dockerfile for Anaconda with TensorFlow stack
# Copyright (C) 2020, 2021  Chelsea E. Manning
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

FROM xychelsea/anaconda3:v0.3-gpu
LABEL description="FFmpeg GPU Container"

# $ docker build --network=host -t xychelsea/ffmpeg-nvidia:latest -f Dockerfile .
# $ docker run --gpus all --rm -it xychelsea/ffmpeg-nvidia:latest /bin/bash
# $ docker push xychelsea/ffmpeg-nvidia:latest

# Start as root
USER root

# Update packages
RUN apt-get update --fix-missing \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade

# Install dependencies
RUN apt-get -y install \
    wget \
    debhelper-compat flite1-dev frei0r-plugins-dev ladspa-sdk libaom-dev libaribb24-dev libass-dev libbluray-dev libbs2b-dev libbz2-dev libcaca-dev libcdio-paranoia-dev libchromaprint-dev libcodec2-dev libdc1394-22-dev libdrm-dev libfdk-aac-dev libffmpeg-nvenc-dev libfontconfig1-dev libfreetype6-dev libfribidi-dev libgl1-mesa-dev libgme-dev libgnutls28-dev libgsm1-dev libiec61883-dev libavc1394-dev libjack-jackd2-dev liblensfun-dev liblilv-dev liblzma-dev libmp3lame-dev libmysofa-dev libopenal-dev libomxil-bellagio-dev libopencore-amrnb-dev libopencore-amrwb-dev libopenjp2-7-dev libopenmpt-dev libopus-dev libpulse-dev librubberband-dev librsvg2-dev libsctp-dev libsdl2-dev libshine-dev libsnappy-dev libsoxr-dev libspeex-dev libssh-gcrypt-dev libtesseract-dev libtheora-dev libtwolame-dev libva-dev libvdpau-dev libvidstab-dev libvo-amrwbenc-dev libvorbis-dev libvpx-dev libwavpack-dev libwebp-dev libx264-dev libx265-dev libxcb-shape0-dev libxcb-shm0-dev libxcb-xfixes0-dev libxml2-dev libxv-dev libxvidcore-dev libxvmc-dev libzmq3-dev libzvbi-dev ocl-icd-opencl-dev pkg-config texinfo nasm zlib1g-dev cleancss doxygen node-less tree

# Switch to user "anaconda"
USER ${ANACONDA_UID}
WORKDIR ${HOME}

RUN cd ~ \
    && wget -O ~/FFmpeg-n4.4.orig.tar.xz https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n4.4.tar.gz \
    && tar -xvf FFmpeg-n4.4.orig.tar.xz \
    && cd ~/FFmpeg-n4.4 \
    && ./configure --prefix=/usr/local/ffmpeg-nvidia \
        --extra-cflags=-I/usr/local/cuda/include \
        --extra-ldflags=-L/usr/local/cuda/lib64 \
        --toolchain=hardened \
        --enable-gpl \
        --disable-stripping \
        --enable-avresample --disable-filter=resample \
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
        --enable-sdl2 \
    && make -j 8

USER root

RUN cd /home/anaconda/FFmpeg-n4.4 \
   && make install

USER $ANACONDA_UID

RUN echo 'PATH="/usr/local/ffmpeg-nvidia/bin:$PATH"' >> $HOME/.bashrc

# Switch back to root
USER root

# Clean Anaconda
RUN conda clean -afy

# Clean packages and caches
RUN apt-get --purge -y autoremove \
        wget \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* ${HOME}/ffmpeg* \
    && rm -rvf /home/${ANACONDA_PATH}/.cache/yarn \
    && fix-permissions ${HOME} \
    && fix-permissions ${ANACONDA_PATH}

# Re-activate user "anaconda"
USER $ANACONDA_UID
WORKDIR $HOME