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
	cd $NGHTTP2_PATH
	ABI=$1
	TOOLCHAIN=$2
	TOOL=$3
	ARCH_FLAGS=$4

	# echo '------ABI------'$ABI
	# echo '------TOOLCHAIN------'$TOOLCHAIN
	# echo '------TOOL------'$TOOL
	# echo '------ARCH_FLAGS------'$ARCH_FLAGS

	PREFIX=$TOOLCHAIN/sysroot/usr/local

	export TOOLCHAIN=$TOOLCHAIN
	
    export PKG_CONFIG_LIBDIR=$TOOLCHAIN/lib/pkgconfig
    export CROSS_SYSROOT=$TOOLCHAIN/sysroot
    # export PATH=$TOOLCHAIN/bin:$PATH
    export CC=$TOOLCHAIN/bin/${TOOL}-clang
    export CXX=$TOOLCHAIN/bin/${TOOL}-clang++
    export LINK=${CXX}
    export LD=$TOOLCHAIN/bin/${TOOL}-ld

    PATH=$TOOLCHAIN/bin:$PATH

    export AS=$TOOLCHAIN/bin/${TOOL}-clang
    export RANLIB=$TOOLCHAIN/bin/${TOOL}-ranlib
    export STRIP=$TOOLCHAIN/bin/${TOOL}-strip
    export ARCH_FLAGS=$ARCH_FLAGS
    CFLAGS="${ARCH_FLAGS} -fPIE -fPIC -ffunction-sections -funwind-tables -fno-stack-protector -fno-strict-aliasing"

    export CXXFLAGS="${CFLAGS} -frtti -fexceptions -fdata-sections -ffunction-sections -fvisibility=hidden -fvisibility-inlines-hidden -Wall -Wextra -Wno-unused-function -Wno-narrowing"    
    export LDFLAGS="-fPIE -pie"
	export CFLAGS="-I$TOOLCHAIN/sysroot/usr/include --sysroot=$TOOLCHAIN/sysroot  $CFLAGS"
	export AR=$TOOLCHAIN/bin/${TOOL}-ar
	

	# config
	safeMakeDir $NGHTTP2_PATH/$ABI
	# echo '---'$BUILD_PATH/zlib/$ABI

	./configure \
	--prefix=$NGHTTP2_PATH/$ABI  \
    --disable-shared \
    --host=$TOOL \
    --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
    --with-xml-prefix="$PREFIX" \
    --without-libxml2 \
    --disable-python-bindings \
    --disable-examples \
    --disable-threads 
    # CC="$TOOLCHAIN"/bin/arm-linux-androideabi-clang \
    # CXX="$TOOLCHAIN"/bin/arm-linux-androideabi-clang++ \
    # CPPFLAGS="-fPIE -I$PREFIX/include" \
    # PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig" \
    # LDFLAGS="-fPIE -pie -L$PREFIX/lib"


	checkExitCode $?
	# clean
	make -j4
	checkExitCode $?
	# install
	make install
	checkExitCode $?
	make clean
	checkExitCode $?
	cd $BASE_PATH
}

BASE_PATH=$(
	cd "$(dirname $0)"
	pwd
)

NGHTTP2_PATH=${BASE_PATH}"/source/nghttp2"

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




