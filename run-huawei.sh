#!/bin/bash

#Usage:
#sudo bash run-huawei.sh [/path/to/system.img]

#cleanups
umount d

set -ex

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"


targetArch=64
srcFile="$1"


if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash run-huawei.sh [/path/to/system.img]"
	exit 1
fi

"$origin"/simg2img "$srcFile" s-iceows.img || cp "$srcFile" s-iceows.img

rm -Rf tmp
mkdir -p d tmp
e2fsck -y -f s-iceows.img
resize2fs s-iceows.img 3500M
e2fsck -E unshare_blocks -y -f s-iceows.img
mount -o loop,rw s-iceows.img d
(
	cd d
	
	# rw-system custom for Huawei device
	cp "$origin/files-patch/system/bin/rw-system.sh" bin/rw-system.sh
	xattr -w security.selinux u:object_r:phhsu_exec:s0 bin/rw-system.sh

	# ?
	cp "$origin/files-patch/system/etc/init/android.system.suspend@1.0-service.rc" etc/init/android.system.suspend@1.0-service.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/android.system.suspend@1.0-service.rc

	# offline charging
	for img in $(cd "$origin/files-patch/system/etc/charger/1080x1920"; echo *);do
		cp "$origin/files-patch/system/etc/charger/1080x1920/$img" etc/charger/1080x1920/$img
		xattr -w security.selinux u:object_r:system_file:s0 etc/charger/1080x1920/$img
	done
	for img in $(cd "$origin/files-patch/system/etc/charger/1080x2160"; echo *);do
		cp "$origin/files-patch/system/etc/charger/1080x2160/$img" etc/charger/1080x2160/$img
		xattr -w security.selinux u:object_r:system_file:s0 etc/charger/1080x2160/$img
	done
	
	# NFC 
	cp "$origin/files-patch/system/etc/libnfc-brcm.conf" etc/libnfc-brcm.conf
	xattr -w security.selinux u:object_r:system_file:s0  etc/libnfc-brcm.conf
	cp "$origin/files-patch/system/etc/libnfc-nci.conf" etc/libnfc-nci.conf
	xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nci.conf
	cp "$origin/files-patch/system/etc/libnfc-nxp.conf" etc/libnfc-nxp.conf
	xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp.conf
	cp "$origin/files-patch/system/etc/libnfc-nxp_RF.conf" etc/libnfc-nxp_RF.conf
	xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp_RF.conf
	
	cp "$origin/files-patch/system/etc/libnfc-brcm.conf" product/etc/libnfc-brcm.conf
	xattr -w security.selinux u:object_r:system_file:s0  product/etc/libnfc-brcm.conf
	cp "$origin/files-patch/system/etc/libnfc-nci.conf" product/etc/libnfc-nci.conf
	xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nci.conf
	cp "$origin/files-patch/system/etc/libnfc-nxp.conf" product/etc/libnfc-nxp.conf
	xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp.conf
	cp "$origin/files-patch/system/etc/libnfc-nxp_RF.conf" product/etc/libnfc-nxp_RF.conf
	xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp_RF.conf	
	
	# NFC permission
	cp "$origin/files-patch/system/etc/permissions/android.hardware.nfc.hce.xml" etc/permissions/android.hardware.nfc.hce.xml
	xattr -w security.selinux u:object_r:system_file:s0 etc/permissions/android.hardware.nfc.hce.xml 
	cp "$origin/files-patch/system/etc/permissions/android.hardware.nfc.hcef.xml" etc/permissions/android.hardware.nfc.hcef.xml
	xattr -w security.selinux u:object_r:system_file:s0 etc/permissions/android.hardware.nfc.hcef.xml
	cp "$origin/files-patch/system/etc/permissions/android.hardware.nfc.xml" etc/permissions/android.hardware.nfc.xml
	xattr -w security.selinux u:object_r:system_file:s0 etc/permissions/android.hardware.nfc.xml
	cp "$origin/files-patch/system/etc/permissions/com.android.nfc_extras.xml" etc/permissions/com.android.nfc_extras.xml
	xattr -w security.selinux u:object_r:system_file:s0 etc/permissions/com.android.nfc_extras.xml

	# NFC product permission
	cp "$origin/files-patch/system/etc/permissions/android.hardware.nfc.hce.xml" product/etc/permissions/android.hardware.nfc.hce.xml
	xattr -w security.selinux u:object_r:system_file:s0 product/etc/permissions/android.hardware.nfc.hce.xml 
	cp "$origin/files-patch/system/etc/permissions/android.hardware.nfc.hcef.xml" product/etc/permissions/android.hardware.nfc.hcef.xml
	xattr -w security.selinux u:object_r:system_file:s0 product/etc/permissions/android.hardware.nfc.hcef.xml
	cp "$origin/files-patch/system/etc/permissions/android.hardware.nfc.xml" product/etc/permissions/android.hardware.nfc.xml
	xattr -w security.selinux u:object_r:system_file:s0 product/etc/permissions/android.hardware.nfc.xml
	cp "$origin/files-patch/system/etc/permissions/com.android.nfc_extras.xml" product/etc/permissions/com.android.nfc_extras.xml
	xattr -w security.selinux u:object_r:system_file:s0 product/etc/permissions/com.android.nfc_extras.xml
	

	# Medias permission
	cp "$origin/files-patch/system/etc/permissions/platform.xml" etc/permissions/platform.xml 
	xattr -w security.selinux u:object_r:system_file:s0 etc/permissions/platform.xml 
	
	# Codec bluetooth 32 bits
	cp "$origin/files-patch/system/lib/libaptX_encoder.so" lib/libaptX_encoder.so
	xattr -w security.selinux u:object_r:system_lib_file:s0 lib/libaptX_encoder.so
	cp "$origin/files-patch/system/lib/libaptXHD_encoder.so" lib/libaptXHD_encoder.so
	xattr -w security.selinux u:object_r:system_lib_file:s0 lib/libaptXHD_encoder.so
	
	# Codec bluetooth 64 bits
	cp "$origin/files-patch/system/lib64/libaptX_encoder.so" lib64/libaptX_encoder.so
	xattr -w security.selinux u:object_r:system_lib_file:s0 lib64/libaptX_encoder.so
	cp "$origin/files-patch/system/lib64/libaptXHD_encoder.so" lib64/libaptXHD_encoder.so
	xattr -w security.selinux u:object_r:system_lib_file:s0 lib64/libaptXHD_encoder.so
		
	# Fingerprint 
	cp "$origin/files-patch/system/phh/huawei/fingerprint.kl" phh/huawei/fingerprint.kl
	xattr -w security.selinux u:object_r:system_file:s0  phh/huawei/fingerprint.kl
	
	# Media Extractor policy (sas-creator run.sh add this two values)
	# getdents64: 1
	# rt_sigprocmask: 1	
	
	# Fix app crashes
	echo "(allow appdomain vendor_file (file (read getattr execute open)))" >> etc/selinux/plat_sepolicy.cil

	# Fix instagram denied 
    	echo "(allow untrusted_app dalvikcache_data_file (file (execmod)))" >> etc/selinux/plat_sepolicy.cil
    	echo "(allow untrusted_app proc_zoneinfo (file (read open)))" >> etc/selinux/plat_sepolicy.cil

	# Fix Google GMS denied 
    	echo "(allow gmscore_app splash2_data_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
    	echo "(allow gmscore_app teecd_data_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
    	echo "(allow gmscore_app modem_fw_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
    	echo "(allow gmscore_app modem_nv_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	# Dirty hack to show build properties
	# To get productid : sed -nE 's/.*productid=([0-9xa-f]*).*/\1/p' /proc/cmdline
	#MODEL=$( cat /sys/firmware/devicetree/base/boardinfo/normal_product_name | tr -d '\n')
	MODEL="PRA-LX1"

	echo "#" >> etc/prop.default
    	echo "## Adding build props" >> etc/prop.default
    	echo "#" >> etc/prop.default
    	cat build.prop | grep "." >> etc/prop.default
    
	echo "#" >> etc/prop.default
	echo "## Adding hi6250 props" >> etc/prop.default
    	echo "#" >> etc/prop.default
    	sed -i "/ro.product.model/d" etc/prop.default
    	sed -i "/ro.product.system.model/d" etc/prop.default
    	echo "ro.product.manufacturer=HUAWEI" >> etc/prop.default
    	echo "ro.product.system.model=hi6250" >> etc/prop.default
    	echo "ro.product.model=$MODEL" >> etc/prop.default
    	
    	LINEAGEV="LineageOS 18.1 LeaOS (CGMod)"
    	sed -i "/ro.lineage.version/d" etc/prop.default;
    	sed -i "/ro.lineage.display.version/d" etc/prop.default;
    	sed -i "/ro.modversion/d" etc/prop.default;
    	echo "ro.lineage.version=$LINEAGEV" >> etc/prop.default;
    	echo "ro.lineage.display.version=$LINEAGEV" >> etc/prop.default;
    	echo "ro.modversion=$LINEAGEV" >> etc/prop.default;
	 
	echo "persist.sys.usb.config=hisuite,mtp,mass_storage" >> etc/prop.default
    	echo "sys.usb.config=mtp" >> etc/prop.default
	echo "sys.usb.configfs=1" >> etc/prop.default
	echo "sys.usb.controller=hisi-usb-otg" >> etc/prop.default
	echo "sys.usb.ffs.aio_compat=true" >> etc/prop.default
   	echo "sys.usb.ffs.ready=0" >> etc/prop.default
	echo "sys.usb.ffs_hdb.ready=0" >> etc/prop.default
   	echo "sys.usb.state=mtp" >> etc/prop.default
   	echo "debug.sf.latch_unsignaled=1" >> build.prop
	echo "ro.surface_flinger.running_without_sync_framework=true" >> build.prop;
	echo "persist.sys.sf.native_mode=1" >> etc/prop.default
	echo "persist.sys.sf.color_mode=1.0" >> etc/prop.default
	echo "persist.sys.sf.color_saturation=1.1" >> etc/prop.default

	# LMK - for Android Kernel that support it
	echo "ro.lmk.debug=true" >> etc/prop.default
	
	# Enable wireless display (Cast/Miracast)
	echo "persist.debug.wfd.enable=1" >> etc/prop.default

	# Add type and mapping for displayengine-hal-1.0
	echo "(typeattributeset hwservice_manager_type (displayengine_hwservice))" >> etc/selinux/plat_sepolicy.cil
	echo "(type displayengine_hwservice)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r displayengine_hwservice)" >> etc/selinux/plat_sepolicy.cil
	echo "(typeattributeset displayengine_hwservice_26_0 (displayengine_hwservice))" >> etc/selinux/mapping/26.0.cil

	# Add allow  for displayengine-hal-1.0
	# echo "(allow hal_displayengine_default displayengine_hwservice (hwservice_manager (add find)))" >> /vendor/etc/selinux/nonplat_sepolicy.cil

	# Add allow vendor.lineage.livedisplay
	echo "(allow system_server default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server default_android_service (service_manager (add)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server vendor_file (file (execute getattr map open read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_app default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil

		
	# Check if FUSE is enabled in build.prop file
	if grep -qs 'ro.sys.sdcardfs=true' build.prop; then
		sed -i 's/^ro.sys.sdcardfs=true/ro.sys.sdcardfs=false/' build.prop
	fi
	if grep -qs 'persist.esdfs_sdcard=true' build.prop; then
		sed -i 's/^persist.esdfs_sdcard=false' build.prop
	fi
	if grep -qs 'persist.sys.sdcardfs' build.prop; then
		sed -i 's/^persist.sys.sdcardfs=true/persist.sys.sdcardfs=false/' build.prop
	fi
	
	
)
sleep 1

umount d

e2fsck -f -y s-iceows.img || true
resize2fs -M s-iceows.img

