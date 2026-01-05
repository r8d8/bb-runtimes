# Use Ubuntu 24.04 as base
FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set up environment variables
ENV ARM_TOOLCHAIN_VERSION=13.3.Rel1
ENV ALIRE_VERSION=2.1.0

# Install base dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    make \
    cmake \
    autoconf \
    automake \
    libtool \
    pkg-config \
    # Python and utilities
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    # Version control
    git \
    git-lfs \
    # Utilities
    wget \
    curl \
    unzip \
    xz-utils \
    bzip2 \
    # Text editors and tools
    vim \
    nano \
    file \
    tree \
    htop \
    # Development tools
    gdb-multiarch \
    openocd \
    # Libraries
    libncurses6 \
    libpython3-dev \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# Create installation directories
RUN mkdir -p /opt/arm-toolchain /tmp/downloads

# Install Alire (Ada package manager)
# Download and install Alire for Linux x86_64
WORKDIR /tmp/downloads
RUN wget -q https://github.com/alire-project/alire/releases/download/v${ALIRE_VERSION}/alr-${ALIRE_VERSION}-bin-x86_64-linux.zip \
    && unzip alr-${ALIRE_VERSION}-bin-x86_64-linux.zip \
    && mkdir -p /usr/local/bin \
    && mv bin/alr /usr/local/bin/ \
    && chmod +x /usr/local/bin/alr \
    && rm -rf alr-${ALIRE_VERSION}-bin-x86_64-linux.zip bin


# Download and install ARM GCC toolchain with Ada support
# Note: For full Ada support on ARM, you may need to build from source or use AdaCore's toolchain
WORKDIR /tmp/downloads

# Install ARM GCC (bare-metal)
RUN wget -q https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_TOOLCHAIN_VERSION}/binrel/arm-gnu-toolchain-${ARM_TOOLCHAIN_VERSION}-x86_64-arm-none-eabi.tar.xz \
    && tar -xf arm-gnu-toolchain-${ARM_TOOLCHAIN_VERSION}-x86_64-arm-none-eabi.tar.xz -C /opt \
    && ls -la /opt/ \
    && mv /opt/arm-gnu-toolchain-* /opt/arm-toolchain \
    && rm arm-gnu-toolchain-${ARM_TOOLCHAIN_VERSION}-x86_64-arm-none-eabi.tar.xz

# Install Python packages for bb-runtimes
RUN pip3 install --break-system-packages --no-cache-dir \
    pyyaml \
    jinja2 \
    pyelftools \
    intelhex

# Note: User creation is handled by the common-utils feature in devcontainer.json

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
