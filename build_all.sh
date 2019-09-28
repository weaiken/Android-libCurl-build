#!/bin/bash

export NDK_ROOT="$NDK_ROOT"
if [ -z "$NDK_ROOT" ]; then
	echo "Please set your NDK_ROOT environment variable first"
	exit 1
fi



if [ ! -d "./toolchain" ]; then
	mkdir toolchain
fi

APP_ABI=(
    'arm'
    'arm64'
    'x86'
    'x86_64'
    # 'mips'
    # 'mips64'
)

toolchains=(
    'arm-linux-androideabi-4.9'
    'aarch64-linux-android-4.9'
    'x86-4.9'
    'x86_64-4.9'
    # 'mipsel-linux-android-4.9'
    # 'mips64el-linux-android-4.9'
)

toolchains_build=(
	'arm-linux-androideabi'
	'aarch64-linux-android'
	'i686-linux-android'
	'x86_64-linux-android'
	 # 'mips-linux-android'
    # 'mips64-linux-android'
)


num=${#APP_ABI[@]}
for ((i=0;i<$num;i++))
do
	if [ ! -d "./toolchain/${APP_ABI[i]}" ]; then
	$NDK_ROOT/build/tools/make-standalone-toolchain.sh --arch=${APP_ABI[i]} --install-dir=./toolchain/${APP_ABI[i]}  --toolchain=${toolchains[i]} --force
	fi
done


build_for_zlib(){
	chmod +x ./build_zlib.sh 
	for ((i=0;i<$num;i++))
	do
			sh ./build_zlib.sh  ${APP_ABI[i]} ${toolchains[i]} ${toolchains_build[i]}		
	done
}

# echo '----1----'


build_for_zlib



# sh build_openssl.sh
