#!/bin/bash


checkExitCode() {
	if [ $1 -ne 0 ]; then
		echo "Error building zlib library"
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
	cd $CRUL_PATH
	ABI=$1
	TOOLCHAIN=$2
	TOOL=$3
	ARCH_FLAGS=$4

	# echo '------ABI------'$ABI
	# echo '------TOOLCHAIN------'$TOOLCHAIN
	# echo '------TOOL------'$TOOL
	# echo '------ARCH_FLAGS------'$ARCH_FLAGS

	export TOOLCHAIN=$TOOLCHAIN
	
	# export AR=$TOOLCHAIN/bin/llvm-ar
	echo 'AR---'$AR
    export PKG_CONFIG_LIBDIR=$TOOLCHAIN/lib/pkgconfig
    export CROSS_SYSROOT=$TOOLCHAIN/sysroot
    # export PATH=$TOOLCHAIN/bin:$PATH
    export CC=$TOOLCHAIN/bin/${TOOL}-clang
    export CXX=$TOOLCHAIN/bin/${TOOL}-clang++
    echo 'CXX---'$CXX
    export LINK=${CXX}
    export LD=$TOOLCHAIN/bin/${TOOL}-ld

    export AS=$TOOLCHAIN/bin/${TOOL}-clang
    export RANLIB=$TOOLCHAIN/bin/${TOOL}-ranlib
    export STRIP=$TOOLCHAIN/bin/${TOOL}-strip
    export ARCH_FLAGS=$ARCH_FLAGS
    CFLAGS="${ARCH_FLAGS} -fPIE -fPIC -ffunction-sections -funwind-tables -fno-stack-protector -fno-strict-aliasing"

    export CXXFLAGS="${CFLAGS} -frtti -fexceptions -fdata-sections -ffunction-sections -fvisibility=hidden -fvisibility-inlines-hidden -Wall -Wextra -Wno-unused-function -Wno-narrowing"    
    export LDFLAGS="-pie"
	export CFLAGS="-I$TOOLCHAIN/sysroot/usr/include --sysroot=$TOOLCHAIN/sysroot  $CFLAGS"
	export AR=$TOOLCHAIN/bin/${TOOL}-ar
	# zlib configure
	export CROSS_PREFIX="$TOOLCHAIN/arm-linux-androideabi-"
	


	# config
	safeMakeDir $CRUL_PATH/$ABI
	# echo '---'$BUILD_PATH/zlib/$ABI
	 # --prefix=$PREFIX \
  #   --enable-static \
  #   --enable-shared \
  #   --host=$TOOLNAME_BASE

	./configure --prefix=$CRUL_PATH/$ABI --enable-static --enable-shared  --host=$TOOL \
	--with-ssl=$BASE_PATH/source/openssl/$ABI 
	# checkExitCode $?
	# # make
	make -j4
	# checkExitCode $?
	# install
	make install
	# checkExitCode $?
	make clean
	# checkExitCode $?
	cd $BASE_PATH
}

BASE_PATH=$(
	cd "$(dirname $0)"
	pwd
)

CRUL_PATH=${BASE_PATH}"/source/curl"

TOOLCHAIN_PATH=$BASE_PATH'/toolchain/'$1
echo '---TOOLCHAIN_PATH---'$TOOLCHAIN_PATH

if [[ $1 == 'arm' ]]; then
	#statements
	compile $1 $TOOLCHAIN_PATH $3 "-march=armv7-a -mfloat-abi=softfp -mfpu=neon"
elif [[ $1 == 'arm64' ]]; then
	#statements
	compile $1 $TOOLCHAIN_PATH $3 "-march=armv8-a"
elif [[ $1 == 'x86' ]]; then
	#statements
	compile $1 $TOOLCHAIN_PATH $3 "-march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32"
elif [[ $1 == 'x86_64' ]]; then
	#statements
	compile $1 $TOOLCHAIN_PATH $3 "-march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel"
fi


