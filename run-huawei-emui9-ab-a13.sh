#!/bin/bash

#Usage:
#sudo bash run-huawei-ab-a13.sh  [/path/to/system.img] [version] [model device] [huawei animation]
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
erofs="$5"

if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash run-huawei-ab-a13.sh [/path/to/system.img] [version] [model device] [bootanimation] [erofs]"
	echo "version=LeaOS A13"
	echo "device=ANE-LX1"
	echo "bootanimation=[Y/N]"
	echo "erofs=[Y/N]"
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
	rm -rf preavs
	
	mkdir splash2
	chown root:root splash2
	chmod 777 splash2
	xattr -w security.selinux u:object_r:rootfs:s0 splash2
	
	mkdir modem_log
	chown root:root modem_log
	chmod 777 modem_log
	xattr -w security.selinux u:object_r:rootfs:s0 modem_log
	
	mkdir preavs
	chown root:root preavs
	chmod 777 preavs
	xattr -w security.selinux u:object_r:rootfs:s0 preavs

	cd system
		
		
	#---------------------------------Setting properties -------------------------------------------------
	
	echo "#" >> build.prop
	echo "## Adding kirin props" >> build.prop
	echo "#" >> build.prop
	
	sed -i "/ro.system.build.type/d" build.prop 
	sed -i "/ro.build.type/d" build.prop 	
	
	echo "ro.system.build.type=user" >> build.prop
	echo "ro.build.type=user" >> build.prop

	
	# change product
	sed -i "/ro.product.manufacturer/d" build.prop
	sed -i "/ro.product.model/d" build.prop
	sed -i "/ro.product.name/d" build.prop
	sed -i "/ro.product.brand/d" build.prop
	sed -i "/ro.product.device/d" build.prop
		
	echo "ro.product.manufacturer=HUAWEI" >> build.prop
	echo "ro.product.model=$model" >> build.prop
	echo "ro.product.name=$model" >> build.prop
	

	# change product.system
	sed -i "/ro.product.system.model/d" build.prop 
	sed -i "/ro.product.system.brand/d" build.prop 
	sed -i "/ro.product.system.device/d" build.prop 
	sed -i "/ro.product.system.name/d" build.prop 
	
	echo "ro.product.system.model=$model" >>  build.prop
	echo "ro.product.system.name=$model" >>  build.prop
		
	# change product.product
	sed -i "/ro.product.product.model/d" product/etc/build.prop 
	sed -i "/ro.product.product.brand/d" product/etc/build.prop 
	sed -i "/ro.product.product.device/d" product/etc/build.prop 
	sed -i "/ro.product.product.name/d" product/etc/build.prop
	echo "ro.product.product.model=$model" >> product/etc/build.prop
	echo "ro.product.product.name=$model" >> product/etc/build.prop

	
	# change product.system_ext
	sed -i "/ro.product.system_ext.model/d" system_ext/etc/build.prop 
	sed -i "/ro.product.system_ext.brand/d" system_ext/etc/build.prop 
	sed -i "/ro.product.system_ext.device/d" system_ext/etc/build.prop 
	sed -i "/ro.product.system_ext.name/d" system_ext/etc/build.prop
	echo "ro.product.system_ext.model=$model" >> system_ext/etc/build.prop
	echo "ro.product.system_ext.name=$model" >> system_ext/etc/build.prop
	

	# set lineage version number for lineage build    	
	sed -i "/ro.lineage.version/d" build.prop
	sed -i "/ro.lineage.display.version/d" build.prop
	sed -i "/ro.modversion/d" build.prop
	sed -i "/ro.lineage.device/d" build.prop
	echo "ro.lineage.version=20" >>  build.prop
	echo "ro.lineage.display.version=$versionNumber" >>  build.prop
	
	# set modversion
	echo "ro.modversion=$versionNumber" >>  build.prop

		
	# set default sound
	echo "ro.config.ringtone=Ring_Synth_04.ogg" >>  build.prop
	echo "ro.config.notification_sound=OnTheHunt.ogg">>  build.prop
	echo "ro.config.alarm_alert=Argon.ogg">>  build.prop

 
	# Debug LMK - for Android Kernel that support it - e
	echo "ro.lmk.debug=false" >>  build.prop
	
	# Debug Huawei Off/On - if on EMUI8 start service logcat on boot
	echo "persist.sys.hiview.debug=0" >> build.prop
	echo "persist.sys.huawei.debug.on=0" >> build.prop

	
	# Enable wireless display (Cast/Miracast)
	echo "persist.debug.wfd.enable=1" >>  build.prop
	
	# Audio
	echo "audio.deep_buffer.media=true" >>  build.prop
	echo "audio.offload.buffer.size.kb=32" >> build.prop
	echo "ro.audio.offload_wakelock=false" >> build.prop
	
	# Display
	echo "ro.surface_flinger.running_without_sync_framework=true" >>  build.prop

	# Graphics hi6250 ?
	echo "debug.egl.hw=1" >>  build.prop
	echo "debug.egl.profiler=1" >>  build.prop
	echo "debug.hwui.use_buffer_age=false" >>  build.prop
	echo "debug.performance.tuning=1" >>  build.prop
	echo "debug.sf.enable_hwc_vds=0" >>  build.prop
	echo "debug.sf.hw=1" >>  build.prop
	echo "hwui.disable_vsync=true" >>  build.prop
	echo "ro.config.enable.hw_accel=true" >>  build.prop
	echo "video.accelerate.hw=1" >>  build.prop
	echo "ro.surface_flinger.max_frame_buffer_acquired_buffers=3" >> build.prop
	echo "debug.cpurend.vsync=false" >> build.prop
	echo "ro.hardware.egl=mali" >> build.prop
	echo "ro.hardware.vulkan=mali" >> build.prop
	echo "debug.sf.disable_backpressure=1" >>  build.prop
	echo "debug.sf.latch_unsignaled=1" >>  build.prop

	# Color
	echo "persist.sys.sf.native_mode=1" >> build.prop
	echo "persist.sys.sf.color_mode=1.0" >> build.prop
	echo "persist.sys.sf.color_saturation=1.1" >> build.prop
	
	# CPU
	echo "persist.sys.boost.byeachfling=true" >> build.prop
	echo "persist.sys.boost.skipframe=3" >> build.prop
	echo "persist.sys.boost.durationms=1000" >> build.prop		
	echo "persist.sys.cpuset.enable=1" >> build.prop
	echo "persist.sys.performance=true" >> build.prop
	
	# bluetooth
	echo "bluetooth.enable_timeout_ms=12000" >> build.prop
	
	# Usb
	echo "persist.sys.usb.config=hisuite,mtp,mass_storage" >> build.prop 
	
	
	# Performance android 13
	echo "debug.performance.tuning=1" >> build.prop
	

	#-----------------------------File copy -----------------------------------------------------

	# Copy bootanimation.zip	
	if [ "$bootanim" == "Y" ];then
		mkdir media
		chmod 777 media
		chown root:root media
		xattr -w security.selinux u:object_r:system_file:s0 media
		
		cp "$origin/files-patch/media/bootanimation.zip" "media/bootanimation.zip"
		chmod 644 "media/bootanimation.zip"
		xattr -w security.selinux u:object_r:system_file:s0 "media/bootanimation.zip"
	
	fi


	# STK-L22 y9s
	if [ "$model" == "STK-L22" ];then
	
		# [ro.sf.lcd_density]: [480]
		# [hw.lcd.density]: [480]
		# [hw.lcd.density.scale]: [800]
	
		# NO NFC

		# Device Name
		echo "ro.product.brand=HUAWEI" >> build.prop
		echo "ro.product.device=HWSTK-HF" >> build.prop	
		echo "ro.product.system.device=HWSTK-HF" >>  build.prop
		echo "ro.product.system.brand=HUAWEI" >>  build.prop	
		echo "ro.product.product.device=HWSTK-HF" >>  product/etc/build.prop
		echo "ro.product.product.brand=HUAWEI" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWSTK-HF" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HUAWEI" >>  system_ext/etc/build.prop
	fi
	
	# POT-LX1 / POT-LX1A P Smart 2019 / 2020
	if [ "$model" == "POT-LX1" ];then
		# NFC
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_potter.conf" etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_potter.conf" etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_potter.conf" etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_potter.conf" etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp_RF.conf	

		# Device Name
		echo "ro.product.brand=HUAWEI" >> build.prop
		echo "ro.product.device=HWPOT" >> build.prop	
		echo "ro.product.system.device=HWPOT" >>  build.prop
		echo "ro.product.system.brand=HUAWEI" >>  build.prop	
		echo "ro.product.product.device=HWPOT" >>  product/etc/build.prop
		echo "ro.product.product.brand=HUAWEI" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWPOT" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HUAWEI" >>  system_ext/etc/build.prop
	fi	

	# VTR-L09 / VTR-AL00 Huawei P10
	if [ "$model" == "VTR-L09" ];then
		# NFC
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_victoria.conf" etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_victoria.conf" etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_victoria.conf" etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_victoria.conf" etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp_RF.conf
		
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_victoria.conf" product/etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  product/etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_victoria.conf" product/etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_victoria.conf" product/etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_victoria.conf" product/etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp_RF.conf
		
		# Device Name
		echo "ro.hardware.consumerir=hisi.hi3660" >> build.prop
		echo "ro.product.brand=HUAWEI" >> build.prop
		echo "ro.build.product=VTR-L09" >> build.prop
		echo "ro.product.device=HWVTR" >> build.prop	
		echo "ro.product.device=HWVTR" >> build.prop	
		echo "ro.product.system.device=HWVTR" >>  build.prop
		echo "ro.product.system.brand=HUAWEI" >>  build.prop	
		echo "ro.product.product.device=HWVTR" >>  product/etc/build.prop
		echo "ro.product.product.brand=HUAWEI" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWVTR" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HUAWEI" >>  system_ext/etc/build.prop

	elif [ "$model" == "VTR-AL00" ];then
	# NFC
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_victoria.conf" etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_victoria.conf" etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_victoria.conf" etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_victoria.conf" etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp_RF.conf
		
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_victoria.conf" product/etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  product/etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_victoria.conf" product/etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_victoria.conf" product/etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_victoria.conf" product/etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp_RF.conf


		# Device Name
		echo "ro.hardware.consumerir=hisi.hi3660" >> build.prop
		echo "ro.product.brand=HUAWEI" >> build.prop
		echo "ro.build.product=VTR-AL00" >> build.prop
		echo "ro.product.device=HWVTR" >> build.prop	
		echo "ro.product.device=HWVTR" >> build.prop	
		echo "ro.product.system.device=HWVTR" >>  build.prop
		echo "ro.product.system.brand=HUAWEI" >>  build.prop
		# echo "ro.build.fingerprint=HUAWEI/VTR-AL00/HWVTR:9/HUAWEIVTR-AL00/120C00R1:user/release-keys" >> build.prop	
		# echo "ro.system.build.fingerprint=HUAWEI/VTR-AL00/HWVTR:9/HUAWEIVTR-AL00/120C00R1:user/release-keys" >> build.prop	
		echo "ro.product.product.device=HWVTR" >>  product/etc/build.prop
		echo "ro.product.product.brand=HUAWEI" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWVTR" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HUAWEI" >>  system_ext/etc/build.prop
		# echo "ro.system_ext.build.fingerprint=HUAWEI/VTR-AL00/HWVTR:9/HUAWEIVTR-AL00/120C00R1:user/release-keys" >> system_ext/etc/build.prop


	fi

	# FIG-LX1 Huawei P Smart 2018
	if [ "$model" == "FIG-LX1" ];then
		# NFC
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_figo.conf" etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_figo.conf" etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_figo.conf" etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_figo.conf" etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp_RF.conf
		
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_figo.conf" product/etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  product/etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_figo.conf" product/etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_figo.conf" product/etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_figo.conf" product/etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp_RF.conf

		echo "ro.product.brand=HUAWEI" >> build.prop
		echo "ro.product.device=HWFIG" >> build.prop		
		echo "ro.product.system.device=HWFIG" >>  build.prop
		echo "ro.product.system.brand=HUAWEI" >>  build.prop	
		echo "ro.product.product.device=HWFIG" >>  product/etc/build.prop
		echo "ro.product.product.brand=HUAWEI" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWFIG" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HUAWEI" >>  system_ext/etc/build.prop
		echo "ro.build.product=FIG" >> build.prop
		
		echo "ro.lineage.device=HWFIG" >>  build.prop
	fi
			
	

	# ANE-LX1 Huawei P20 Lite 2017
	if [ "$model" == "ANE-LX1" ];then
		# NFC 
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_anne.conf" etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_anne.conf" etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_anne.conf" etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_anne.conf" etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp_RF.conf
		
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_anne.conf" product/etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  product/etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_anne.conf" product/etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_anne.conf" product/etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_anne.conf" product/etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp_RF.conf

		echo "ro.product.system.device=HWANE" >>  build.prop
		echo "ro.product.system.brand=HUAWEI" >>  build.prop	
		echo "ro.product.brand=HUAWEI" >> build.prop
		echo "ro.product.device=HWANE" >> build.prop
		echo "ro.product.product.device=HWANE" >>  product/etc/build.prop
		echo "ro.product.product.brand=HUAWEI" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWANE" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HUAWEI" >>  system_ext/etc/build.prop
		echo "ro.build.product=ANE" >> build.prop
	fi	


	# STF-L09 Huawei Honor 9 (L09 - L29)
	if [ "$model" == "STF-L09" ];then
		# NFC 
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_stanford.conf" etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_stanford.conf" etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_stanford.conf" etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_stanford.conf" etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp_RF.conf
		
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_stanford.conf" product/etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  product/etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_stanford.conf" product/etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_stanford.conf" product/etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_stanford.conf" product/etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp_RF.conf

		echo "ro.product.brand=HONOR" >> build.prop
		echo "ro.product.device=HWSTF" >> build.prop	
		echo "ro.product.system.device=HWSTF" >>  build.prop
		echo "ro.product.system.brand=HONOR" >>  build.prop	
		echo "ro.product.product.device=HWSTF" >>  product/etc/build.prop
		echo "ro.product.product.brand=HONOR" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWSTF" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HONOR" >>  system_ext/etc/build.prop
		echo "ro.build.product=STF" >> build.prop
		
		# Perhaps also replace fingerprint
		#[ro.build.description]: [STF-L09-user 9.1.0 HUAWEISTF-L09 231-OVS-LGRP2 release-keys]
		#[ro.build.display.id]: [STF-L09 9.1.0.220(C432E2R1P5)]
		#[ro.build.fingerprint]: [HONOR/STF-L09/HWSTF:9/HUAWEISTF-L09/9.1.0.220C432:user/release-keys]
		#[ro.huawei.build.fingerprint]: [HONOR/STF-L09/HWSTF:9/HUAWEISTF-L09/9.1.0.231C432:user/release-keys]
		
	fi
	
	# Huawei Honor play
	if [ "$model" == "COR-AL00" ];then
	
		echo "ro.product.system.device=HWCOR" >>  build.prop
		echo "ro.product.system.brand=HONOR" >>  build.prop	
		echo "ro.product.brand=HONOR" >> build.prop
		echo "ro.product.device=HWCOR" >> build.prop
		echo "ro.product.product.device=HWCOR" >>  product/etc/build.prop
		echo "ro.product.product.brand=HONOR" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWCOR" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HONOR" >>  system_ext/etc/build.prop
	fi
	
	# Huawei P20 Pro
	if [ "$model" == "CLT-L29" ];then
	
		echo "ro.product.system.device=HWCLT" >>  build.prop
		echo "ro.product.system.brand=HUAWEI" >>  build.prop	
		echo "ro.product.device=HWCLT" >> build.prop
		echo "ro.product.brand=HUAWEI" >> build.prop
		echo "ro.product.product.device=HWCLT" >>  product/etc/build.prop
		echo "ro.product.product.brand=HUAWEI" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWCLT" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HUAWEI" >>  system_ext/etc/build.prop
	fi
	
	
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
	

	# Tee Deamon
	cp "$origin/files-patch/system/bin/tee_auth_daemon" bin/tee_auth_daemon
	xattr -w security.selinux u:object_r:teecd_auth_exec:s0  bin/tee_auth_daemon
	chmod 755 bin/tee_auth_daemon
	# 2000 = shell
	chown root:2000 bin/tee_auth_daemon
	cp "$origin/files-patch/system/bin/79b77788-9789-4a7a-a2be-b60155eef5f4.sec" bin/79b77788-9789-4a7a-a2be-b60155eef5f4.sec
	xattr -w security.selinux u:object_r:system_file:s0  bin/79b77788-9789-4a7a-a2be-b60155eef5f4
	cp "$origin/files-patch/system/lib64/libc_secshared.so" lib64/libc_secshared.so
	xattr -w security.selinux u:object_r:system_lib_file:s0  lib64/libc_secshared.so
	cp "$origin/files-patch/system/lib64/libtuidaemon.so" lib64/libtuidaemon.so
	xattr -w security.selinux u:object_r:system_lib_file:s0  lib64/libtuidaemon.so
	cp "$origin/files-patch/system/lib64/libteec_client.so" lib64/libteec_client.so
	xattr -w security.selinux u:object_r:system_lib_file:s0  lib64/libteec_client.so
	cp "$origin/files-patch/system/lib64/libhidlbase.so" lib64/libhidlbase.so
	xattr -w security.selinux u:object_r:system_lib_file:s0  lib64/libhidlbase.so
	cp "$origin/files-patch/system/lib64/vendor.huawei.hardware.libteec@1.0.so" lib64/vendor.huawei.hardware.libteec@1.0.so
	xattr -w security.selinux u:object_r:system_lib_file:s0  lib64/vendor.huawei.hardware.libteec@1.0.so
	cp "$origin/files-patch/system/lib64/vendor.huawei.hardware.libteec@2.0.so" lib64/vendor.huawei.hardware.libteec@2.0.so
	xattr -w security.selinux u:object_r:system_lib_file:s0   lib64/vendor.huawei.hardware.libteec@2.0.so	

	
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
	
	# Bluetooth conf : 1000 = system
	mkdir etc/bluetooth/
	chmod 766 etc/bluetooth/
	chown 1000:1000 etc/bluetooth/
	xattr -w security.selinux u:object_r:system_file:s0 etc/bluetooth
	
	cp "$origin/files-patch/system/etc/bluetooth/bt_did.conf" etc/bluetooth/bt_did.conf
	xattr -w security.selinux u:object_r:system_file:s0 etc/bluetooth/bt_did.conf
	cp "$origin/files-patch/system/etc/bluetooth/bt_stack.conf" etc/bluetooth/bt_stack.conf
	xattr -w security.selinux u:object_r:system_file:s0 etc/bluetooth/bt_stack.conf
	
	# Special linkerconfig to support preavs
	#rm -rf ../linkerconfig/ld.config.txt
	#cp "$origin/files-patch/linkerconfig/ld.config.txt" ../linkerconfig/ld.config.txt
	#xattr -w security.selinux object_r:linkerconfig_file:s0 ../linkerconfig/ld.config.txt
	#chown root:root ../linkerconfig/ld.config.txt
	#chmod 777 ../linkerconfig/ld.config.txt
	
	#cp "$origin/files-patch/linkerconfig/ld.config.28.txt" etc/ld.config.28.txt
	#cp "$origin/files-patch/linkerconfig/ld.config.28.txt" etc/ld.config.txt
	#xattr -w security.selinux u:object_r:system_file:s0 etc/ld.config.28.txt
	#xattr -w security.selinux u:object_r:system_file:s0 etc/ld.config.txt

		
	# --------------AGPS Patch Only gnss model ---------------------- #
	
	if [ "$model" == "FIG-LX1" ] || [ "$model" == "ANE-LX1" ] || [ "$model" == "POT-LX1" ];then
	
		cp "$origin/files-patch/system/bin/gnss_watchlssd_thirdparty" bin/gnss_watchlssd_thirdparty
		cp "$origin/files-patch/system/lib/libgnss_lss_gw_thirdparty.so" lib/libgnss_lss_gw_thirdparty.so
		cp "$origin/files-patch/system/lib64/libgnss_lss_gw_thirdparty.so" lib64/libgnss_lss_gw_thirdparty.so
		
		mkdir app/gnss_supl20service_hisi
		chmod 755 app/
		xattr -w security.selinux u:object_r:system_file:s0 app/gnss_supl20service_hisi
		
		cp "$origin/files-patch/system/app/gnss_supl20service_hisi/gnss_supl20service_hisi.apk" app/gnss_supl20service_hisi/gnss_supl20service_hisi.apk
		xattr -w security.selinux u:object_r:system_file:s0 app/gnss_supl20service_hisi/gnss_supl20service_hisi.apk
		
		cp "$origin/files-patch/system/etc/gps_debug.conf" etc/gps_debug.conf
		cp "$origin/files-patch/system/etc/permissions/privapp-permissions-supl.xml" etc/permissions/privapp-permissions-supl.xml
		xattr -w security.selinux u:object_r:system_file:s0  etc/permissions/privapp-permissions-supl.xml
		
		mkdir etc/gnss
		xattr -w security.selinux u:object_r:system_file:s0  etc/gnss
		mkdir etc/gnss/config
		xattr -w security.selinux u:object_r:system_file:s0  etc/gnss/config
		cp "$origin/files-patch/system/etc/gnss/config/gnss_suplconfig_hisi.xml" etc/gnss/config/gnss_suplconfig_hisi.xml
		cp "$origin/files-patch/system/etc/gnss/config/gnss_lss_config_thirdparty.bin" etc/gnss/config/gnss_lss_config_thirdparty.bin
		cp "$origin/files-patch/system/etc/gnss/config/gnss_lss_rfg_key_thirdparty.pem" etc/gnss/config/gnss_lss_rfg_key_thirdparty.pem
		cp "$origin/files-patch/system/etc/gnss/config/gnss_lss_slp_thirdparty.p12" etc/gnss/config/gnss_lss_slp_thirdparty.p12
		xattr -w security.selinux u:object_r:system_file:s0  etc/gnss/config/gnss_suplconfig_hisi.xml
		xattr -w security.selinux u:object_r:system_file:s0  etc/gnss/config/gnss_lss_config_thirdparty.bin
		xattr -w security.selinux u:object_r:system_file:s0  etc/gnss/config/gnss_lss_rfg_key_thirdparty.pem
		xattr -w security.selinux u:object_r:system_file:s0  etc/gnss/config/gnss_lss_slp_thirdparty.p12
		
		# Add RC
		cp "$origin/files-patch/system/etc/init/init-gnss.rc" etc/init/init-gnss.rc
		xattr -w security.selinux u:object_r:system_file:s0 etc/init/init-gnss.rc
		
		
		# Set owner and permissions (system:system)
		chmod 755 bin/gnss_watchlssd_thirdparty
		chown root:2000 bin/gnss_watchlssd_thirdparty

		xattr -w security.selinux u:object_r:hi110x_daemon_exec:s0 bin/gnss_watchlssd_thirdparty
		xattr -w security.selinux u:object_r:system_lib_file:s0 lib/libgnss_lss_gw_thirdparty.so
		xattr -w security.selinux u:object_r:system_lib_file:s0 lib64/libgnss_lss_gw_thirdparty.so


		# For gnss_lss
		echo "/system/bin/gnss_watchlssd_thirdparty		u:object_r:hi110x_daemon_exec:s0" >> etc/selinux/plat_file_contexts 
		echo "(allow hi110x_daemon self (fifo_file (ioctl read write create getattr setattr lock append unlink rename open)))" >> etc/selinux/plat_sepolicy.cil
		echo "(allow hi110x_daemon system_data_root_file (dir (read write)))" >> etc/selinux/plat_sepolicy.cil
		echo "(allow hi110x_daemon socket_device (dir (read write)))" >> etc/selinux/plat_sepolicy.cil
		

		# Hisupl (com.android.supl) - gnss_supl20service_hisi.apk (old version)
		echo "(allow system_app hi110x_daemon (unix_stream_socket (connectto create bind read write getattr setattr lock append listen accept getopt setopt shutdown)))" >> etc/selinux/plat_sepolicy.cil
		echo "(allow system_app hal_hisupl_default (binder (call transfer)))" >> etc/selinux/plat_sepolicy.cil 
		echo "(allow system_app hi110x_vendor_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil
		echo "(allow system_app hi110x_vendor_file (file (open read)))" >>  etc/selinux/plat_sepolicy.cil 


		# ------------------------------------ #
		
		# From iceows supl20 apk (# Hisi)
		echo "is_hisi_connectivity_chip=1" >> build.prop
		echo "ro.hardware.consumerir=hisi.hi6250" >> build.prop		
		echo "ro.hardware.hisupl=hi1102"  >> build.prop;
	fi
	

	# Hisupl (com.android.supl) - gnss_supl20service_hisi.apk (old version)
	echo "(allow system_app hi110x_daemon (unix_stream_socket (connectto create bind read write getattr setattr lock append listen accept getopt setopt shutdown)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_app hal_hisupl_default (binder (call transfer)))" >> etc/selinux/plat_sepolicy.cil 
	echo "(allow system_app hi110x_vendor_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_app hi110x_vendor_file (file (open read)))" >>  etc/selinux/plat_sepolicy.cil 
	
	
	
	# Fix system ntp_server (europe pool)
	set global ntp_server europe.pool.ntp.org

	# Allow agps an set config
	echo "persist.sys.pgps.config=1"  >> build.prop;
	echo "assisted_gps_enabled=1"  >> build.prop;

	# Uncomment to Debug GPS
	# echo "log.tag.GnssConfiguration=DEBUG" >> build.prop;
	# echo "log.tag.GnssLocationProvider=DEBUG" >> build.prop;
	# echo "log.tag.GnssManagerService=DEBUG" >> build.prop;
	# echo "log.tag.NtpTimeHelper=DEBUG" >> build.prop;
	
	# active le mode journalisation
	# echo "ro.control_privapp_permissions=log" >> build.prop;


	
	#----------------------------- SELinux rules Now include in huawei.te ------------------------------	

	# NFC and perf
	echo "(allow nfc system_data_file (file (ioctl read write create getattr setattr lock append unlink rename open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel system_data_root_file (file (setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel system_data_root_file (dir (setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow uniperf system_data_file (lnk_file (read)))" >> etc/selinux/plat_sepolicy.cil

	
	
	# --------------------------- Kirin EMUI 9 perf properties add SELinux rules for vendor init -----

	echo "(type kirin_audio_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r kirin_audio_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(type kirin_perf_persist_public_read_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r kirin_perf_persist_public_read_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(type kirin_video_dbg_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r kirin_video_dbg_prop)" >> etc/selinux/plat_sepolicy.cil	
	echo "(type kirin_video_dbgs_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r kirin_video_dbgs_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(type kirin_audio_set_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r kirin_audio_set_prop)" >> etc/selinux/plat_sepolicy.cil	
	echo "(type kirin_drm_info)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r kirin_drm_info)" >> etc/selinux/plat_sepolicy.cil
	echo "(type kirin_video_sys_mediaserver_timestamp_print)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r kirin_video_sys_mediaserver_timestamp_print)" >> etc/selinux/plat_sepolicy.cil
	echo "(type kirin_video_sys_mediaserver_saveyuv)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r kirin_video_sys_mediaserver_saveyuv)" >> etc/selinux/plat_sepolicy.cil
	echo "(type kirin_perf_ro_public_read_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r kirin_perf_ro_public_read_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(type product_platform_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r product_platform_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(type tee_tui_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r tee_tui_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(type vowifi_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r vowifi_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(type huawei_hiai_ddk_version_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r huawei_hiai_ddk_version_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(type huawei_perf_persist_public_read_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r huawei_perf_persist_public_read_prop)" >> etc/selinux/plat_sepolicy.cil
	
	echo "(typeattribute kirin_exported_public_read_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(typeattributeset kirin_exported_public_read_prop (kirin_audio_prop kirin_video_dbg_prop kirin_video_dbgs_prop kirin_drm_info kirin_video_sys_mediaserver_timestamp_print kirin_video_sys_mediaserver_saveyuv kirin_perf_persist_public_read_prop kirin_perf_ro_public_read_prop product_platform_prop tee_tui_prop vowifi_prop huawei_hiai_ddk_version_prop ))" >> etc/selinux/plat_sepolicy.cil
	echo "(typeattribute huawei_exported_public_read_prop)" >> etc/selinux/plat_sepolicy.cil
	echo "(typeattributeset huawei_exported_public_read_prop ( huawei_perf_persist_public_read_prop ))" >> etc/selinux/plat_sepolicy.cil


	#sed -i '/(typeattributeset kirin_exported_public_read_prop/d' /system/etc/selinux/plat_sepolicy.cil	
	#(type vrdisplay_property)
	#(roletype object_r vrdisplay_property)
	#(type netflix_certification_prop)
	#(roletype object_r netflix_certification_prop)


	# ------------------- etc/selinux/mapping/28.0.cil ------------------

	echo "(typeattributeset kirin_audio_prop_28_0 (kirin_audio_prop))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (kirin_audio_prop_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute kirin_audio_prop_28_0)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattributeset kirin_video_dbg_prop_28_0 (kirin_video_dbg_prop))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (kirin_video_dbg_prop_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute kirin_video_dbg_prop_28_0)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattributeset kirin_video_dbgs_prop_28_0 (kirin_video_dbgs_prop))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (kirin_video_dbgs_prop_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute kirin_video_dbgs_prop_28_0)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattributeset kirin_drm_info_28_0 (kirin_drm_info))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (kirin_drm_info_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute kirin_drm_info_28_0)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattributeset kirin_video_sys_mediaserver_timestamp_print_28_0 (kirin_video_sys_mediaserver_timestamp_print))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (kirin_video_sys_mediaserver_timestamp_print_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute kirin_video_sys_mediaserver_timestamp_print_28_0)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattributeset kirin_video_sys_mediaserver_saveyuv_28_0 (kirin_video_sys_mediaserver_saveyuv))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (kirin_video_sys_mediaserver_saveyuv_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute kirin_video_sys_mediaserver_saveyuv_28_0)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattributeset kirin_perf_persist_public_read_prop_28_0 (kirin_perf_persist_public_read_prop))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (kirin_perf_persist_public_read_prop_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute kirin_perf_persist_public_read_prop_28_0)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattributeset kirin_perf_ro_public_read_prop_28_0 (kirin_perf_ro_public_read_prop))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (kirin_perf_ro_public_read_prop_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute kirin_perf_ro_public_read_prop_28_0)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattributeset product_platform_prop_28_0 (product_platform_prop))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (product_platform_prop_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute product_platform_prop_28_0)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattributeset tee_tui_prop_28_0 (tee_tui_prop))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (tee_tui_prop_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute tee_tui_prop_28_0)" >> etc/selinux/mapping/28.0.cil
	
	echo "(typeattributeset huawei_perf_persist_public_read_prop_28_0 (huawei_perf_persist_public_read_prop))" >> etc/selinux/mapping/28.0.cil
	echo "(expandtypeattribute (huawei_perf_persist_public_read_prop_28_0) true)" >> etc/selinux/mapping/28.0.cil
	echo "(typeattribute huawei_perf_persist_public_read_prop_28_0)" >> etc/selinux/mapping/28.0.cil


	# ------------------- etc/selinux/plat_property_contexts ------------------

	echo "" >> etc/selinux/plat_property_contexts	
	echo "# vendor-init-settable|public-readable" >> etc/selinux/plat_property_contexts
	echo "# audio property" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.media.offload.enable  u:object_r:kirin_audio_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.media.usbvoice.enable  u:object_r:kirin_audio_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.media.usbvoice.name    u:object_r:kirin_audio_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.media.lowlatency.enable u:object_r:kirin_audio_prop:s0" >> etc/selinux/plat_property_contexts

	echo "" >> etc/selinux/plat_property_contexts	
	echo "# video property" >> etc/selinux/plat_property_contexts
	echo "kirin.video.debug.datadump             u:object_r:kirin_video_dbg_prop:s0" >> etc/selinux/plat_property_contexts
	echo "kirin.video.mntn                       u:object_r:kirin_video_dbgs_prop:s0" >> etc/selinux/plat_property_contexts
	echo "kirin.drm.info                         u:object_r:kirin_drm_info:s0" >> etc/selinux/plat_property_contexts
	echo "kirin.sys.mediaserver.timestamp.print  u:object_r:kirin_video_sys_mediaserver_timestamp_print:s0" >> etc/selinux/plat_property_contexts
	echo "kirin.sys.mediaserver.saveyuv          u:object_r:kirin_video_sys_mediaserver_saveyuv:s0" >> etc/selinux/plat_property_contexts

	echo "" >> etc/selinux/plat_property_contexts	
	echo "# perf property" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.alloc_buffer_sync u:object_r:kirin_perf_persist_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.texture_cache_opt u:object_r:kirin_perf_persist_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.touch_vsync_opt u:object_r:kirin_perf_persist_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.touch_move_opt u:object_r:kirin_perf_persist_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.touchevent_opt u:object_r:kirin_perf_persist_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.decodebitmap_opt u:object_r:kirin_perf_persist_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.kirin.perfoptpackage_list u:object_r:kirin_perf_persist_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	echo "ro.kirin.config.hw_perfgenius u:object_r:kirin_perf_ro_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	echo "ro.kirin.config.hw_board_ipa u:object_r:kirin_perf_ro_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	
	echo "" >> etc/selinux/plat_property_contexts	
	echo "persist.huawei.touch_vsync_opt u:object_r:huawei_perf_persist_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.huawei.touch_move_opt u:object_r:huawei_perf_persist_public_read_prop:s0" >> etc/selinux/plat_property_contexts
	echo "persist.huawei.touchevent_opt u:object_r:huawei_perf_persist_public_read_prop:s0" >> etc/selinux/plat_property_contexts

	echo "" >> etc/selinux/plat_property_contexts	
	echo "# product_platform" >> etc/selinux/plat_property_contexts
	echo "ro.kirin.product.platform     u:object_r:product_platform_prop:s0" >> etc/selinux/plat_property_contexts
	echo "ro.vendor.tui.service  u:object_r:tee_tui_prop:s0" >> etc/selinux/plat_property_contexts


	# property
	#echo "ro.hwcamera.SlowMotionZoom  u:object_r:default_prop:s0" >> etc/selinux/plat_property_contexts
		
	# Kirin	
	echo "persist.kirin.alloc_buffer_sync=true" >> build.prop
	echo "persist.kirin.texture_cache_opt=1"  >> build.prop
	echo "persist.kirin.touch_move_opt=1"  >> build.prop
	echo "persist.kirin.touch_vsync_opt=1"  >> build.prop
	echo "persist.kirin.touchevent_opt=1"  >> build.prop
	
	# Enable lowlatency
	echo "persist.media.lowlatency.enable=true" >> build.prop
	echo "persist.kirin.media.lowlatency.enable=true" >> build.prop

	#----------------------------- tee daemon --------------------------------------------------------	
	
	echo "/system/bin/tee_auth_daemon   u:object_r:teecd_auth_exec:s0" >> etc/selinux/plat_file_contexts
	echo "/sec_storage(/.*)?              u:object_r:teecd_data_file:s0" >> etc/selinux/plat_file_contexts
	echo "/sec_storage            u:object_r:teecd_data_file:s0" >> etc/selinux/plat_file_contexts
	echo "/dev/hisi_teelog                u:object_r:teelog_device:s0" >> etc/selinux/plat_file_contexts
	echo "/sys/kernel/tui/c_state         u:object_r:sysfs_tee:s0" >> etc/selinux/plat_file_contexts
	echo "/dev/socket/tee-multi-user              u:object_r:tee_multi_user_socket:s0" >> etc/selinux/plat_file_contexts
	
	echo "(type teecd_auth_exec)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r teecd_auth_exec)" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init teecd_auth_exec (file (read getattr map execute open)))" >> etc/selinux/plat_sepolicy.cil

	echo "(type teecd_data_file)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r teecd_data_file)" >> etc/selinux/plat_sepolicy.cil
	
	echo "(type teelog_device)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r teelog_device)" >> etc/selinux/plat_sepolicy.cil

	echo "(type sysfs_tee)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r sysfs_tee)" >> etc/selinux/plat_sepolicy.cil
	
	echo "(type tee_multi_user_socket)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r tee_multi_user_socket)" >> etc/selinux/plat_sepolicy.cil
	
	echo "(type system_teecd)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r system_teecd)" >> etc/selinux/plat_sepolicy.cil

	echo "(allow tee_multi_user_socket socket_device (dir (write add_name)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow tee_multi_user_socket socket_device (sock_file (create setattr)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow init teecd_data_file (dir (mounton)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init teecd_data_file (filesystem (relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck teecd_data_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow teecd_data_file self (filesystem (relabelto relabelfrom associate)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow installd teecd_data_file (filesystem (quotaget)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow init teecd_auth_exec (file (read getattr map execute open)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow init system_teecd (file (open write read ioctl getattr setattr relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init system_teecd (process (transition)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd tmpfs (dir (getattr search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (capability (dac_override)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd tee_device (chr_file (ioctl read write getattr lock append open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd tee_data_file (dir (ioctl read write getattr lock add_name remove_name search open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd tee_data_file (file (ioctl read write create getattr setattr lock append unlink rename open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (netlink_socket (read write create getattr setattr lock append bind connect getopt setopt shutdown)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (netlink_generic_socket (read write create getattr setattr lock append bind connect getopt setopt shutdown)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd sysfs_type (dir (ioctl read getattr lock search open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd sysfs_type (file (ioctl read getattr lock open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd sysfs_type (lnk_file (ioctl read getattr lock open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd system_data_file (file (read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd system_data_file (lnk_file (ioctl read getattr lock open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (capability (chown sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd kernel (process (setsched)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init system_teecd (process (transition)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd rootfs (file (read getattr execute entrypoint open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(dontaudit init system_teecd (process (noatsecure)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init system_teecd (process (siginh rlimitinh)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd property_socket (sock_file (write)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd init (unix_stream_socket (connectto)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd teecd_data_file (dir (setattr mounton)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (filesystem (associate)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd teecd_data_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(typetransition system_teecd system_data_file dir teecd_data_file)" >> etc/selinux/plat_sepolicy.cil
	echo "(typetransition system_teecd system_data_file fifo_file teecd_data_file)" >> etc/selinux/plat_sepolicy.cil
	echo "(typetransition system_teecd system_data_file sock_file teecd_data_file)" >> etc/selinux/plat_sepolicy.cil
	echo "(typetransition system_teecd system_data_file lnk_file teecd_data_file)" >> etc/selinux/plat_sepolicy.cil
	echo "(typetransition system_teecd system_data_file file teecd_data_file)" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd keystore (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd keystore (file (ioctl read getattr lock open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd system_data_file (file (ioctl read getattr lock open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd system_server (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd system_server (file (ioctl read getattr lock open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (capability (fowner fsetid net_raw)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (tcp_socket (ioctl read write create connect getopt setopt name_connect)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd port (tcp_socket (name_connect)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (udp_socket (ioctl read write create connect getopt setopt)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd teecd_data_file (lnk_file (read create getattr setattr unlink)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd domain (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd domain (file (ioctl read getattr lock open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow coredomain system_teecd (unix_stream_socket (connectto)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow domain system_teecd (fd (use)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd init (unix_stream_socket (read write listen accept connectto)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd cpuctl_device (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (capability (sys_nice)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd vendor_file (file (ioctl read getattr lock execute open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (capability (dac_override)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd sysfs (file (ioctl read getattr lock open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd teecd_auth_exec (file (read getattr map execute entrypoint open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd sysfs_tee (dir (ioctl read getattr lock search open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd sysfs_tee (file (ioctl read getattr lock map open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd sysfs_tee (lnk_file (ioctl read getattr lock map open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd sysfs_tee (file (ioctl read getattr lock map open)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow system_teecd dnsproxyd_socket (sock_file (write)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd self (capability (dac_override)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd teecd_device (chr_file (ioctl read write getattr lock append open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd teecd_data_file (dir (ioctl read write create getattr setattr lock rename add_name remove_name reparent search rmdir open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd system_data_file (dir (ioctl read write getattr lock add_name remove_name search open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_teecd teecd_data_file (file (ioctl read write create getattr setattr lock append unlink rename open)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow init tee_multi_user_socket (sock_file (create setattr unlink)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow tee_multi_user_socket tmpfs (filesystem (associate)))" >> etc/selinux/plat_sepolicy.cil

	#echo "(dontaudit teecd hal_keymaster_default (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	#echo "(dontaudit teecd hal_gatekeeper_default (process (getattr)))" >> etc/selinux/plat_sepolicy.cil

	# Add type attribute
	sed -i '/(typeattributeset dev_type (teelog_device device ashmem_device ashmem_libcutils_device audio_device binder_device hwbinder_device/d' etc/selinux/plat_sepolicy.cil
	sed -i '/(typeattributeset file_type (teecd_auth_exec adbd_exec aidl_lazy_test_server_exec apexd_exec appdomain_tmpfs app_zygote_tmpfs/d' etc/selinux/plat_sepolicy.cil
	sed -i '/(typeattributeset exec_type (teecd_auth_exec adbd_exec aidl_lazy_test_server_exec apexd_exec bootanim_exec bootstat_exec bufferhubd_exec/d' etc/selinux/plat_sepolicy.cil
	sed -i '/(typeattributeset mlstrustedobject (shmem_device ashmem_libcutils_device binder_device/d' etc/selinux/plat_sepolicy.cil
	sed -i '/(typeattributeset coredomain (adbd aidl_lazy_test_server apexd/d' etc/selinux/plat_sepolicy.cil
	sed -i '/(typeattributeset domain (system_teecd adbd aidl_lazy_test_server apexd app_zygote/d' etc/selinux/plat_sepolicy.cil
	
	echo "(typeattributeset dev_type (teelog_device device ashmem_device ashmem_libcutils_device audio_device binder_device hwbinder_device vndbinder_device block_device camera_device dm_device dm_user_device keychord_device loop_control_device loop_device pmsg_device radio_device ram_device rtc_device vd_device vold_device console_device fscklogs gpu_device graphics_device hw_random_device input_device port_device lowpan_device mtp_device nfc_device ptmx_device kmsg_device kmsg_debug_device null_device random_device secure_element_device sensors_device serial_device socket_device owntty_device tty_device video_device zero_device fuse_device iio_device ion_device dmabuf_heap_device dmabuf_system_heap_device dmabuf_system_secure_heap_device qtaguid_device watchdog_device uhid_device uio_device tun_device usbaccessory_device usb_device usb_serial_device gnss_device properties_device properties_serial property_info hci_attach_dev rpmsg_device root_block_device frp_block_device system_block_device recovery_block_device boot_block_device userdata_block_device cache_block_device swap_block_device metadata_block_device misc_block_device super_block_device sdcard_block_device userdata_sysdev rootdisk_sysdev ppp_device tee_device kvm_device ))" >> etc/selinux/plat_sepolicy.cil
	echo "(typeattributeset file_type (teecd_auth_exec adbd_exec aidl_lazy_test_server_exec apexd_exec appdomain_tmpfs app_zygote_tmpfs audioserver_tmpfs bootanim_exec bootstat_exec bufferhubd_exec cameraserver_exec cameraserver_tmpfs charger_exec crash_dump_exec credstore_exec dhcp_exec diced_exec dnsmasq_exec drmserver_exec drmserver_socket dumpstate_exec e2fs_exec extra_free_kbytes_exec unlabeled system_file system_asan_options_file system_event_log_tags_file system_lib_file system_bootstrap_lib_file system_group_file system_linker_exec system_linker_config_file system_passwd_file system_seccomp_policy_file system_security_cacerts_file tcpdump_exec system_zoneinfo_file cgroup_desc_file cgroup_desc_api_file vendor_cgroup_desc_file task_profiles_file task_profiles_api_file vendor_task_profiles_file art_apex_dir linkerconfig_file incremental_control_file vendor_hal_file vendor_file vendor_app_file vendor_configs_file same_process_hal_file vndk_sp_file vendor_framework_file vendor_overlay_file vendor_public_lib_file vendor_public_framework_file vendor_keylayout_file vendor_keychars_file vendor_idc_file vendor_uuid_mapping_config_file vendor_vm_file vendor_vm_data_file metadata_file vold_metadata_file gsi_metadata_file gsi_public_metadata_file password_slot_metadata_file apex_metadata_file ota_metadata_file metadata_bootstat_file userspace_reboot_metadata_file staged_install_file watchdog_metadata_file dev_cpu_variant runtime_event_log_tags_file logcat_exec cgroup_rc_file coredump_file system_data_root_file system_data_file packages_list_file game_mode_intervention_list_file vendor_data_file unencrypted_data_file install_data_file drm_data_file adb_data_file anr_data_file tombstone_data_file tombstone_wifi_data_file apex_data_file apk_data_file apk_tmp_file apk_private_data_file apk_private_tmp_file dalvikcache_data_file ota_data_file ota_package_file user_profile_root_file user_profile_data_file profman_dump_data_file prereboot_data_file resourcecache_data_file shell_data_file property_data_file bootchart_data_file dropbox_data_file heapdump_data_file nativetest_data_file shell_test_data_file ringtone_file preloads_data_file preloads_media_file dhcp_data_file server_configurable_flags_data_file staging_data_file vendor_apex_file mnt_media_rw_file mnt_user_file mnt_pass_through_file mnt_expand_file mnt_sdcard_file storage_file mnt_media_rw_stub_file storage_stub_file mnt_vendor_file mnt_product_file apex_mnt_dir apex_info_file postinstall_mnt_dir postinstall_file postinstall_apex_mnt_dir mirror_data_file adb_keys_file apex_system_server_data_file apex_module_data_file apex_ota_reserved_file apex_rollback_data_file appcompat_data_file audio_data_file audioserver_data_file bluetooth_data_file bluetooth_logs_data_file bootstat_data_file boottrace_data_file camera_data_file credstore_data_file gatekeeper_data_file incident_data_file keychain_data_file keystore_data_file media_data_file media_rw_data_file misc_user_data_file net_data_file network_watchlist_data_file nfc_data_file nfc_logs_data_file radio_data_file recovery_data_file shared_relro_file snapshotctl_log_data_file stats_data_file systemkeys_data_file textclassifier_data_file trace_data_file vpn_data_file wifi_data_file zoneinfo_data_file vold_data_file iorapd_data_file tee_data_file update_engine_data_file update_engine_log_data_file method_trace_data_file gsi_data_file radio_core_data_file app_data_file privapp_data_file system_app_data_file cache_file overlayfs_file cache_backup_file cache_private_backup_file cache_recovery_file efs_file wallpaper_file shortcut_manager_icons icon_file asec_apk_file asec_public_file asec_image_file backup_data_file bluetooth_efs_file fingerprintd_data_file fingerprint_vendor_data_file app_fuse_file face_vendor_data_file iris_vendor_data_file adbd_socket bluetooth_socket dnsproxyd_socket dumpstate_socket fwmarkd_socket lmkd_socket logd_socket logdr_socket logdw_socket mdns_socket mdnsd_socket misc_logd_file mtpd_socket property_socket racoon_socket recovery_socket rild_socket rild_debug_socket snapuserd_socket snapuserd_proxy_socket statsdw_socket system_wpa_socket system_ndebug_socket system_unsolzygote_socket tombstoned_crash_socket tombstoned_java_trace_socket tombstoned_intercept_socket traced_consumer_socket traced_perf_socket traced_producer_socket uncrypt_socket wpa_socket zygote_socket heapprofd_socket gps_control pdx_display_dir pdx_performance_dir pdx_bufferhub_dir pdx_display_client_endpoint_socket pdx_display_manager_endpoint_socket pdx_display_screenshot_endpoint_socket pdx_display_vsync_endpoint_socket pdx_performance_client_endpoint_socket pdx_bufferhub_client_endpoint_socket file_contexts_file mac_perms_file property_contexts_file seapp_contexts_file sepolicy_file service_contexts_file keystore2_key_contexts_file vendor_service_contexts_file hwservice_contexts_file vndservice_contexts_file vendor_kernel_modules system_dlkm_file audiohal_data_file fingerprintd_exec flags_health_check_exec fsck_exec gatekeeperd_exec hal_graphics_composer_server_tmpfs hwservicemanager_exec idmap_exec init_exec init_tmpfs inputflinger_exec installd_exec iorap_inode2filename_exec iorap_inode2filename_tmpfs iorap_prefetcherd_exec iorap_prefetcherd_tmpfs iorapd_exec iorapd_tmpfs keystore_exec llkd_exec lmkd_exec logd_exec mediadrmserver_exec mediaextractor_exec mediaextractor_tmpfs mediametrics_exec mediaserver_exec mediaserver_tmpfs mediaswcodec_exec mtp_exec netd_exec netutils_wrapper_exec performanced_exec ppp_exec profman_exec racoon_exec recovery_persist_exec recovery_refresh_exec rs_exec runas_exec sdcardd_exec servicemanager_exec sgdisk_exec shell_exec simpleperf_app_runner_exec statsd_exec su_exec surfaceflinger_tmpfs system_server_tmpfs tombstoned_exec toolbox_exec traced_tmpfs tzdatacheck_exec ueventd_tmpfs uncrypt_exec update_engine_exec update_verifier_exec usbd_exec vdc_exec vendor_misc_writer_exec vendor_shell_exec vendor_toolbox_exec virtual_touchpad_exec vold_exec vold_prepare_subdirs_exec watchdogd_exec webview_zygote_exec webview_zygote_tmpfs wificond_exec wpantund_exec zygote_tmpfs zygote_exec apex_test_prepostinstall_exec artd_exec atrace_exec audioserver_exec auditctl_exec automotive_display_service_exec blank_screen_exec blkid_exec boringssl_self_test_exec vendor_boringssl_self_test_exec boringssl_self_test_marker bpfloader_exec canhalconfigurator_exec clatd_exec compos_verify_exec composd_exec cppreopts_exec crosvm_exec crosvm_tmpfs derive_classpath_exec derive_sdk_exec dex2oat_exec dexoptanalyzer_exec dexoptanalyzer_tmpfs dmesgd_exec dumpstate_tmpfs evsmanagerd_exec storaged_data_file wm_trace_data_file accessibility_trace_data_file perfetto_traces_data_file perfetto_traces_bugreport_data_file perfetto_configs_data_file sdk_sandbox_system_data_file sdk_sandbox_data_file app_exec_data_file rollback_data_file checkin_data_file ota_image_data_file gsi_persistent_data_file emergency_data_file profcollectd_data_file apex_art_data_file apex_art_staging_data_file apex_compos_data_file apex_appsearch_data_file apex_permission_data_file apex_scheduling_data_file apex_tethering_data_file apex_wifi_data_file font_data_file dmesgd_data_file odrefresh_data_file odsign_data_file odsign_metrics_file virtualizationservice_data_file environ_system_data_file bootanim_data_file fd_server_exec compos_exec compos_key_helper_exec sepolicy_metadata_file sepolicy_test_file prng_seeder_socket fsverity_init_exec fwk_bufferhub_exec gki_apex_prepostinstall_exec gpuservice_exec gsid_exec hal_allocator_default_exec heapprofd_exec heapprofd_tmpfs hidl_lazy_test_server_exec incident_exec incident_helper_exec incidentd_exec iw_exec linkerconfig_exec lpdumpd_exec mdnsd_exec mediatranscoding_exec mediatranscoding_tmpfs mediatuner_exec migrate_legacy_obb_data_exec mm_events_exec mtectrl_exec odrefresh_exec odsign_exec otapreopt_chroot_exec otapreopt_slot_exec perfetto_exec perfetto_tmpfs postinstall_exec postinstall_dexopt_exec postinstall_dexopt_tmpfs preloads_copy_exec preopt2cachename_exec prng_seeder_exec profcollectd_exec remount_exec rss_hwm_reset_exec simpleperf_exec simpleperf_boot_data_file snapshotctl_exec snapuserd_exec stats_exec storaged_exec surfaceflinger_exec system_server_startup_tmpfs system_suspend_exec traced_exec traced_perf_exec traced_probes_exec traced_probes_tmpfs vehicle_binding_util_exec viewcompiler_exec viewcompiler_tmpfs virtualizationservice_exec wait_for_keymaster_exec ))" >> etc/selinux/plat_sepolicy.cil
	echo "(typeattributeset exec_type (teecd_auth_exec adbd_exec aidl_lazy_test_server_exec apexd_exec bootanim_exec bootstat_exec bufferhubd_exec cameraserver_exec charger_exec crash_dump_exec credstore_exec dhcp_exec diced_exec dnsmasq_exec drmserver_exec dumpstate_exec e2fs_exec extra_free_kbytes_exec tcpdump_exec logcat_exec fingerprintd_exec flags_health_check_exec fsck_exec gatekeeperd_exec hwservicemanager_exec idmap_exec init_exec inputflinger_exec installd_exec iorap_inode2filename_exec iorap_prefetcherd_exec iorapd_exec keystore_exec llkd_exec lmkd_exec logd_exec mediadrmserver_exec mediaextractor_exec mediametrics_exec mediaserver_exec mediaswcodec_exec mtp_exec netd_exec netutils_wrapper_exec performanced_exec ppp_exec profman_exec racoon_exec recovery_persist_exec recovery_refresh_exec rs_exec runas_exec sdcardd_exec servicemanager_exec sgdisk_exec shell_exec simpleperf_app_runner_exec statsd_exec su_exec tombstoned_exec toolbox_exec tzdatacheck_exec uncrypt_exec update_engine_exec update_verifier_exec usbd_exec vdc_exec vendor_misc_writer_exec vendor_shell_exec vendor_toolbox_exec virtual_touchpad_exec vold_exec vold_prepare_subdirs_exec watchdogd_exec webview_zygote_exec wificond_exec wpantund_exec zygote_exec apex_test_prepostinstall_exec artd_exec atrace_exec audioserver_exec auditctl_exec automotive_display_service_exec blank_screen_exec blkid_exec boringssl_self_test_exec vendor_boringssl_self_test_exec bpfloader_exec canhalconfigurator_exec clatd_exec compos_verify_exec composd_exec cppreopts_exec crosvm_exec derive_classpath_exec derive_sdk_exec dex2oat_exec dexoptanalyzer_exec dmesgd_exec evsmanagerd_exec fd_server_exec compos_exec compos_key_helper_exec fsverity_init_exec fwk_bufferhub_exec gki_apex_prepostinstall_exec gpuservice_exec gsid_exec hal_allocator_default_exec heapprofd_exec hidl_lazy_test_server_exec incident_exec incident_helper_exec incidentd_exec iw_exec linkerconfig_exec lpdumpd_exec mdnsd_exec mediatranscoding_exec mediatuner_exec migrate_legacy_obb_data_exec mm_events_exec mtectrl_exec odrefresh_exec odsign_exec otapreopt_chroot_exec otapreopt_slot_exec perfetto_exec postinstall_exec postinstall_dexopt_exec preloads_copy_exec preopt2cachename_exec prng_seeder_exec profcollectd_exec remount_exec rss_hwm_reset_exec simpleperf_exec snapshotctl_exec snapuserd_exec stats_exec storaged_exec surfaceflinger_exec system_suspend_exec traced_exec traced_perf_exec traced_probes_exec vehicle_binding_util_exec viewcompiler_exec virtualizationservice_exec wait_for_keymaster_exec ))" >> etc/selinux/plat_sepolicy.cil
	echo "(typeattributeset mlstrustedobject (system_teecd sysfs_tee ashmem_device ashmem_libcutils_device binder_device hwbinder_device pmsg_device gpu_device mtp_device ptmx_device kmsg_device null_device random_device owntty_device zero_device fuse_device ion_device dmabuf_heap_device dmabuf_system_heap_device dmabuf_system_secure_heap_device uhid_device tun_device usbaccessory_device usb_device proc_qtaguid_ctrl proc_qtaguid_stat selinuxfs cgroup sysfs sysfs_bluetooth_writable sysfs_kernel_notes sysfs_nfc_power_writable sysfs_vendor_sched inotify devpts fuse sdcardfs vfat exfat debugfs_trace_marker debugfs_tracing debugfs_tracing_debug functionfs anr_data_file tombstone_data_file apk_tmp_file apk_private_tmp_file ota_package_file user_profile_data_file shell_data_file heapdump_data_file ringtone_file media_rw_data_file radio_data_file shared_relro_file trace_data_file method_trace_data_file system_app_data_file cache_file cache_backup_file cache_recovery_file wallpaper_file shortcut_manager_icons asec_apk_file backup_data_file app_fuse_file dnsproxyd_socket fwmarkd_socket logd_socket logdr_socket logdw_socket mdnsd_socket property_socket statsdw_socket system_ndebug_socket system_unsolzygote_socket tombstoned_crash_socket tombstoned_java_trace_socket traced_consumer_socket traced_perf_socket traced_producer_socket heapprofd_socket pdx_display_client_endpoint_socket pdx_display_manager_endpoint_socket pdx_display_screenshot_endpoint_socket pdx_display_vsync_endpoint_socket pdx_performance_client_endpoint_socket pdx_bufferhub_client_endpoint_socket system_server_tmpfs traced_tmpfs wm_trace_data_file prng_seeder_socket heapprofd_tmpfs ))" >> etc/selinux/plat_sepolicy.cil
	echo "(typeattributeset coredomain (system_teecd adbd aidl_lazy_test_server apexd app_zygote atrace audioserver blkid blkid_untrusted bluetooth bootanim bootstat bpfloader bufferhubd cameraserver charger crash_dump credstore dhcp diced dnsmasq drmserver dumpstate e2fs ephemeral_app evsmanagerd extra_free_kbytes fastbootd fingerprintd flags_health_check fsck fsck_untrusted gatekeeperd gmscore_app gpuservice healthd heapprofd hwservicemanager idmap incident incident_helper incidentd init inputflinger installd iorap_inode2filename iorap_prefetcherd iorapd isolated_app kernel keystore llkd lmkd logd logpersist mdnsd mediadrmserver mediaextractor mediametrics mediaprovider mediaserver mediaswcodec mediatranscoding modprobe mtp netd netutils_wrapper network_stack nfc otapreopt_chroot perfetto performanced platform_app postinstall ppp priv_app prng_seeder profman racoon radio recovery recovery_persist recovery_refresh rs rss_hwm_reset runas runas_app sdcardd secure_element servicemanager sgdisk shared_relro shell simpleperf simpleperf_app_runner slideshow statsd su surfaceflinger system_app system_server tombstoned toolbox traced traced_perf traced_probes traceur_app tzdatacheck ueventd uncrypt untrusted_app untrusted_app_30 untrusted_app_29 untrusted_app_27 untrusted_app_25 update_engine update_verifier usbd vdc virtual_touchpad vold vold_prepare_subdirs watchdogd webview_zygote wificond wpantund zygote apex_test_prepostinstall apexd_derive_classpath artd auditctl automotive_display_service blank_screen boringssl_self_test canhalconfigurator clatd compos_fd_server compos_verify composd cppreopts crosvm derive_classpath derive_sdk dex2oat dexoptanalyzer dmesgd fsverity_init fwk_bufferhub gki_apex_prepostinstall gsid hal_allocator_default hidl_lazy_test_server iw linkerconfig lpdumpd mediaprovider_app mediatuner migrate_legacy_obb_data mm_events mtectrl odrefresh odsign otapreopt_slot permissioncontroller_app postinstall_dexopt preloads_copy preopt2cachename profcollectd remote_prov_app remount sdk_sandbox simpleperf_boot snapshotctl snapuserd stats storaged system_server_startup system_suspend vehicle_binding_util viewcompiler virtualizationservice wait_for_keymaster ))" >> etc/selinux/plat_sepolicy.cil
	echo "(typeattributeset domain (system_teecd adbd aidl_lazy_test_server apexd app_zygote atrace audioserver blkid blkid_untrusted bluetooth bootanim bootstat bpfloader bufferhubd cameraserver charger charger_vendor crash_dump credstore dhcp diced dnsmasq drmserver dumpstate e2fs ephemeral_app evsmanagerd extra_free_kbytes fastbootd fingerprintd flags_health_check fsck fsck_untrusted gatekeeperd gmscore_app gpuservice healthd heapprofd hwservicemanager idmap incident incident_helper incidentd init inputflinger installd iorap_inode2filename iorap_prefetcherd iorapd isolated_app kernel keystore llkd lmkd logd logpersist mdnsd mediadrmserver mediaextractor mediametrics mediaprovider mediaserver mediaswcodec mediatranscoding modprobe mtp netd netutils_wrapper network_stack nfc otapreopt_chroot perfetto performanced platform_app postinstall ppp priv_app prng_seeder profman racoon radio recovery recovery_persist recovery_refresh rs rss_hwm_reset runas runas_app sdcardd secure_element servicemanager sgdisk shared_relro shell simpleperf simpleperf_app_runner slideshow statsd su surfaceflinger system_app system_server tee tombstoned toolbox traced traced_perf traced_probes traceur_app tzdatacheck ueventd uncrypt untrusted_app untrusted_app_30 untrusted_app_29 untrusted_app_27 untrusted_app_25 update_engine update_verifier usbd vdc vendor_init vendor_misc_writer vendor_modprobe vendor_shell virtual_touchpad vndservicemanager vold vold_prepare_subdirs watchdogd webview_zygote wificond wpantund zygote apex_test_prepostinstall apexd_derive_classpath artd auditctl automotive_display_service blank_screen boringssl_self_test vendor_boringssl_self_test canhalconfigurator clatd compos_fd_server compos_verify composd cppreopts crosvm derive_classpath derive_sdk dex2oat dexoptanalyzer dmesgd fsverity_init fwk_bufferhub gki_apex_prepostinstall gsid hal_allocator_default hidl_lazy_test_server iw linkerconfig lpdumpd mediaprovider_app mediatuner migrate_legacy_obb_data mm_events mtectrl odrefresh odsign otapreopt_slot permissioncontroller_app postinstall_dexopt preloads_copy preopt2cachename profcollectd remote_prov_app remount sdk_sandbox simpleperf_boot snapshotctl snapuserd stats storaged system_server_startup system_suspend vehicle_binding_util viewcompiler virtualizationservice vzwomatrigger_app wait_for_keymaster ))" >> etc/selinux/plat_sepolicy.cil

	
	
	#-----------------------------vndk-lite --------------------------------------------------------	

	# Remove non use apex vndk
	rm -rf "system_ext/apex/com.android.vndk.v29"
	rm -rf "system_ext/apex/com.android.vndk.v30"
	rm -rf "system_ext/apex/com.android.vndk.v31"
	rm -rf "system_ext/apex/com.android.vndk.v32"

	cd ../d


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

)

sleep 1



# --------------------- erofs-vndklite or ext4-vndklite -------------------------------------------

if [ "$erofs" == "Y" ];then
	mkfs.erofs -E legacy-compress -zlz4hc -d2 s-erofs.img d/
	umount d
else
	umount d
	e2fsck -f -y s-ab-raw.img || true
	resize2fs -M s-ab-raw.img

	mv s-ab-raw.img s-vndklite.img
	chmod -R 777 s-vndklite.img
fi
	
	





