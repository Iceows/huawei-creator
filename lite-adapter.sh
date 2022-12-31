#!/bin/bash

#Usage:
#bash lite-adapter.sh <32|64> [/path/to/system/image]

#cleanups
umount d

set -ex

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"

[ ! -d vendor_vndk ] && git clone https://github.com/phhusson/vendor_vndk -b android-10.0

targetArch=64
[ "$1" == 32 ] && targetArch=32

[ -z "$ANDROID_BUILD_TOP" ] && ANDROID_BUILD_TOP=/build2/AOSP-11.0/
if [ "$targetArch" == 32 ];then
    srcFile="$ANDROID_BUILD_TOP/out/target/product/tdgsi_a64_ab/system.img"
else
    srcFile="$ANDROID_BUILD_TOP/out/target/product/tdgsi_arm64_ab/system.img"
fi
if [ -f "$2" ];then
    srcFile="$2"
fi

if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash lite-adapter.sh <32|64> [/path/to/system.img]"
	exit 1
fi

simg2img "$srcFile" s-vndklite.img  || cp "$srcFile" s-vndklite.img 

rm -Rf tmp
mkdir -p d tmp
e2fsck -y -f s-vndklite.img 
resize2fs s-vndklite.img  3500M
e2fsck -E unshare_blocks -y -f s-vndklite.img 
mount -o loop,rw s-vndklite.img d
(
cd d
find -name \*.capex -or -name \*.apex -type f -delete
for vndk in 28 29;do
    for arch in 32 64;do
        d="$origin/vendor_vndk/vndk-${vndk}-arm${arch}"
        [ ! -d "$d" ] && continue
        p=lib
        [ "$arch" = 64 ] && p=lib64
        [ ! -d system/system_ext/apex/com.android.vndk.v${vndk}/${p}/ ] && continue
        for lib in $(cd "$d"; echo *);do
            cp "$origin/vendor_vndk/vndk-${vndk}-arm${arch}/$lib" system/system_ext/apex/com.android.vndk.v${vndk}/${p}/$lib
            xattr -w security.selinux u:object_r:system_lib_file:s0 system/system_ext/apex/com.android.vndk.v${vndk}/${p}/$lib
            echo $lib >> system/system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt
        done
        sort -u system/system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt > v
        mv -f v system/system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt
        xattr -w security.selinux u:object_r:system_file:s0 system/system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt

        grep -v -e libgui.so -e libft2.so system/system_ext/apex/com.android.vndk.v${vndk}/etc/vndkprivate.libraries.${vndk}.txt > v
        mv -f v system/system_ext/apex/com.android.vndk.v${vndk}/etc/vndkprivate.libraries.${vndk}.txt
        xattr -w security.selinux u:object_r:system_file:s0 system/system_ext/apex/com.android.vndk.v${vndk}/etc/vndkprivate.libraries.${vndk}.txt
    done
done
mkdir -p firmware/radio
xattr -w security.selinux u:object_r:firmware_file:s0 firmware
xattr -w security.selinux u:object_r:firmware_file:s0 firmware/radio
)
sleep 1

umount d

e2fsck -f -y s-vndklite.img  || true
resize2fs -M s-vndklite.img 

