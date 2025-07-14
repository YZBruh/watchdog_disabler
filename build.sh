#!/bin/bash
#
#  Copyright 2025 Yağız Zengin
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at

#	  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

set -e

BUILD_64="build_arm64-v8a"
BUILD_32="build_armeabi-v7a"
THIS="$(basename $0)"

echo()
{
	command echo "[$THIS]: $@"
}

checks()
{
	if [ -z "$ANDROID_NDK" ]; then
		echo "Please set ANDROID_NDK variable as your NDK path."
		exit 1
	fi
	if [ ! -f /usr/bin/cmake ] && [ ! -f /bin/cmake ]; then
		echo "Please verify your CMake installation."
		exit 1
	fi
}

clean()
{
	echo "Cleaning workspace."
	rm -rf $BUILD_32 $BUILD_64
}

build()
{
	mkdir -p $BUILD_64 $BUILD_32
	command echo -e "BUILD INFO:
	ARCHS: arm64-v8a armeabi-v7a
	ANDROID_PLATFORM: android-21 (android 5.0)
	ANDROID_TOOLCHAIN_FILE: $ANDROID_NDK/build/cmake/android.toolchain.cmake\n"

	echo "Configuring for arm64-v8a..."
	cmake -B $BUILD_64 -S . \
		-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
		-DANDROID_ABI=arm64-v8a \
		-DANDROID_PLATFORM=android-21

	echo "Configuring for armeabi-v7a..."
	cmake -B $BUILD_32 -S . \
		-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
		-DANDROID_ABI=armeabi-v7a \
		-DANDROID_PLATFORM=android-21

	echo "Building arm64-v8a artifacts..."
	cmake --build $BUILD_64
	echo "arm64-v8a build complete, artifacts: $PWD/$BUILD_64"

	echo "Building armeabi-v7a artifacts..."
	cmake --build $BUILD_32
	echo "armeabi-v7a build complete, artifacts: $PWD/$BUILD_32"
}

if [ $# -eq 0 ]; then
	command echo "Usage: $0 build|rebuild|clean"
	exit 1
fi

case $1 in
	"build")	checks; build ;;
	"clean")	clean ;;
	"rebuild")	clean; checks; build ;;
	*)
		command echo "$0: Unknown argument: $1"
		exit 1 ;;
esac
