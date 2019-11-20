FROM ubuntu:18.04

ENV DEBIAN_FRONTEND="noninteractive"

# Install Deps
RUN dpkg --add-architecture i386 && \
  apt update --quiet && \
  #essentials
  apt install --quiet -y \
  expect git wget openjdk-8-jdk rsync unzip git curl \
  #android
  libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1  \
  #build go
  golang \
  #build clang
  clang \
  #build GCC
  build-essential \
  #build buck
  ant \
  python \
  python3 \
  #build rust
  && curl https://sh.rustup.rs -sSf | sh -s -- -y
  
# Install build dependencies (and vim + picocom for editing/debugging)
RUN apt-get -qq update \
    && apt-get install -y gcc git wget make libncurses-dev flex bison gperf python python-serial \
                          cmake ninja-build \
                          ccache \
                          vim picocom \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
# Setup ssh server
RUN apt update && \
  apt install -y openssh-server && \
  mkdir /var/run/sshd && \
  echo 'root:root' |chpasswd && \
  sed -ri 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
EXPOSE 22
CMD    ["/usr/sbin/sshd", "-D"]
