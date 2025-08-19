#!/bin/bash

#Usage:
#sudo bash run-huawei-emui10-ab-a13.sh  [/path/to/system.img] [version] [model device] [boot animation]
#cleanups
#A13 version
umount d

set -ex

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"


srcFile="$1"
versionNumber="$2"
model="$3"
bootanim="$4"


if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash make-erofs.sh  [/path/to/system.img]"
	exit 1
fi

# Need install sim2img and img2simg before
simg2img "$srcFile" s-ab-raw.img || cp "$srcFile" s-ab-raw.img

rm -Rf tmp

mkdir -p d tmp
e2fsck -y -f s-ab-raw.img
resize2fs s-ab-raw.img 4500M
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
	echo "ro.modversion=$versionNumber" >>  build.prop

		
	# set default sound
	echo "ro.config.ringtone=Ring_Synth_04.ogg" >>  build.prop
	echo "ro.config.notification_sound=OnTheHunt.ogg">>  build.prop
	echo "ro.config.alarm_alert=Argon.ogg">>  build.prop

  	# Debug Huawei Off=0/On=1
	echo "persist.sys.hiview.debug=1" >> build.prop
	echo "persist.sys.huawei.debug.on=1" >> build.prop

	# Enable wireless display (Cast/Miracast)
	echo "persist.debug.wfd.enable=1" >>  build.prop
	
	# Display
	echo "ro.surface_flinger.running_without_sync_framework=true" >>  build.prop

	# Graphics
	echo "debug.sf.disable_backpressure=1" >>  build.prop
	echo "debug.sf.latch_unsignaled=1" >>  build.prop

	# Color
	echo "persist.sys.sf.native_mode=1" >> build.prop
	echo "persist.sys.sf.color_saturation=1.0" >> build.prop
	
	# CPU
	echo "persist.sys.boost.byeachfling=true" >> build.prop
	echo "persist.sys.boost.skipframe=3" >> build.prop
	echo "persist.sys.boost.durationms=1000" >> build.prop	
		
	echo "persist.sys.cpuset.enable=1" >> build.prop
	echo "persist.sys.cpuset.subswitch=16" >> build.prop	
	echo "persist.sys.performance=true" >> build.prop
	

	# Usb (adb)
	echo "persist.sys.usb.config=adb" >> build.prop

	# echo "ro.adb.secure=0" >> build.prop
	# echo "persist.service.adb.enable=1 " >> build.prop
	# echo "service.adb.root=1" >> build.prop		

	
	#Performance android 13
	echo "debug.performance.tuning=1" >> build.prop
	


	#-----------------------------File copy -----------------------------------------------------
	
        # -----------------------------VNDK fixe ----------------------- #	
	cp "$origin/files-patch/system/bin/vndk-detect" "bin/vndk-detect"
	cp "$origin/files-patch/system/etc/init/vndk.rc" "etc/init/vndk.rc"
	
	
        # -----------------------------IA Config Huawei -------------------- #
        mkdir etc/xml
	cp "$origin/files-patch/system/etc/xml/iaware_config_cust.bin" etc/xml/iaware_config_cust.bin
		
	# -----------------------------APN Huawei -------------------------- #
	cp "$origin/files-patch/system/product/etc/apns-conf.xml" product/etc/apns-conf.xml

	# -----------------------------Huawei specific tweak ---------------------------- #	
	cp "$origin/files-patch/system/etc/init/init.emui10.huawei.iaware.a15.rc" "etc/init/init.huawei.iaware.a15.rc"
	xattr -w security.selinux u:object_r:system_file:s0 "etc/init/init.huawei.iaware.a15.rc"
	cp "$origin/files-patch/system/etc/init/init.emui10.huawei.os.a15.rc" "etc/init/init.huawei.os.a15.rc"
	xattr -w security.selinux u:object_r:system_file:s0 "etc/init/init.huawei.os.a15.rc"
	cp "$origin/files-patch/system/etc/init/init.emui10.huawei.os.common.rc" "etc/init/init.huawei.os.common.rc"
	xattr -w security.selinux u:object_r:system_file:s0 "etc/init/init.huawei.os.common.rc"
	
	# -----------------------------PHH Exec ---------------------------- #
	cp "$origin/files-patch/system/bin/rw-system.sh" "bin/rw-system.sh"
	xattr -w security.selinux u:object_r:phhsu_exec:s0 "bin/rw-system.sh"
	
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

	# Huawei P40 Pro
	if [ "$model" == "ELS-N29" ];then
	
		echo "ro.product.system.device=HWELS" >>  build.prop
		echo "ro.product.system.brand=HUAWEI" >>  build.prop	
		echo "ro.product.device=HWELS" >> build.prop
		echo "ro.product.brand=HUAWEI" >> build.prop
		echo "ro.product.product.device=HWELS" >>  product/etc/build.prop
		echo "ro.product.product.brand=HUAWEI" >>  product/etc/build.prop	
		echo "ro.product.system_ext.device=HWCLT" >>  system_ext/etc/build.prop
		echo "ro.product.system_ext.brand=HUAWEI" >>  system_ext/etc/build.prop

		# HISI chip
		
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

		# Inteli Art for Camera
		echo "ro.camera.master_ai_default=off" >>  build.prop
		echo "ro.camera.front_ai_default=off" >>  build.prop
		echo "ro.hwcamera.ai_resolution=3264x2448" >>  build.prop
		
		# Android10 Huawei iaware
		echo "ro.config.enable_iaware=true" >>  build.prop
	
	fi

	mkdir media
	mkdir media/audio
	mkdir media/audio/ui
	cp "product/media/audio/ui/Lock.ogg" "media/audio/ui/Lock.ogg"
	cp "product/media/audio/ui/Unlock.ogg" "media/audio/ui/Unlock.ogg"
	cp "product/media/audio/ui/Trusted.ogg" "media/audio/ui/Trusted.ogg"


	# Remove duplicate media audio
	rm -rf "product/media/audio/ringtones/ANDROMEDA.ogg"
	rm -rf "product/media/audio/ringtones/CANISMAJOR.ogg"
	rm -rf "product/media/audio/ringtones/URSAMINOR.ogg"
	
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
	
	#----------------------------- SELinux rules Now include in huawei.te ------------------------------	

	#----------------------------- Set prop like vendor huawei -----------------------------------------		
	# Kirin prop
	echo "persist.kirin.media.hires.enable=true" >> build.prop
	echo "persist.kirin.media.lowlatency.enable=true" >> build.prop
	echo "persist.kirin.media.offload.enable=true"  >> build.prop
	echo "persist.kirin.media.usbvoice.enable=true"  >> build.prop
	echo "persist.kirin.media.usbvoice.name=USB-Audio - HUAWEI GLASS"  >> build.prop
	
	echo "persist.kirin.touch_move_opt=1"  >> build.prop
	echo "persist.kirin.touch_vsync_opt=1"  >> build.prop
	echo "persist.kirin.touchevent_opt=1"  >> build.prop

	echo "ro.kirin.config.callinwifi=200,6"  >> build.prop
	
	echo "ro.kirin.config.hw_perfgenius=true"  >> build.prop
	echo "ro.kirin.config.hw_board_ipa=true"  >> build.prop
	echo "ro.kirin.product.platform=kirin990"  >> build.prop

	
	# Enable lowlatency
	echo "persist.media.lowlatency.enable=true" >> build.prop

	#----------------------------- Make vndklite ------------------------------
	cd ..
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

# Huawei P20 Pro
if [ "$model" == "CLT-L29" ];then
	rm -Rf s-erofs.img
	./mkfs.erofs -E legacy-compress -zlz4 -d2 s-erofs.img d/
fi

umount d
sleep 5

if [ "$model" == "ELS-N29" ];then
	e2fsck -f -y s-ab-raw.img || true
	resize2fs -M s-ab-raw.img

	mv s-ab-raw.img s-p40.img
	chmod -R 777 s-p40.img
fi




