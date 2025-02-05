FROM ubuntu AS base
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y libfreetype6 libxrender1 libfontconfig1 libxext6
RUN apt-get install -y build-essential git make

FROM base AS deps
RUN apt-get update && \
    apt-get install -y wget unzip bzip2 \
        libx11-6 xvfb
WORKDIR /tmp
RUN wget https://www.segger.com/downloads/embedded-studio/Setup_EmbeddedStudio_ARM_v540_linux_x64.tar.gz && \
    tar xzvf Setup_EmbeddedStudio_ARM_v540_linux_x64.tar.gz && \
    xvfb-run ./arm_segger_embedded_studio_540_linux_x64/install_segger_embedded_studio --silent --accept-license --destination /usr/local/segger && \
    rm -rf ./arm_segger_embedded_studio_540_linux_x64 && \
    rm -f Setup_EmbeddedStudio_ARM_v540_linux_x64.tar.gz
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && \
    tar xvjf gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && \
    mv gcc-arm-none-eabi-10.3-2021.10 /usr/local/gcc-arm-none-eabi && \
    rm -f gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2
RUN wget https://developer.nordicsemi.com/.pc-tools/nrfutil/x64-linux/nrfutil && \
    mv nrfutil /usr/local/bin/ && \
    chmod +x /usr/local/bin/nrfutil
RUN wget https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/sdks/nrf5/binaries/nrf5_sdk_17.1.0_ddde560.zip && \
    unzip nrf5_sdk_17.1.0_ddde560.zip && \
    mv nRF5_SDK_17.1.0_ddde560/ /sdk && \
    rm -f nrf5_sdk_17.1.0_ddde560.zip
WORKDIR /sdk/components/drivers_ext
RUN git clone https://github.com/boschsensortec/BMI270_SensorAPI.git && \
    git clone https://github.com/boschsensortec/BMP3_SensorAPI.git && \
    rm -rf BMI270_SensorAPI/.git && \
    rm -rf BMP3_SensorAPI/.git
RUN mkdir -p /sdk/examples/projects
WORKDIR /sdk/external/micro-ecc
RUN git clone https://github.com/kmackay/micro-ecc.git && \
    rm -rf micro-ecc/.git
WORKDIR /sdk/components/toolchain/gcc/
RUN sed -i 's|^GNU_INSTALL_ROOT\s*?=.*|GNU_INSTALL_ROOT ?= /usr/local/gcc-arm-none-eabi/bin/|' Makefile.posix
WORKDIR /sdk/external/micro-ecc/nrf52hf_armgcc/armgcc
RUN make
RUN test -f /sdk/external/micro-ecc/nrf52hf_armgcc/armgcc/micro_ecc_lib_nrf52.a || (echo "micro_ecc_lib_nrf52.a not found!" && exit 1)

FROM base AS builder
COPY --from=deps /usr/local/gcc-arm-none-eabi /usr/local/gcc-arm-none-eabi
COPY --from=deps /usr/local/segger /usr/local/segger
COPY --from=deps /usr/local/bin/nrfutil /usr/local/bin/nrfutil
COPY --from=deps /sdk /sdk
ENV PATH="$PATH:/usr/local/segger/bin"
WORKDIR /sdk/examples/projects