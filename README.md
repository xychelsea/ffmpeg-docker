FFMPEG NVIDIA/CUDA GPU-enabled Docker Container
-----
Provides an [NVIDIA GPU-enabled](https://hub.docker.com/r/nvidia/cuda) container with [FFmpeg](https://ffmpeg.org/) pre-installed on an [Anaconda](https://www.anaconda.com/) container ```xychelsea/ffmpeg-nvidia:latest```, and optional [Jupyter Notebooks](https://jupyter.org/) container ```xychelsea/ffmpeg:latest-jupyter```.

FFmpeg with NVIDIA/CUDA support
-----
FFmpeg is the leading multimedia framework, able to decode, encode, transcode, mux, demux, stream, filter and play pretty much anything that humans and machines have created. It supports the most obscure ancient formats up to the cutting edge. No matter if they were designed by some standards committee, the community or a corporation. It is also highly portable: FFmpeg compiles, runs, and passes our testing infrastructure FATE across Linux, Mac OS X, Microsoft Windows, the BSDs, Solaris, etc. under a wide variety of build environments, machine architectures, and configurations.

[Anaconda](https://anaconda.com/) is an open data science platform based on Python 3. This container allows you to create custom Anaconda environments through the ```conda``` command with a lightweight version of Anaconda (Miniconda) and the ```conda-forge``` [repository](https://conda-forge.org/) in the ```/usr/local/anaconda``` directory. The default user, ```anaconda``` runs a [Tini shell](https://github.com/krallin/tini/) ```/usr/bin/tini```, and comes preloaded with the ```conda``` command in the environment ```$PATH```. An additional flavor of this container provides [Jupyter Notebooks](https://jupyter.org/) tags.

### NVIDIA/CUDA GPU-enabled Containers

Two flavors provide an [NVIDIA GPU-enabled](https://hub.docker.com/r/nvidia/cuda) container with [TensorFlow](https://tensorflow.org) pre-installed through [Anaconda](https://anaconda.com/).

## Getting the containers

The base container, based on the ```xychelsea/anaconda3:latest-gpu``` from the [Anaconda 3 container stack](https://hub.docker.com/r/xychelsea/anaconda3) (```xychelsea/anaconda3:latest```) running Tini shell. For the container with a ```/usr/bin/tini``` entry point, use:

```bash
docker pull xychelsea/ffmpeg-nvidia:latest
```

With Jupyter Notebooks server pre-installed, pull with:

```bash
docker pull xychelsea/ffmpeg-nvidia:latest-jupyter
```

## Running the containers

To run the containers with the generic Docker application or NVIDIA enabled Docker, use the ```docker run``` command with a bound volume directory ```workspace``` attached at mount point ```/home/anaconda/workspace```.

```bash
docker run --gpus all --rm -it
     -v workspace:/home/anaconda/workspace \
     xychelsea/ffmpeg-nvidia:latest /bin/bash
```

With Jupyter Notebooks server pre-installed, run with:

```bash
docker run --gpus all --rm -it -d
     -v workspace:/home/anaconda/workspace \
     -p 8888:8888 \
     xychelsea/deepfacelab:latest-jupyter
```

## Using FFmpeg

Once inside the container, as the default user ```anaconda```, you can use the compiler to transcode using hardware acceleration.

First, however, enter ```nvidia-smi``` to see whether the container can see your NVIDIA devices. Second, check to ensure that directory of ```ffmpeg``` is ```/usr/local/ffmpeg-nvidia``` by entering ```which ffmpeg``` into a shell. Lastly, ensure that the compiled version of ```ffmpeg``` has access to both the hardware encoder and decoder using ```ffmpeg -codecs | grep -e cuvid``` and ```ffmpeg -codecs | grep -e nvenc``` respectively.

In this example, we transcode an H.264/MPEG-4 AVC video file ```input.mp4``` into an H.265/MPEG-4 HEVC video file ```output.mp4``` using the ```cuvid``` decoder and ```nvenc``` encoder (see the [NVIDIA Transcoding Guide](https://developer.nvidia.com/blog/nvidia-ffmpeg-transcoding-guide/) for more details on hardware decoding and encoding)

```bash
ffmpeg \
    -vsync 0 \
    -hwaccel cuvid \
    -c:v h264_cuvid \
    -i input.mp4 \
    -c:v hevc_nvenc \
    -cq:v 4 \
    output.mp4
```

## Building the containers

To build either the GPU-enabled container, use the [ffmpeg-docker](https://github.com/xychelsea/ffmpeg-docker) GitHub repository.

```bash
git clone git://github.com/xychelsea/ffmpeg-docker.git
```

### Compiling FFmpeg with NVIDIA/CUDA GPU support

```bash
docker build -t ffmpeg-nvidia:latest -f Dockerfile .
```

With Jupyter Notebooks server pre-installed, build with:

```
docker build -t ffmpeg-nvidia:latest-jupyter -f Dockerfile.jupyter .
```

## Default Compiler Flags

The default compiler configuration file uses the following flags:

```
./configure
        --prefix=/usr/local/ffmpeg-nvidia \
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
        --enable-sdl2
```

## References

- [FFmpeg](https://ffmpeg.org)
- [NVIDIA CUDA container](https://hub.docker.com/r/nvidia/cuda)
- [Anaconda 3](https://www.anaconda.com/blog/tensorflow-in-anaconda)
- [conda-forge](https://conda-forge.org/)
