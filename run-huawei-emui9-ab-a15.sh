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
	echo "ro.lineage.version=22" >>  build.prop
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
	echo "persist.sys.bt.esco_transport_unit_size=16" >> build.prop
	
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
s
		# For FM Radio volume (# Hisi)
		echo "ro.connectivity.chiptype=hisi"  >> build.prop;
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
		
		# From iceows supl20 apk (# Hisi)
		echo "is_hisi_connectivity_chip=1" >> build.prop
		echo "ro.hardware.consumerir=hisi.hi6250" >> build.prop		
		echo "ro.hardware.hisupl=hi1102"  >> build.prop;
		
		# For FM Radio volume (# Hisi)
		echo "ro.connectivity.chiptype=hisi"  >> build.prop;
	fi

	# ANE-LX1 Huawei P20 Lite
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
		echo "ro.lineage.device=HWANE" >>  build.prop
				
		# From iceows supl20 apk (# Hisi)
		echo "is_hisi_connectivity_chip=1" >> build.prop
		echo "ro.hardware.consumerir=hisi.hi6250" >> build.prop		
		echo "ro.hardware.hisupl=hi1102"  >> build.prop;
		
		# For FM Radio volume (# Hisi)
		echo "ro.connectivity.chiptype=hisi"  >> build.prop;
	fi	

	# BND-L21
	if [ "$model" == "BND-L21" ];then

		echo "ro.product.brand=[HONOR]" >> build.prop
		echo "ro.product.device=HWBND-H" >> build.prop	
		echo "ro.product.system.device=HWBND-H" >>  build.prop
		echo "ro.product.system.brand=HONOR" >>  build.prop	
		echo "ro.product.product.device=HWBND-H" >>  product/etc/build.prop
		echo "ro.product.product.brand=HONOR" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWBND-H" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HONOR" >>  system_ext/etc/build.prop
		echo "ro.build.product=BND" >> build.prop
		
		# Perhaps also replace fingerprint
		#[ro.build.description]: [BND-L21-user 9.1.0 HUAWEIBND-L21 194-LGRP2-OVS release-keys]
		#[ro.build.display.id]: [BND-L21 9.1.0.174(C185E2R1P2)]
		#[ro.build.fingerprint]: [HONOR/BND-L21/HWBND-H:9/HONORBND-L21/9.1.0.174C185:user/release-keys]
		
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
	xattr -w security.selinux u:object_r:system_file:s0  bin/79b77788-9789-4a7a-a2be-b60155eef5f4.sec
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
	
	





