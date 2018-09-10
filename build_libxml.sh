#!/bin/bash
set -x

if [ "$#" -ne 2 ]; then
    echo "Usage: ./build_libxml.sh tool_chain_path install_path!"
    echo "Example: ./build_libxml.sh /usr/local/arm-linux /Desktop/eric/logger/build/moxa-ia240/libxml"
    exit
fi

export PATH="$1/bin:$PATH"
export CPATH="$1/include"

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
	./autogen.sh --prefix=$2 --without-python --without-iconv --without-zlib --without-lzma
else
	export AR=${ARCH}-ar
	export AS=${ARCH}-as
	export LD=${ARCH}-ld
	export RANLIB=${ARCH}-ranlib
	export CC=${ARCH}-gcc
	export NM=${ARCH}-nm
	./autogen.sh --host=${ARCH} --prefix=$2 ARCH=${ARCH} --without-python --without-iconv --without-zlib --without-lzma
fi

make clean
make
make install
rm -rf $2/lib/*.so
