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

# Copy install tools
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

# Setup environment variables
ENV ANDROID_SDK_FILE_NAME tools_r25.2.3-linux.zip
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin
ENV ANDROID_SDK_INSTALLER "echo \"y\" | \"${ANDROID_HOME}/tools/bin/sdkmanager\""
RUN echo "export ANDROID_HOME=$ANDROID_HOME" | cat - ~/.bashrc >> temp && mv temp ~/.bashrc

# Install Android SDK
RUN mkdir -p $ANDROID_HOME && \
  mkdir "$ANDROID_HOME/licenses" || true && \
  echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license" && \
  echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license" && \
  curl https://dl.google.com/android/repository/$ANDROID_SDK_FILE_NAME --progress-bar --location --output $ANDROID_SDK_FILE_NAME && \
  unzip $ANDROID_SDK_FILE_NAME -d $ANDROID_HOME && \
  rm $ANDROID_SDK_FILE_NAME

RUN eval $ANDROID_SDK_INSTALLER '"tools"' && \
  eval $ANDROID_SDK_INSTALLER '"platform-tools"' && \
  eval $ANDROID_SDK_INSTALLER '"build-tools;25.0.2"' && \
  eval $ANDROID_SDK_INSTALLER '"platforms;android-25"' && \
  eval $ANDROID_SDK_INSTALLER '"extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"' && \
  eval $ANDROID_SDK_INSTALLER '"extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"'

# Setup ssh server
RUN apt update && \
  apt install -y openssh-server && \
  mkdir /var/run/sshd && \
  echo 'root:root' |chpasswd && \
  sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
EXPOSE 22
CMD    ["/usr/sbin/sshd", "-D"]
