#!/bin/bash

#Usage:
#bash run.sh <32|64> [/path/to/system/image]

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
    srcFile="$ANDROID_BUILD_TOP/out/target/product/phhgsi_arm_ab/system.img"
else
    srcFile="$ANDROID_BUILD_TOP/out/target/product/phhgsi_arm64_ab/system.img"
fi
if [ -f "$2" ];then
    srcFile="$2"
fi

if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash run.sh <32|64> [/path/to/system.img]"
	exit 1
fi

"$origin"/simg2img "$srcFile" s.img || cp "$srcFile" s.img

rm -Rf tmp
mkdir -p d tmp
e2fsck -y -f s.img
resize2fs s.img 3500M
e2fsck -E unshare_blocks -y -f s.img
mount -o loop,rw s.img d
(
cd d

cp init.environ.rc "$origin"/tmp

find -maxdepth 1 -not -name system -not -name . -not -name .. -exec rm -Rf '{}' +
mv system/* .
rmdir system

rm -Rf system_ext/apex/com.android.vndk.v29
rm -Rf apex/*.apex
rm -Rf system_ext/apex/*.apex

sed -i \
    -e '/ro.radio.noril/d' \
    -e '/sys.usb.config/d' \
    -e '/ro.build.fingerprint/d' \
    -e '/persist.sys.theme/d' \
    -e '/ro.opengles.version/d' \
    -e '/ro.sf.lcd_density/d' \
    -e '/sys.usb.controller/d' \
    -e '/persist.dbg.volte_avail_ovr/d' \
    -e '/persist.dbg.wfc_avail_ovr/d' \
    -e '/persist.radio.multisim.config/d' \
    -e /persist.dbg.vt_avail_ovr/d \
    -e /ro.build.description/d \
    -e /ro.build.display.id/d \
    -e /ro.build.version.base_os/d \
    -e /ro.com.android.dataroaming/d \
    -e /ro.telephony.default_network/d \
    -e /ro.vendor.build.fingerprint/d \
    etc/selinux/plat_property_contexts

xattr -w security.selinux u:object_r:property_contexts_file:s0 etc/selinux/plat_property_contexts

cp "$origin"/files/apex-setup.rc etc/init/
xattr -w security.selinux u:object_r:system_file:s0 etc/init/apex-setup.rc

cp "$origin"/tmp/init.environ.rc etc/init/init-environ.rc
sed -i 's/on early-init/on init/g' etc/init/init-environ.rc
xattr -w security.selinux u:object_r:system_file:s0 etc/init/init-environ.rc

sed -i \
    -e s/MREMAP_MAYMOVE/1/g \
    etc/seccomp_policy/mediaextractor.policy \
    etc/seccomp_policy/mediacodec.policy \
    system_ext/apex/com.android.media/etc/seccomp_policy/mediaextractor.policy \
    system_ext/apex/com.android.media.swcodec/etc/seccomp_policy/mediaswcodec.policy
sed -i '0,/^@include/s/^@include.*/getdents64: 1\n&/' etc/seccomp_policy/mediaextractor.policy \
  system_ext/apex/com.android.media/etc/seccomp_policy/mediaextractor.policy
sed -i '0,/^@include/s/^@include.*/rt_sigprocmask: 1\n&/' etc/seccomp_policy/mediaextractor.policy \
  system_ext/apex/com.android.media/etc/seccomp_policy/mediaextractor.policy
sed -i '0,/^@include/s/^@include.*/rt_sigprocmask: 1\nrt_sigaction: 1\n&/' etc/seccomp_policy/mediacodec.policy

xattr -w security.selinux u:object_r:system_file:s0 system_ext/apex/com.android.media/etc/seccomp_policy/mediaextractor.policy system_ext/apex/com.android.media.swcodec/etc/seccomp_policy/mediaswcodec.policy
xattr -w security.selinux u:object_r:system_seccomp_policy_file:s0 etc/seccomp_policy/mediacodec.policy etc/seccomp_policy/mediaextractor.policy etc/seccomp_policy/mediacodec.policy

#"lmkd" user and group don't exist
#"readproc" doesn't exist, use SYS_PTRACE instead
sed -i -E \
    -e '/user lmkd/d' \
    -e 's/group .*/group root/g' \
    -e 's/capabilities (.*)/capabilities \1 SYS_PTRACE/g' \
    etc/init/lmkd.rc
xattr -w security.selinux u:object_r:system_file:s0 etc/init/lmkd.rc

sed -i -E \
    -e '/user/d' \
    -e '/group/d' \
    etc/init/credstore.rc
xattr -w security.selinux u:object_r:system_file:s0 etc/init/credstore.rc

cp system_ext/apex/com.android.media.swcodec/etc/init.rc etc/init/media-swcodec.rc
xattr -w security.selinux u:object_r:system_file:s0 etc/init/media-swcodec.rc

cp system_ext/apex/com.android.adbd/etc/init.rc etc/init/adbd.rc
xattr -w security.selinux u:object_r:system_file:s0 etc/init/adbd.rc

if [ -f system_ext/apex/com.android.adbd/lib64/libadb_protos.so ];then
cp system_ext/apex/com.android.adbd/lib64/libadb_protos.so lib64/libadb_protos.so
xattr -w security.selinux u:object_r:system_file:s0 lib64/libadb_protos.so
fi

if [ -f system_ext/apex/com.android.adbd/lib/libadb_protos.so ];then
cp system_ext/apex/com.android.adbd/lib/libadb_protos.so lib/libadb_protos.so
xattr -w security.selinux u:object_r:system_file:s0 lib/libadb_protos.so
fi

sed -i s/ro.iorapd.enable=true/ro.iorapd.enable=false/g etc/prop.default
xattr -w security.selinux u:object_r:system_file:s0 etc/prop.default

cp -R system_ext/apex/com.android.vndk.v27 system_ext/apex/com.android.vndk.v26
for i in vndkcore llndk vndkprivate vndksp;do
    mv system_ext/apex/com.android.vndk.v26/etc/${i}.libraries.27.txt system_ext/apex/com.android.vndk.v26/etc/${i}.libraries.26.txt
done
find system_ext/apex/com.android.vndk.v26 -exec xattr -w security.selinux u:object_r:system_file:s0 '{}' \;

vndk=26
archs="64 32"
if [ "$targetArch" == 32 ];then
    archs=32
fi

echo libstdc++.so >> system_ext/apex/com.android.vndk.v26/etc/vndksp.libraries.26.txt

for arch in $archs;do
    for lib in $(cd "$origin/vendor_vndk/vndk-sp-${vndk}-arm${arch}"; echo *);do
        #TODO: handle "hw"
        [ ! -f "$origin/vendor_vndk/vndk-sp-${vndk}-arm${arch}"/$lib ] && continue
        p=lib
        [ "$arch" = 64 ] && p=lib64
        cp "$origin/vendor_vndk/vndk-sp-${vndk}-arm${arch}/$lib" system_ext/apex/com.android.vndk.v${vndk}/${p}/$lib
        xattr -w security.selinux u:object_r:system_lib_file:s0 system_ext/apex/com.android.vndk.v${vndk}/${p}/$lib
        echo $lib >> system_ext/apex/com.android.vndk.v${vndk}/etc/vndksp.libraries.${vndk}.txt
    done
    sort -u system_ext/apex/com.android.vndk.v${vndk}/etc/vndksp.libraries.${vndk}.txt > v
    mv -f v system_ext/apex/com.android.vndk.v${vndk}/etc/vndksp.libraries.${vndk}.txt
    xattr -w security.selinux u:object_r:system_file:s0 system_ext/apex/com.android.vndk.v${vndk}/etc/vndksp.libraries.${vndk}.txt
done

for vndk in 28 27 26;do
    archs="64 32"
    if [ "$targetArch" == 32 ];then
        archs="32 32-binder32"
    fi
    for arch in $archs;do
        t="$origin/vendor_vndk/vndk-${vndk}-arm${arch}"
        [ -d "$t" ] && for lib in $(cd "$origin/vendor_vndk/vndk-${vndk}-arm${arch}"; echo *);do
            p=lib
            [ "$arch" = 64 ] && p=lib64
            cp "$origin/vendor_vndk/vndk-${vndk}-arm${arch}/$lib" system_ext/apex/com.android.vndk.v${vndk}/${p}/$lib
            xattr -w security.selinux u:object_r:system_lib_file:s0 system_ext/apex/com.android.vndk.v${vndk}/${p}/$lib
            echo $lib >> system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt
        done
        sort -u system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt > v
        mv -f v system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt
        xattr -w security.selinux u:object_r:system_file:s0 system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt
    done
done

sed -i 's/v27/v26/g' system_ext/apex/com.android.vndk.v26/apex_manifest.pb
xattr -w security.selinux u:object_r:system_file:s0 system_ext/apex/com.android.vndk.v26/apex_manifest.pb

sed -E -i 's/(.*allowx adbd functionfs .*0x6782)/\1 0x67e7/g' etc/selinux/plat_sepolicy.cil
xattr -w security.selinux u:object_r:sepolicy_file:s0 etc/selinux/plat_sepolicy.cil

sed -E -i 's/\+passcred//g' etc/init/logd.rc
sed -E -i 's/\+passcred//g' etc/init/lmkd.rc
sed -E -i 's/reserved_disk//g' etc/init/vold.rc
xattr -w security.selinux u:object_r:system_file:s0 etc/init/vold.rc etc/init/logd.rc etc/init/lmkd.rc

sed -E -i /rlimit/d etc/init/bpfloader.rc etc/init/cameraserver.rc
xattr -w security.selinux u:object_r:system_file:s0 etc/init/bpfloader.rc etc/init/cameraserver.rc

sed -i -e s/readproc//g -e s/reserved_disk//g etc/init/hw/init.zygote64.rc etc/init/hw/init.zygote64_32.rc etc/init/hw/init.zygote32_64.rc etc/init/hw/init.zygote32.rc
xattr -w security.selinux u:object_r:system_file:s0 etc/init/hw/init.zygote64.rc etc/init/hw/init.zygote64_32.rc etc/init/hw/init.zygote32_64.rc etc/init/hw/init.zygote32.rc

ln -s /apex/com.android.vndk.v26/lib/ lib/vndk-sp-26
xattr -sw security.selinux u:object_r:system_lib_file:s0 lib/vndk-sp-26
ln -s /apex/com.android.vndk.v26/lib/ lib/vndk-26
xattr -sw security.selinux u:object_r:system_lib_file:s0 lib/vndk-26

if [ -d lib64 ];then
ln -s /apex/com.android.vndk.v26/lib64/ lib64/vndk-sp-26
xattr -sw security.selinux u:object_r:system_lib_file:s0 lib64/vndk-sp-26
ln -s /apex/com.android.vndk.v26/lib64/ lib64/vndk-26
xattr -sw security.selinux u:object_r:system_lib_file:s0 lib64/vndk-26
fi

)
sleep 1

umount d

e2fsck -f -y s.img || true
resize2fs -M s.img
