#!/bin/bash
set -x

if [ $# -ne 1 ]; then
    echo $0: usage: cross_compile_library.sh ARCH 
    echo "example: usage: cross_compile_library.sh [ arm-linux | arm-linux-gnueabihf | arm-linux-gnueabi ]"
    exit 1
fi

export PATH="$1/bin:$PATH"
#export C_INCLUDE_PATH="$1/include"


tool_chain_path=$1

# linux architecture 
item=`ls $tool_chain_path/bin | grep gcc`
IFS=' ' read -ra ADDR <<< "$item"
item="${ADDR[0]}"
ARCH=`echo $item | sed -e 's/-gcc.*//g'`

# ======== libxml with static build ========
export ARCH=$ARCH
if [ "$ARCH" == "" ]; then
	export AR=ar
	export AS=as
	export LD=ld
	export RANLIB=ranlib
	export CC=gcc
	export NM=nm
	./autogen.sh --prefix=$tool_chain_path --without-python --without-iconv --without-zlib --without-lzma
else
	export AR=${ARCH}-ar
	export AS=${ARCH}-as
	export LD=${ARCH}-ld
	export RANLIB=${ARCH}-ranlib
	export CC=${ARCH}-gcc
	export NM=${ARCH}-nm
	./autogen.sh --host=${ARCH} --prefix=$tool_chain_path ARCH=${ARCH} --without-python --without-iconv --without-zlib --without-lzma
fi

make clean
make
sudo "PATH=$PATH" make install
