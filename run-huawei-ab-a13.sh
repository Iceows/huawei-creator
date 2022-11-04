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
	echo "Usage: sudo bash run-huawei-ab-a13.sh [/path/to/system.img] [version] [model device] [bootanimation]"
	echo "version=LeaOS A13"
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
	
	echo "#" >> build.prop
	echo "## Adding hi6250 props" >> build.prop
	echo "#" >> build.prop
	
	sed -i "/ro.system.build.type/d" build.prop 
	sed -i "/ro.build.type/d" build.prop 	
	sed -i "/ro.product.model/d" build.prop
	
	echo "ro.system.build.type=userdebug" >> build.prop
	echo "ro.build.type=userdebug" >> build.prop
	echo "ro.product.model=ANE-LX1" >> build.prop
	
	
	# change product and system prop
	sed -i "/ro.product.system.model/d" build.prop 
	sed -i "/ro.product.system.brand/d" build.prop 
	sed -i "/ro.product.system.device/d" build.prop 
	sed -i "/ro.product.system.name/d" build.prop 
	
	echo "ro.product.system.model=$model" >>  build.prop
	echo "ro.product.system.device=HWANE" >>  build.prop
	echo "ro.product.system.brand=HUAWEI" >>  build.prop
	echo "ro.product.system.name=LeaOS" >>  build.prop
	
	sed -i "/ro.product.manufacturer/d" build.prop
	sed -i "/ro.product.model/d" build.prop
	sed -i "/ro.product.device/d" build.prop
	sed -i "/ro.product.name/d" build.prop
	
	echo "ro.product.manufacturer=HUAWEI" >> build.prop
	echo "ro.product.model=$model" >> build.prop
	echo "ro.product.device=HWANE" >> build.prop
	echo "ro.product.name=$model" >> build.prop
	echo "ro.product.brand=HUAWEI" >> build.prop
	
	# Safetynet CTS profile
	echo "ro.build.fingerprint=HUAWEI/ANE-LX1/HWANE:9/HUAWEIANE-L01/9.1.0.368C432:user/release-keys" >> build.prop
	echo "ro.build.version.security_patch=2020-08-01" >> build.prop
	

	# set default sound
	echo "ro.config.ringtone=Ring_Synth_04.ogg" >>  build.prop
	echo "ro.config.notification_sound=OnTheHunt.ogg">>  build.prop
	echo "ro.config.alarm_alert=Argon.ogg">>  build.prop

 
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
	
	#----------------------------- offline charging fix ----------------------------------------
	# remove AOSP charger img
	rm -rf etc/charger

	# unzip new img for all resolution
	cd etc/
	unzip "$origin/files-patch/system/etc/charger.zip"
	cd ..
	
	# cp new offline charger animation
	cp "$origin/files-patch/system/bin/offlinecharger" bin/offlinecharger
	chown root:2000 bin/offlinecharger
	xattr -w security.selinux u:object_r:charger_exec:s0 bin/offlinecharger
	chmod 755 bin/offlinecharger


	# Fix init.rc	
	sed -i '13iimport /vendor/etc/init/${ro.bootmode}/init.${ro.bootmode}.rc' etc/init/hw/init.rc
	sed -i -e "s/service charger \/bin\/charger/service charger \/bin\/offlinecharger -p/g" etc/init/hw/init.rc 
	
	sed -i -e "s/user system/user root/g" etc/init/hw/init.rc
	sed -i -e "s/group system shell graphics input wakelock/group root system shell graphics input wakelock/g" etc/init/hw/init.rc


	#-----------------------------File copy -----------------------------------------------------

	# rw-system custom for Huawei device
	cp "$origin/files-patch/system/bin/rw-system.sh" bin/rw-system.sh
	xattr -w security.selinux u:object_r:phhsu_exec:s0 bin/rw-system.sh

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
	
	# NFC
	# ANE-LX1 Huawei P20 Lite 2017
	if [ "$model" == "ANE-LX1" ];then
		# NFC 
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_anne_L31.conf" etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_anne_L31.conf" etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_anne_L31.conf" etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_anne_L31.conf" etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp_RF.conf
		
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_anne_L31.conf" product/etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  product/etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_anne_L31.conf" product/etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_anne_L31.conf" product/etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_anne_L31.conf" product/etc/libnfc-nxp_RF.conf
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
	xattr -w security.selinux u:object_r:system_file:s0  bin/tee_auth_daemon
	cp "$origin/files-patch/system/bin/79b77788-9789-4a7a-a2be-b60155eef5f4.sec" bin/79b77788-9789-4a7a-a2be-b60155eef5f4.sec
	xattr -w security.selinux u:object_r:system_file:s0  bin/79b77788-9789-4a7a-a2be-b60155eef5f4
	
	
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
	
	
	
	#----------------------------- SELinux rules Now include in huawei.te --------------------------	
	
	
	

	#-----------------------------vndk-lite --------------------------------------------------------	
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

umount d

e2fsck -f -y s-ab-raw.img || true
resize2fs -M s-ab-raw.img

mv s-ab-raw.img s-vndklite.img




