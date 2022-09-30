#!/bin/bash

#Usage:
#sudo bash run-huawei-abonly.sh  [/path/to/system.img] [version] [model device] [huawei animation]
#cleanups
#A13 version
umount d

set -ex

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"


targetArch=64
srcFile="$1"
versionNumber="$2"
model="$3"
bootanim="$4"


if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash run-huawei-ab.sh [/path/to/system.img] [version] [model device] [bootanimation]"
	echo "version=LeaOS, LeaOS-PHH , crDRom v316 - Mod Iceows , LiR v316 - Mod Iceows , Caos v316 - Mod Iceows"
	echo "device=ANE-LX1"
	echo "bootanimation=[Y/N]"
	exit 1
fi

"$origin"/simg2img "$srcFile" s-ab-raw.img || cp "$srcFile" s-ab-raw.img

rm -Rf tmp
mkdir -p d tmp
e2fsck -y -f s-ab-raw.img
resize2fs s-ab-raw.img 5000M
e2fsck -E unshare_blocks -y -f s-ab-raw.img
mount -o loop,rw s-ab-raw.img d
(
	#----------------------------- Missing Huawei root folder -----------------------------------------------------		
	cd d
	
	rm -rf splash2
	rm -rf modem_log
	
	mkdir splash2
	chown root:root splash2
	chmod 777 splash2
	xattr -w security.selinux u:object_r:rootfs:s0 splash2
	
	mkdir modem_log
	chown root:root modem_log
	chmod 777 modem_log
	xattr -w security.selinux u:object_r:rootfs:s0 modem_log
	
	#mkdir sec_storage
	#chown root:root sec_storage
	#chmod 777 sec_storage
	#xattr -w security.selinux u:object_r:rootfs:s0 sec_storage
	
	
	cd system
		
		
	#---------------------------------Setting properties -------------------------------------------------
	
	# Dirty hack to show build properties
	# To get productid : sed -nE 's/.*productid=([0-9xa-f]*).*/\1/p' /proc/cmdline
	#MODEL=$( cat /sys/firmware/devicetree/base/boardinfo/normal_product_name | tr -d '\n')
	

	# build - change type to user
	sed -i "/ro.system.build.type/d" build.prop 
	sed -i "/ro.build.type/d" build.prop 	
	echo "ro.system.build.type=user" >> build.prop
	echo "ro.build.type=user" >> build.prop

	
	echo "#" >> build.prop
	echo "## Adding hi6250 props" >> build.prop
	echo "#" >> build.prop
	

	
	# change product and system_ext prop
	# sed -i "/ro.product.system_ext.model/d" system_ext/build.prop 
	# sed -i "/ro.product.system_ext.brand/d" system_ext/build.prop 
	# sed -i "/ro.product.system_ext.device/d" system_ext/build.prop 
	# sed -i "/ro.product.system_ext.name/d" system_ext/build.prop 
		
	# sed -i "/ro.product.product.model/d" product/build.prop 
	# sed -i "/ro.product.product.brand/d" product/build.prop 
	# sed -i "/ro.product.product.device/d" product/build.prop 
	# sed -i "/ro.product.product.name/d" product/build.prop  
	
	# sed -i "/ro.product.system.model/d" product/build.prop 
	# sed -i "/ro.product.system.brand/d" product/build.prop 
	# sed -i "/ro.product.system.device/d" product/build.prop 
	# sed -i "/ro.product.system.name/d" product/build.prop 
	
	# echo "ro.product.system_ext.model=$model" >>  system_ext/build.prop
	# echo "ro.product.system_ext.brand=Huawei" >>  system_ext/build.prop
	# echo "ro.product.system_ext.device=anne" >>  system_ext/build.prop
	# echo "ro.product.system_ext.name=LeaOS" >>  system_ext/build.prop
	
	# echo "ro.product.product.model=$model" >>  product/build.prop
	# echo "ro.product.product.brand=Huawei" >>  product/build.prop
	# echo "ro.product.product.device=anne" >>  product/build.prop
	# echo "ro.product.product.name=LeaOS" >>  product/build.prop
	
	echo "ro.product.system.model=$model" >>  build.prop
	echo "ro.product.system.brand=Huawei" >>  build.prop
	echo "ro.product.system.device=anne" >>  build.prop
	echo "ro.product.system.name=LeaOS" >>  build.prop
	
	sed -i "/ro.product.manufacturer/d" build.prop
	sed -i "/ro.product.model/d" build.prop
	sed -i "/ro.product.device/d" build.prop
	sed -i "/ro.product.name/d" build.prop
	
	echo "ro.product.manufacturer=Huawei" >> build.prop
	echo "ro.product.model=$model" >> build.prop
	echo "ro.product.device=anne" >> build.prop
	echo "ro.product.name=LeaOS" >> build.prop


	
	# echo "ro.product.name
	# echo "ro.product.device

	# set default sound
	echo "ro.config.ringtone=Ring_Synth_04.ogg" >>  build.prop
	echo "ro.config.notification_sound=OnTheHunt.ogg">>  build.prop
	echo "ro.config.alarm_alert=Argon.ogg">>  build.prop

	# set lineage version number for lineage build
	sed -i "/ro.lineage.version/d"  build.prop
	sed -i "/ro.lineage.display.version/d"  build.prop
	sed -i "/ro.modversion/d"  build.prop
	echo "ro.lineage.version=$versionNumber" >>  build.prop
	echo "ro.lineage.display.version=$versionNumber" >>  build.prop
	echo "ro.modversion=$versionNumber" >>  build.prop
 
	# Debug LMK - for Android Kernel that support it - e
	echo "ro.lmk.debug=false" >>  build.prop
	
	# Debug Huawei Off - if on  start service logcat 
	echo "persist.sys.hiview.debug=1" >> build.prop
	echo "persist.sys.huawei.debug.on=1" >> build.prop

	
	# Enable wireless display (Cast/Miracast)
	echo "persist.debug.wfd.enable=1" >>  build.prop
	
	# DarkJoker ANE-LX1 special prop
	# Audio
	echo "audio.deep_buffer.media=true" >>  build.prop
	echo "ro.config.media_vol_steps=25" >>  build.prop
	echo "ro.config.vc_call_vol_steps=7" >>  build.prop

	# Display
	echo "ro.surface_flinger.running_without_sync_framework=true" >>  build.prop

	# Graphics
	echo "debug.egl.hw=1" >>  build.prop
	echo "debug.egl.profiler=1" >>  build.prop
	echo "debug.hwui.use_buffer_age=false" >>  build.prop
	echo "debug.performance.tuning=1" >>  build.prop
	echo "debug.sf.enable_hwc_vds=0" >>  build.prop
	echo "debug.sf.hw=1" >>  build.prop
	echo "hwui.disable_vsync=true" >>  build.prop
	echo "ro.config.enable.hw_accel=true" >>  build.prop
	echo "video.accelerate.hw=1" >>  build.prop
	echo "debug.sf.latch_unsignaled=1" >>  build.prop
	echo "ro.surface_flinger.max_frame_buffer_acquired_buffers=3" >> build.prop
	echo "debug.cpurend.vsync=false" >> build.prop
	echo "ro.hardware.egl=mali" >> build.prop
	echo "ro.hardware.vulkan=mali" >> build.prop
	
	# CPU
	echo "persist.sys.boost.byeachfling=true" >> build.prop
	echo "persist.sys.boost.skipframe=3" >> build.prop
	echo "persist.sys.boost.durationms=1000" >> build.prop		
	echo "persist.sys.cpuset.enable=1" >> build.prop
	echo "persist.sys.performance=true" >> build.prop
	

	

	# Usb
	echo "persist.sys.usb.config=hisuite,mtp,mass_storage" >> build.prop 
	echo "sys.usb.config=mtp" >> build.prop
	echo "sys.usb.configfs=1" >> build.prop
	echo "sys.usb.controller=hisi-usb-otg" >> build.prop
	echo "sys.usb.ffs.aio_compat=true" >> build.prop
	echo "sys.usb.ffs.ready=0" >> build.prop
	echo "sys.usb.ffs_hdb.ready=0" >> build.prop
	echo "sys.usb.state=mtp,adb" >> build.prop
	

	#-----------------------------File copy -----------------------------------------------------
	
	# rw-system custom for Huawei device
	# cp "$origin/files-patch/system/bin/rw-system.sh" bin/rw-system.sh
	# xattr -w security.selinux u:object_r:phhsu_exec:s0 bin/rw-system.sh
	cp "$origin/files-patch/system/bin/vndk-detect" bin/vndk-detect
	xattr -w security.selinux u:object_r:phhsu_exec:s0 bin/vndk-detect
	
	
	# Fix LD_PRELOAD in vndk
	cp "$origin/files-patch/system/etc/init/vndk.rc" etc/init/vndk.rc
	xattr -w security.selinux u:object_r:system_file:s0  etc/init/vndk.rc
	
	

	#-----------------------------vndk-lite ----
	cd ../d

	
	find -name \*.capex -or -name \*.apex -type f -delete
	for vndk in 28 29 ;do
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
)

sleep 1

umount d

e2fsck -f -y s-ab-raw.img || true
resize2fs -M s-ab-raw.img

mv s-ab-raw.img s-vndklite.img




