#!/bin/bash
# 
# Creates a new ios release from current branch
#

export BASEDIR=$(pwd)
export SOURCE_PACKAGE="${BASEDIR}/../../prebuilt/ios-framework"
export COCOA_PACKAGE="${BASEDIR}/../../prebuilt/ios-cocoa"
export UNIVERSAL_PACKAGE="${BASEDIR}/../../prebuilt/ios-universal"
export ALL_UNIVERSAL_PACKAGES="${BASEDIR}/../../prebuilt/ios-all-universal"

create_package() {
    local PACKAGE_NAME="mobile-ffmpeg-$1"
    local PACKAGE_VERSION="$2"

    local CURRENT_PACKAGE="${COCOA_PACKAGE}/${PACKAGE_NAME}"
    rm -rf ${CURRENT_PACKAGE}
    mkdir ${CURRENT_PACKAGE} || exit 1

    cp -r ${SOURCE_PACKAGE}/* ${CURRENT_PACKAGE} || exit 1
    cd ${CURRENT_PACKAGE} || exit 1
    zip -r "../mobile-ffmpeg-$1-$2-ios-framework.zip" * || exit 1

    # COPY PODSPEC AS THE LAST ITEM
    cp ${BASEDIR}/ios/${PACKAGE_NAME}.podspec ${CURRENT_PACKAGE} || exit 1
    sed -i '' "s/VERSION/${PACKAGE_VERSION}/g" ${CURRENT_PACKAGE}/${PACKAGE_NAME}.podspec || exit 1

    mkdir -p ${ALL_UNIVERSAL_PACKAGES} || exit 1
    local CURRENT_UNIVERSAL_PACKAGE="${ALL_UNIVERSAL_PACKAGES}/${PACKAGE_NAME}-universal"
    rm -rf ${CURRENT_UNIVERSAL_PACKAGE}
    cp -r ${UNIVERSAL_PACKAGE}/mobile-ffmpeg-universal ${CURRENT_UNIVERSAL_PACKAGE} || exit 1
}

if [ $# -ne 1 ];
then
    echo "Usage: ios.sh <version name>"
    exit 1
fi

# VALIDATE VERSIONS
MOBILE_FFMPEG_VERSION=$(grep 'MOBILE_FFMPEG_VERSION' ${BASEDIR}/../../ios/src/MobileFFmpeg.m | grep -Eo '\".*\"' | sed -e 's/\"//g')
if [ "${MOBILE_FFMPEG_VERSION}" != "$1" ]; then
    echo "Error: version mismatch. v$1 requested but v${MOBILE_FFMPEG_VERSION} found. Please perform the following updates and try again."
    echo "1. Update docs"
    echo "2. Update android/app/build.gradle file versions"
    echo "3. Update tools/release scripts' descriptions"
    echo "4. Update podspec links"
    echo "5. Update mobileffmpeg.h versions for both android and ios"
    exit 1
fi

# CREATE COCOA DIRECTORY
rm -rf ${COCOA_PACKAGE}
mkdir ${COCOA_PACKAGE} || exit 1

# MIN RELEASE
cd ${BASEDIR}/../.. || exit 1
./ios.sh ${CUSTOM_OPTIONS} || exit 1
create_package "min" "$1" || exit 1

# MIN-GPL RELEASE
cd ${BASEDIR}/../.. || exit 1
./ios.sh ${CUSTOM_OPTIONS} --enable-gpl --enable-libvidstab --enable-x264 --enable-x265 --enable-xvidcore || exit 1
create_package "min-gpl" "$1" || exit 1

# HTTPS RELEASE
cd ${BASEDIR}/../.. || exit 1
./ios.sh ${CUSTOM_OPTIONS} --enable-gnutls || exit 1
create_package "https" "$1" || exit 1

# HTTPS-GPL RELEASE
cd ${BASEDIR}/../.. || exit 1
./ios.sh ${CUSTOM_OPTIONS} --enable-gnutls --enable-gpl --enable-libvidstab --enable-x264 --enable-x265 --enable-xvidcore || exit 1
create_package "https-gpl" "$1" || exit 1

# AUDIO RELEASE
cd ${BASEDIR}/../.. || exit 1
./ios.sh ${CUSTOM_OPTIONS} --enable-chromaprint --enable-lame --enable-libilbc --enable-libvorbis --enable-opencore-amr --enable-opus --enable-shine --enable-soxr --enable-speex --enable-wavpack || exit 1
create_package "audio" "$1" || exit 1

# VIDEO RELEASE
cd ${BASEDIR}/../.. || exit 1
./ios.sh ${CUSTOM_OPTIONS} --enable-fontconfig --enable-freetype --enable-fribidi --enable-kvazaar --enable-libaom --enable-libass --enable-libiconv --enable-libtheora --enable-libvpx --enable-snappy --enable-libwebp || exit 1
create_package "video" "$1" || exit 1

# FULL RELEASE
cd ${BASEDIR}/../.. || exit 1
./ios.sh ${CUSTOM_OPTIONS} --full || exit 1
create_package "full" "$1" || exit 1

# FULL-GPL RELEASE
cd ${BASEDIR}/../.. || exit 1
./ios.sh ${CUSTOM_OPTIONS} --full --enable-gpl --enable-libvidstab --enable-x264 --enable-x265 --enable-xvidcore || exit 1
create_package "full-gpl" "$1" || exit 1
