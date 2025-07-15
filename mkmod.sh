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

echo() { command echo "[$THIS]: $@"; }

clean()
{
	rm -rf watchdog_disabler*.zip \
		$PWD/module/system/bin/disable_watchdog \
		$PWD/module/customize.sh
	touch $PWD/module/system/bin/placeholder
}

prepare()
{
	if [ ! -d $BUILD_32 ] || [ ! -d $BUILD_64 ]; then
		echo "Missing artifacts. Please build!"
		exit 1
	fi

	if [ ! -f /usr/bin/zip ] && [ ! -f /bin/zip ]; then
		echo "Please verify your Zip installation!"
		exit 1
	fi

	if [ -f $MOD ]; then rm $MOD; fi
}

mk_customize()
{
	if [ $1 -eq 32 ]; then
		cat <<EOF
#!/system/bin/sh

if ! getprop ro.product.cpu.abi | grep armeabi-v7a &>/dev/null; then
	echo "This module is compatible with 32-bit devices. Your device running a 64-bit system!"
	exit 1
fi
EOF
	elif [ $1 -eq 64 ]; then
		cat <<EOF
#!/system/bin/sh

if ! getprop ro.product.cpu.abi | grep arm64-v8a &>/dev/null; then
	echo "This module is compatible with 64-bit devices. Your device running a 32-bit system!"
	exit 1
fi
EOF
	else
		cat <<EOF
#!/system/bin/sh

echo "This module not generated correctly. Not usable. Re-generate with mkmod.sh. See https://github.com/YZBruh/watchdog_disabler"
exit 1
EOF
	fi
}

mkzip()
{
	local dir
	if [ $1 -eq 32 ]; then dir=$BUILD_32; else dir=$BUILD_64; fi

	cd module
	rm -f $PWD/system/bin/placeholder $PWD/system/bin/disable_watchdog
	mk_customize $1 > $PWD/customize.sh
	chmod 755 $PWD/customize.sh
	cp ../$dir/disable_watchdog $PWD/system/bin
	zip -rq $MOD *
	mv $MOD ..
	cd ..

	echo "Created module package for $1-bit."
}

if [ $# -eq 0 ]; then
	command echo "Usage: $0 32|64|clean"
	exit 1
fi

MOD="watchdog_disabler_$1-bit_$(date +%Y-%M-%d).zip"

case $1 in
	"32")		prepare; mkzip 32 ;;
	"64")		prepare; mkzip 64 ;;
	"clean")	clean ;;
	*)
		command echo "$0: Unknown argument: $1"
		exit 1 ;;
esac
