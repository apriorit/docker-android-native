FROM ubuntu:18.04

LABEL maintainer="Andrey Mokych <mokych.andrey@apriorit.com>"

RUN apt-get update
RUN apt-get install -y git wget unzip cmake xxd build-essential gcovr
RUN apt-get install -y openjdk-8-jdk

# Get Plog sources
RUN mkdir -p /tmp/plog
WORKDIR /tmp/plog
RUN git clone --depth=1 --branch=1.1.3 https://github.com/SergiusTheBest/plog.git plog
RUN cp -r ./plog/include/plog /opt/include/
WORKDIR /
RUN rm -rdf /tmp/plog

# Download android ndk
ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK_VERSION r12b

# download
RUN mkdir /opt/android-ndk-tmp
WORKDIR /opt/android-ndk-tmp
RUN wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
# uncompress
RUN unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
# move to its final location
RUN mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME}
WORKDIR /
RUN rm -rf /opt/android-ndk-tmp

# add to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}

# Download android sdk
ENV ANDROID_SDK_HOME /opt/android-sdk

# download
RUN mkdir ${ANDROID_SDK_HOME}
WORKDIR ${ANDROID_SDK_HOME}
RUN wget -q https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
# uncompress
RUN unzip -q sdk-tools-linux-3859397.zip
RUN rm sdk-tools-linux-3859397.zip
# setup development environment
RUN yes | sdkmanager --licenses
RUN sdkmanager "emulator"
RUN sdkmanager "platforms;android-25"
RUN sdkmanager "platform-tools"

ENV PATH ${PATH}:${ANDROID_SDK_HOME}/emulator:${ANDROID_SDK_HOME}/tools:${ANDROID_SDK_HOME}/tools/bin:${ANDROID_SDK_HOME}/platform-tools

RUN sdkmanager "system-images;android-25;google_apis;armeabi-v7a"
RUN sdkmanager "system-images;android-25;google_apis;arm64-v8a"
RUN echo no | avdmanager create avd -n armeabi-v7a -k "system-images;android-25;google_apis;armeabi-v7a" -g "google_apis" -f
RUN echo no | avdmanager create avd -n arm64-v8a -k "system-images;android-25;google_apis;arm64-v8a" -g "google_apis" -f
RUN emulator -list-avds
ENV ANDROID_EMULATOR_FORCE_32BIT true

RUN git clone --depth=1 --branch=release-1.10.0 https://github.com/google/googletest.git /opt/gtest
ENV GTEST_HOME /opt/gtest

VOLUME [ "/tmp/app" ]
WORKDIR /tmp/app