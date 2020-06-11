#Image dependencies for downloading
FROM ubuntu:18.04 AS ndk-sdk-utils
RUN apt-get update && \
    apt-get install -y wget --no-install-recommends && \
    apt-get install -y ca-certificates --no-install-recommends && \
    apt-get install -y unzip --no-install-recommends && \
    rm /var/lib/apt/lists/* -rf

#Build dependencies for downloading
# Download android ndk
ENV ANDROID_NDK_VERSION r12b
# download and uncompress
RUN mkdir /opt/android-ndk-tmp
WORKDIR /opt/android-ndk-tmp
RUN wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
    unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
    rm android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip

# download and uncompress
RUN mkdir /opt/android-sdk-tmp
WORKDIR /opt/android-sdk-tmp
RUN wget -q https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip && \
    unzip -q sdk-tools-linux-3859397.zip && \
    rm sdk-tools-linux-3859397.zip

#################################################################################################
#Build base image
FROM ubuntu:18.04 AS ndk-sdk-base
RUN apt-get update && \
    apt-get install -y build-essential --no-install-recommends && \
    apt-get install -y openjdk-8-jdk --no-install-recommends && \
    apt-get install -y file --no-install-recommends && \
    apt-get install -y cmake --no-install-recommends && \
    apt-get install -y git && \
    rm /var/lib/apt/lists/* -rf

ENV CMAKE_EXE=cmake

# Copy android ndk from ndk-utils
ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK_VERSION r12b

# move ndk to its final location
COPY --from=ndk-sdk-utils /opt/android-ndk-tmp/android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME}

# add ndk to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}
ENV ANDROID_NDK ${ANDROID_NDK_HOME}/android-ndk-${ANDROID_NDK_VERSION}
ENV PATH ${ANDROID_NDK}:${PATH}

# Copy android sdk from ndk-utils
ENV ANDROID_SDK_HOME /opt/android-sdk

# move sdk to its final location
COPY --from=ndk-sdk-utils /opt/android-sdk-tmp ${ANDROID_SDK_HOME}

# add sdk to PATH
ENV PATH ${PATH}:${ANDROID_SDK_HOME}/tools:${ANDROID_SDK_HOME}/tools/bin