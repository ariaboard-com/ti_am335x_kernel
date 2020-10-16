#!/bin/sh

export ARCH=arm
export CROSS_COMPILE="arm-linux-gnueabihf-"

if [ x"${CORES}" = x"" ]; then
    CORES="2"
fi

if [ x"$1" = x"mrprober" ]; then
   rm -rf build/test-platform-mk2
fi

if [ ! -d "build/test-platform-mk2" ]; then
    mkdir -p build/test-platform-mk2
fi

if [ ! -f "build/test-platform-mk2/.config" ]; then
    cp arch/arm/configs/am335x_evm_novotech_test_platform_mk2_defconfig build/test-platform-mk2/.config
fi

rm -rf deploy/test-platform-mk2
mkdir -p deploy/test-platform-mk2

make O=build/test-platform-mk2 zImage -j${CORES}
make O=build/test-platform-mk2 am335x-evm-test-platform-mk2.dtb
make O=build/test-platform-mk2 am335x-evm-test-legacy-mk2.dtb
make O=build/test-platform-mk2 am335x-evm-test-platform-dual-emmc.dtb
make O=build/test-platform-mk2 modules firmware -j${CORES}

mkdir -p deploy/test-platform-mk2/modules/lib/firmware
mkdir -p deploy/test-platform-mk2/headers/usr/src/linux

make O=build/test-platform-mk2 modules_install INSTALL_MOD_PATH=$(pwd)/deploy/test-platform-mk2/modules
make O=build/test-platform-mk2 headers_install INSTALL_HDR_PATH=$(pwd)/deploy/test-platform-mk2/headers/usr/src/linux

cat build/test-platform-mk2/arch/arm/boot/zImage build/test-platform-mk2/arch/arm/boot/dts/am335x-evm-test-platform-mk2.dtb > deploy/test-platform-mk2/zImage
cat build/test-platform-mk2/arch/arm/boot/zImage build/test-platform-mk2/arch/arm/boot/dts/am335x-evm-test-legacy-mk2.dtb > deploy/test-platform-mk2/zImage-legacy
cat build/test-platform-mk2/arch/arm/boot/zImage build/test-platform-mk2/arch/arm/boot/dts/am335x-evm-test-platform-dual-emmc.dtb > deploy/test-platform-mk2/zImage-dual-emmc

cd deploy/test-platform-mk2/modules
tar -czf ../modules.tar.gz lib
cd ../headers
tar -czf ../headers.tar.gz usr
cd ../../..
