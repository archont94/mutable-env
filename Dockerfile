FROM ubuntu:14.04
ENV WORKSPACE_DIR "/mutable-env/"
ENV DEBIAN_FRONTEND noninteractive

# Install some additional drivers, including support for FTDI dongles
# http://askubuntu.com/questions/541443/how-to-install-usbserial-and-ftdi-sio-modules-to-14-04-trusty-vagrant-box
#RUN apt-get update -qq && \
#  apt-get install -y linux-image-extra-virtual && \
#  modprobe ftdi_sio vendor=0x0403 product=0x6001

# Install basic development tools
RUN dpkg --add-architecture i386 && \
  apt-get update -qq && \
  apt-get install -y build-essential autotools-dev autoconf pkg-config libusb-1.0-0 libusb-1.0-0-dev libftdi1 libftdi-dev git libc6:i386 libncurses5:i386 libstdc++6:i386 cowsay figlet language-pack-en && \
  locale-gen en_US.UTF-8 || true

# Install python
RUN apt-get install -y python2.7 python-numpy python-scipy python-matplotlib python3 python3-serial

# Install development tools for avr
RUN apt-get install -y gcc-avr binutils-avr avr-libc avrdude wget

# The makefile from Mutable Instruments expects the avr-gcc binaries to be
# in a different directory.
RUN ln -s /usr /usr/local/CrossPack-AVR && \
  mkdir -p "${WORKSPACE_DIR}"

# Install openocd
RUN cd "${WORKSPACE_DIR}" && \
  wget -nv https://downloads.sourceforge.net/project/openocd/openocd/0.11.0/openocd-0.11.0.tar.gz --no-check-certificate && \
  tar xfz openocd-0.11.0.tar.gz && \
  cd openocd-0.11.0 && \
  ./configure --enable-ftdi --enable-stlink && \
  make && \
  make install && \
  cd "${WORKSPACE_DIR}" && \
  rm -rf openocd-0.11.0 && \
  rm *.tar.gz

# Install stlink
RUN cd "${WORKSPACE_DIR}" && \
  wget -nv https://github.com/texane/stlink/archive/v1.1.0.tar.gz --no-check-certificate && \
  tar xfz v1.1.0.tar.gz && \
  cd stlink-1.1.0 && \
  ./autogen.sh && \
  ./configure && \
  make && \
  make install && \
  cp 49-stlink*.rules /etc/udev/rules.d/ && \
  cd "${WORKSPACE_DIR}" && \
  rm -rf stlink-1.1.0 && \
  rm *.tar.gz

# Allow non-root users to access USB devices such as Atmel AVR and Olimex
# programmers, FTDI dongles...
RUN echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="15ba", ATTRS{idProduct}=="0003", GROUP="users", MODE="0666"' >> /etc/udev/rules.d/60-programmers.rules && \
  echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="15ba", ATTRS{idProduct}=="002a", GROUP="users", MODE="0666"' >> /etc/udev/rules.d/60-programmers.rules && \
  echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="15ba", ATTRS{idProduct}=="002b", GROUP="users", MODE="0666"' >> /etc/udev/rules.d/60-programmers.rules && \
  echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2104", GROUP="users", MODE="0666"' >> /etc/udev/rules.d/60-programmers.rules && \
  echo 'SUBSYSTEMS=="usb", KERNEL=="ttyUSB*", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="users", MODE="0666", SYMLINK+="ftdi-usbserial"' >> /etc/udev/rules.d/60-programmers.rules  && \
  udevadm control --reload-rules || true && \
  udevadm trigger


# Install toolchain for STM32F
RUN cd "${WORKSPACE_DIR}" && \
  wget -nv https://launchpad.net/gcc-arm-embedded/4.8/4.8-2013-q4-major/+download/gcc-arm-none-eabi-4_8-2013q4-20131204-linux.tar.bz2 --no-check-certificate && \
  tar xjf gcc-arm-none-eabi-4_8-2013q4-20131204-linux.tar.bz2 && \
  mv gcc-arm-none-eabi-4_8-2013q4 /usr/local/arm-4.8.3/ && \
  rm *.tar.bz2

# (We're progressively checking that all STM32F1 projects can also be built with
# this gcc version instead of 4.5.2).
RUN ln -s /usr/local/arm-4.8.3 /usr/local/arm

# Add "." to PYTHONPATH, and set default language
RUN echo 'export LC_ALL=en_US.UTF-8' >> /root/.bashrc && \
  echo 'export LANGUAGE=en_US' >> /root/.bashrc && \
  echo 'export PYTHONPATH=.:$PYTHONPATH' >> /root/.bashrc

CMD cd "${WORKSPACE_DIR}" && /bin/bash
