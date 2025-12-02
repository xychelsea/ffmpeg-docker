FFMPEG NVIDIA/CUDA GPU-enabled Docker Container
-----
Provides an [NVIDIA GPU-enabled](https://hub.docker.com/r/nvidia/cuda) container with [FFmpeg 8.0](https://ffmpeg.org/) pre-installed with full hardware acceleration support.

FFmpeg with NVIDIA/CUDA support
-----
FFmpeg is the leading multimedia framework, able to decode, encode, transcode, mux, demux, stream, filter and play pretty much anything that humans and machines have created. It supports the most obscure ancient formats up to the cutting edge. No matter if they were designed by some standards committee, the community or a corporation. It is also highly portable: FFmpeg compiles, runs, and passes our testing infrastructure FATE across Linux, Mac OS X, Microsoft Windows, the BSDs, Solaris, etc. under a wide variety of build environments, machine architectures, and configurations.

This container is built using a lightweight [NVIDIA CUDA base image](https://hub.docker.com/r/nvidia/cuda) with Ubuntu 22.04, providing minimal overhead while maintaining full GPU acceleration capabilities. The container uses a multi-stage build process to optimize image size and build time.

### NVIDIA/CUDA GPU-enabled Container

This container provides an [NVIDIA GPU-enabled](https://hub.docker.com/r/nvidia/cuda) environment with FFmpeg 8.0 compiled with full hardware acceleration support, including NVENC encoding and CUVID decoding.

## Getting the container

Pull the container from Docker Hub:

```bash
docker pull xychelsea/ffmpeg-nvidia:latest
```

## Running the container

### Using Docker Run

To run the container with NVIDIA GPU support, use the ```docker run``` command with a bound volume directory ```workspace``` attached at mount point ```/home/ffmpeg/workspace```.

```bash
docker run --gpus all --rm -it \
     -v workspace:/home/ffmpeg/workspace \
     xychelsea/ffmpeg-nvidia:latest /bin/bash
```

### Using Docker Compose

A `docker-compose.yml` file is provided with multiple service configurations for different use cases. This is the recommended approach for easier management and configuration.

#### Prerequisites

- Docker Compose v1.28+ or Docker Compose v2.0+
- NVIDIA Container Toolkit installed on the host
- Create input and output directories (or customize paths in `.env`)

#### Quick Start

1. **Create directories** (or customize in `.env`):
   ```bash
   mkdir -p input output scripts
   ```

2. **Interactive shell** - For manual FFmpeg operations:
   ```bash
   docker-compose run --rm ffmpeg-interactive
   ```

3. **Transcode a file** - One-shot transcoding with GPU acceleration:
   ```bash
   # Set input/output files via environment variables
   INPUT_FILE=input.mp4 OUTPUT_FILE=output.mp4 docker-compose run --rm ffmpeg-transcode
   ```

4. **Batch processing** - Process multiple files:
   ```bash
   # Create a batch script in ./scripts/batch-process.sh
   docker-compose run --rm ffmpeg-batch
   ```

5. **Stream processing** - Real-time streaming:
   ```bash
   RTMP_URL=rtmp://your-server/live/stream docker-compose up -d ffmpeg-stream
   ```

#### Available Services

- **`ffmpeg-interactive`**: Interactive shell for manual operations
- **`ffmpeg-transcode`**: One-shot transcoding job (H.264 to HEVC example)
- **`ffmpeg-batch`**: Batch processing service for multiple files
- **`ffmpeg-stream`**: Real-time streaming service with GPU encoding

#### Environment Variables

Create a `.env` file to customize configuration:

```bash
# GPU Configuration
NVIDIA_VISIBLE_DEVICES=all
CUDA_VISIBLE_DEVICES=

# Directory paths (relative to docker-compose.yml)
INPUT_DIR=./input
OUTPUT_DIR=./output
SCRIPTS_DIR=./scripts

# File names (for transcode service)
INPUT_FILE=input.mp4
OUTPUT_FILE=output.mp4

# Streaming (for stream service)
RTMP_URL=rtmp://localhost/live/stream
```

See `docker-compose.yml` for detailed comments and additional configuration options.

## Using FFmpeg

Once inside the container, as the default user ```ffmpeg```, you can use FFmpeg to transcode using hardware acceleration.

First, enter ```nvidia-smi``` to see whether the container can see your NVIDIA devices. Second, check to ensure that the directory of ```ffmpeg``` is ```/usr/local/ffmpeg-nvidia/bin``` by entering ```which ffmpeg``` into a shell. Lastly, ensure that the compiled version of ```ffmpeg``` has access to both the hardware encoder and decoder using ```ffmpeg -codecs | grep -e cuvid``` and ```ffmpeg -codecs | grep -e nvenc``` respectively.

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

## Building the container

To build the GPU-enabled container, use the [ffmpeg-docker](https://github.com/xychelsea/ffmpeg-docker) GitHub repository.

```bash
git clone git://github.com/xychelsea/ffmpeg-docker.git
cd ffmpeg-docker
```

### Compiling FFmpeg with NVIDIA/CUDA GPU support

```bash
docker build --network=host -t xychelsea/ffmpeg-nvidia:latest -f Dockerfile .
```

The build process uses a multi-stage approach:
- **Builder stage**: Compiles FFmpeg 8.0 from source with all codecs and libraries
- **Runtime stage**: Creates a minimal image with only the compiled binaries and runtime dependencies

## Default Compiler Flags

The default compiler configuration uses the following flags:

```
./configure
        --prefix=/usr/local/ffmpeg-nvidia \
        --extra-cflags=-I/usr/local/cuda/include \
        --extra-ldflags=-L/usr/local/cuda/lib64 \
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

## Base Image

This container is based on `nvidia/cuda:12.5.1-base-ubuntu22.04`, providing:
- CUDA 12.5.1 runtime support
- Ubuntu 22.04 LTS
- Minimal image size with only essential CUDA libraries

## References

- [FFmpeg](https://ffmpeg.org)
- [NVIDIA CUDA container](https://hub.docker.com/r/nvidia/cuda)
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-container-toolkit)
- [NVIDIA Transcoding Guide](https://developer.nvidia.com/blog/nvidia-ffmpeg-transcoding-guide/)
