#!/bin/bash

#Usage:
#sudo bash run-huawei-aonly.sh  [/path/to/system.img] [version] [device]

#cleanups
umount d

set -ex

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"

[ ! -d vendor_vndk ] && git clone https://github.com/phhusson/vendor_vndk -b android-10.0

targetArch=64
srcFile="$1"
versionNumber="$2"
model="$3"

if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash run-huawei-ab.sh [/path/to/system.img] [version] [model] "
	echo "version=LeaOS, LeaOS-PHH , crDRom v316 - Mod Iceows , LiR v316 - Mod Iceows , Caos v316 - Mod Iceows"
	echo "model=ANE-LX1"
	exit 1
fi

"$origin"/simg2img "$srcFile" s-ab-raw.img || cp "$srcFile" s-ab-raw.img

rm -Rf tmp
mkdir -p d tmp
e2fsck -y -f s-ab-raw.img
resize2fs s-ab-raw.img 4500M
e2fsck -E unshare_blocks -y -f s-ab-raw.img
mount -o loop,rw s-ab-raw.img d
(
	cd d/system
		
		
	#---------------------------------Setting properties -------------------------------------------------
	
	# Dirty hack to show build properties
	# To get productid : sed -nE 's/.*productid=([0-9xa-f]*).*/\1/p' /proc/cmdline
	#MODEL=$( cat /sys/firmware/devicetree/base/boardinfo/normal_product_name | tr -d '\n')

	
	# build - change type to user
	sed -i "/ro.system.build.type/d" build.prop 
	sed -i "/ro.build.type/d" build.prop 	
	echo "ro.system.build.type=user" >> build.prop
	echo "ro.build.type=user" >> build.prop

	echo "#" >> etc/prop.default
	echo "## Adding build props" >> etc/prop.default
	echo "#" >> etc/prop.default
	cat build.prop | grep "." >> etc/prop.default

	echo "#" >> etc/prop.default
	echo "## Adding hi6250 props" >> etc/prop.default
	echo "#" >> etc/prop.default

	# change product
	sed -i "/ro.product.model/d" etc/prop.default
	sed -i "/ro.product.system.model/d" etc/prop.default
	echo "ro.product.manufacturer=HUAWEI" >> etc/prop.default
	echo "ro.product.system.model=hi6250" >> etc/prop.default
	echo "ro.product.model=$model" >> etc/prop.default

	# set default sound
	echo "ro.config.ringtone=Ring_Synth_04.ogg" >> etc/prop.default
	echo "ro.config.notification_sound=OnTheHunt.ogg">> etc/prop.default
	echo "ro.config.alarm_alert=Alarm_Classic.ogg">> etc/prop.default

	# set lineage version number for lineage build
	sed -i "/ro.lineage.version/d" etc/prop.default;
	sed -i "/ro.lineage.display.version/d" etc/prop.default;
	sed -i "/ro.modversion/d" etc/prop.default;
	echo "ro.lineage.version=$versionNumber" >> etc/prop.default;
	echo "ro.lineage.display.version=$versionNumber" >> etc/prop.default;
	echo "ro.modversion=$versionNumber" >> etc/prop.default;


	# Force FUSE usage for emulated storage
	# Force sdcardfs usage for emulated storage (Huawei)
	# Enabled sdcardfs, disabled esdfs_sdcard
	if grep -qs 'persist.sys.sdcardfs' etc/prop.default; then
		sed -i 's/^persist.sys.sdcardfs=force_off/persist.sys.sdcardfs=force_on/' etc/prop.default
	fi
	
	# Fallback device
	if grep -qs 'ro.sys.sdcardfs' etc/prop.default; then
		sed -i 's/^ro.sys.sdcardfs=false/ro.sys.sdcardfs=true/' etc/prop.default
		sed -i 's/^ro.sys.sdcardfs=0/ro.sys.sdcardfs=true/' etc/prop.default
	fi

	if grep -qs 'persist.esdfs_sdcard=true' etc/prop.default; then
		sed -i 's/^persist.esdfs_sdcard=false' etc/prop.default
	fi
	 
	 
	# LMK - for Android Kernel that support it - e
	echo "ro.lmk.debug=true" >> etc/prop.default
	
	# Enable wireless display (Cast/Miracast)
	echo "persist.debug.wfd.enable=1" >> etc/prop.default
	
	# Set default phh properties
	echo "persist.sys.phh.autorun=false" >> etc/prop.default
	echo "persist.sys.phh.backlight.scale=0" >> etc/prop.default
	echo "persist.sys.phh.camera.force_timestampsource=-1" >> etc/prop.default
	echo "persist.sys.phh.disable_a2dp_offload=false" >> etc/prop.default
	echo "persist.sys.phh.disable_audio_effects=0" >> etc/prop.default
	echo "persist.sys.phh.disable_buttons_light=false" >> etc/prop.default
	echo "persist.sys.phh.include_all_cameras=false" >> etc/prop.default
	echo "persist.sys.phh.linear_brightness=false" >> etc/prop.default
	echo "persist.sys.phh.mainkeys=0" >> etc/prop.default
	echo "persist.sys.phh.no_cutout=false" >> etc/prop.default
	echo "persist.sys.phh.no_present_or_validate=true" >> etc/prop.default
	echo "persist.sys.phh.no_stock_apps=false" >> etc/prop.default
	echo "persist.sys.phh.nolog=false" >> etc/prop.default
	echo "persist.sys.phh.pixelprops=false" >> etc/prop.default
	echo "persist.sys.phh.remote=false" >> etc/prop.default
	echo "persist.sys.phh.restart_ril=false" >> etc/prop.default
	echo "persist.sys.phh.root=false" >> etc/prop.default
	echo "persist.sys.phh.safetynet=false" >> etc/prop.default


	# From device/huawei/anne/system.prop
	# Disable debugging strict mode toasts
	echo "persist.sys.strictmode.disable=true" >> etc/prop.default
	echo "persist.sys.max_profiles=10" >> etc/prop.default
	echo "persist.sys.overlay.nightmode=true" >> etc/prop.default
	echo "fw.max_users=10" >> etc/prop.default	


	# DarkJoker ANE-LX1 special prop
	# Audio
	echo "audio.deep_buffer.media=true" >> etc/prop.default
	echo "ro.config.media_vol_steps=25" >> etc/prop.default
	echo "ro.config.vc_call_vol_steps=7" >> etc/prop.default

	# Display
	echo "ro.surface_flinger.running_without_sync_framework=true" >> etc/prop.default

	# Graphics
	echo "debug.egl.hw=1" >> etc/prop.default
	echo "debug.egl.profiler=1" >> etc/prop.default
	echo "debug.hwui.use_buffer_age=false" >> etc/prop.default
	echo "debug.performance.tuning=1" >> etc/prop.default
	echo "debug.sf.enable_hwc_vds=0" >> etc/prop.default
	echo "debug.sf.hw=1" >> etc/prop.default
	echo "hwui.disable_vsync=true" >> etc/prop.default
	echo "ro.config.enable.hw_accel=true" >> etc/prop.default
	echo "video.accelerate.hw=1" >> etc/prop.default
	echo "debug.sf.latch_unsignaled=1" >> etc/prop.default
	echo "ro.surface_flinger.max_frame_buffer_acquired_buffers=3" >> etc/prop.default
	echo "debug.cpurend.vsync=false" >> etc/prop.default
	echo "ro.hardware.egl=mali" >> etc/prop.default
	echo "ro.hardware.vulkan=mali" >> etc/prop.default

	# Usb
	echo "persist.sys.usb.config=hisuite,mtp,mass_storage" >> etc/prop.default 
	echo "sys.usb.config=mtp" >> etc/prop.default
	echo "sys.usb.configfs=1" >> etc/prop.default
	echo "sys.usb.controller=hisi-usb-otg" >> etc/prop.default
	echo "sys.usb.ffs.aio_compat=true" >> etc/prop.default
	echo "sys.usb.ffs.ready=0" >> etc/prop.default
	echo "sys.usb.ffs_hdb.ready=0" >> etc/prop.default
	echo "sys.usb.state=mtp,adb" >> etc/prop.default
	

	#-----------------------------File copy -----------------------------------------------------

	# Copy bootanimation.zip
	mkdir media
	chmod 777 media
	chown root:root media
	xattr -w security.selinux u:object_r:system_file:s0 media
	
	mkdir media/audio/
	chmod 777 media/audio
	chown root:root media/audio
	xattr -w security.selinux u:object_r:system_file:s0 media/audio
	
	cp "$origin/files-patch/media/bootanimation.zip" "media/bootanimation.zip"
	chmod 644 "media/bootanimation.zip"
	xattr -w security.selinux u:object_r:system_file:s0 "media/bootanimation.zip"
	
	# Remove duplicate media audio
	rm -rf product/media/audio/ringtones/ANDROMEDA.ogg
	rm -rf product/media/audio/ringtones/CANISMAJOR.ogg
	rm -rf product/media/audio/ringtones/URSAMINOR.ogg
	
	# Remove non huawei Overlay
	rm -rf product/overlay/treble-overlay-infinix-*
	rm -rf product/overlay/treble-overlay-lenovo-*
	rm -rf product/overlay/treble-overlay-lge-*
	rm -rf product/overlay/treble-overlay-asus-*
	rm -rf product/overlay/treble-overlay-xiaomi-*
	rm -rf product/overlay/treble-overlay-samsung-*
	rm -rf product/overlay/treble-overlay-sony-*	
	rm -rf product/overlay/treble-overlay-tecno-*
	rm -rf product/overlay/treble-overlay-realme-*
	rm -rf product/overlay/treble-overlay-oppo-*
	rm -rf product/overlay/treble-overlay-nokia-*
	rm -rf product/overlay/treble-overlay-oneplus-*	
	rm -rf product/overlay/treble-overlay-nubia-*		
	rm -rf product/overlay/treble-overlay-moto-*	
	rm -rf product/overlay/treble-overlay-lg-*
	rm -rf product/overlay/treble-overlay-htc-*
	rm -rf product/overlay/treble-overlay-blackview-*
	rm -rf product/overlay/treble-overlay-vivo-*
	rm -rf product/overlay/treble-overlay-vsmart-*
	rm -rf product/overlay/treble-overlay-razer-*
	rm -rf product/overlay/treble-overlay-sharp-*
	
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
		

)
sleep 1

umount d

e2fsck -f -y s-ab-raw.img || true
resize2fs -M s-ab-raw.img

# Make android spare image
img2simg s-ab-raw.img s-ab.img






