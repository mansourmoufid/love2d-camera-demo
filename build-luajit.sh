#!/bin/sh
set -e
set -x
dir="$(cd $(dirname $0) && pwd)"
lib="${dir}/lib"
export HOST_CC="clang"
export HOST_LD="clang"
export HOST_SYS="$(uname -s)"
case "${ABI}" in
    "armeabi-v7a")
        TARGET_CFLAGS="-m32"
        TARGET_LDFLAGS="-m32"
        ;;
    "arm64-v8a")
        TARGET_CFLAGS="-m64"
        TARGET_LDFLAGS="-m64"
        ;;
    *)
        ;;
esac
export HOST_CFLAGS
export HOST_LDFLAGS
export TARGET_CFLAGS
export TARGET_LDFLAGS
export TARGET_SYS="Linux"
# test -f "${dir}/LuaJIT-2.1.zip"
# test -d "${dir}/LuaJIT-2.1" || unzip -d "${dir}" "${dir}/LuaJIT-2.1.zip"
(
    # patch -d "${dir}/LuaJIT-2.1" -f -p0 < "${dir}/patches/patch-LuaJIT-2.1"
    patch -d "${dir}/LuaJIT" -f -p0 < "${dir}/patches/patch-LuaJIT-2.1"
) || true
# make -C "${dir}/LuaJIT-${VERSION}" clean
# make -C "${dir}/LuaJIT-${VERSION}"
make -C "${dir}/LuaJIT" clean
make -C "${dir}/LuaJIT"
cp -f "${dir}/LuaJIT/src/libluajit.a" "${DESTDIR}${LIBDIR}/"
