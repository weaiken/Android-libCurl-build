#!/bin/bash


checkExitCode() {
	if [ $1 -ne 0 ]; then
		echo "Error building openssl library"
		cd $BASE_PATH
		exit $1
	fi
}
safeMakeDir() {
	if [ ! -x "$1" ]; then
		mkdir -p "$1"
	fi
}

compile() {
	cd $OPENSSL_PATH
	ABI=$1
	TOOLCHAIN=$2
	ABI_TYPE=$3

	export ANDROID_NDK_HOME=$TOOLCHAIN
	PATH=$ANDROID_NDK_HOME/bin:$PATH

	make clean
	checkExitCode $?
	# config
	./Configure  $ABI_TYPE -d --prefix=$OPENSSL_PATH/$ABI 
	checkExitCode $?
	make all
	checkExitCode $?
	make install
	checkExitCode $?

	cd $BASE_PATH
}

BASE_PATH=$(
	cd "$(dirname $0)"
	pwd
)

OPENSSL_PATH=${BASE_PATH}"/source/openssl"

TOOLCHAIN_PATH=$BASE_PATH'/toolchain/'$1
echo '---TOOLCHAIN_PATH---'$TOOLCHAIN_PATH

#1 [arm | arm64 | x86 | x86_64]  $3 [ arm-linux-androideabi ]
#3 android-arm, android-arm64, android-mips, android-mip64, android-x86 , android-x86_64

if [[ $1 == 'arm' ]]; then
	#statements
	compile $1 $TOOLCHAIN_PATH android-arm 
elif [[ $1 == 'arm64' ]]; then
	#statements
	# echo 1
	compile $1 $TOOLCHAIN_PATH android-arm64
elif [[ $1 == 'x86' ]]; then
	#statements
	# echo 1
	compile $1 $TOOLCHAIN_PATH android-x86  
elif [[ $1 == 'x86_64' ]]; then
	#statements
	# echo 1
	compile $1 $TOOLCHAIN_PATH android-x86_64
fi


