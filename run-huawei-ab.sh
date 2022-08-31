#!/bin/bash

#Usage:
#sudo bash run-huawei-abonly.sh  [/path/to/system.img] [version] [model device] [huawei animation]
#cleanups
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
	rm -rf /data
	rm -rf /data/sec_storage_data
	rm -rf /data/sec_storage_data_users
	
	mkdir splash2
	chown root:root splash2
	chmod 777 splash2
	xattr -w security.selinux u:object_r:rootfs:s0 splash2
	
	mkdir modem_log
	chown root:root modem_log
	chmod 777 modem_log
	xattr -w security.selinux u:object_r:rootfs:s0 modem_log
	
	mkdir /data
	
	mkdir /data/sec_storage_data
	chown root:root /data/sec_storage_data
	chmod 777 /data/sec_storage_data
	xattr -w security.selinux u:object_r:teecd_data_file_system:s0 /data/sec_storage_data
	
	mkdir /data/sec_storage_data_users
	chown root:root /data/sec_storage_data_users
	chmod 777 /data/sec_storage_data_users
	xattr -w security.selinux u:object_r:teecd_data_file_system:s0 /data/sec_storage_data_users
    
	
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
	sed -i "/ro.product.system_ext.model/d" build.prop 
	sed -i "/ro.product.system_ext.brand/d" build.prop 
	sed -i "/ro.product.system_ext.device/d" build.prop 
	sed -i "/ro.product.system_ext.name/d" build.prop 
	
	sed -i "/ro.product.product.model/d" build.prop 
	sed -i "/ro.product.product.brand/d" build.prop 
	sed -i "/ro.product.product.device/d" build.prop 
	sed -i "/ro.product.product.name/d" build.prop 
	
	echo "ro.product.system_ext.model=$model" >>  build.prop
	echo "ro.product.system_ext.brand=Huawei" >>  build.prop
	echo "ro.product.system_ext.device=anne" >>  build.prop
	echo "ro.product.system_ext.name=LeaOS" >>  build.prop
	
	echo "ro.product.product.model=$model" >>  build.prop
	echo "ro.product.product.brand=Huawei" >>  build.prop
	echo "ro.product.product.device=anne" >>  build.prop
	echo "ro.product.product.name=LeaOS" >>  build.prop
	

	sed -i "/ro.product.model/d" build.prop
	sed -i "/ro.product.system.model/d" build.prop
	sed -i "/ro.product.manufacturer/d" build.prop
	echo "ro.product.manufacturer=HUAWEI" >> build.prop
	echo "ro.product.system.model=ANE-LX1" >> build.prop
	echo "ro.product.model=ANE-LX1" >> build.prop


	
	# echo "ro.product.name
	# echo "ro.product.device

	# set default sound
	echo "ro.config.ringtone=Ring_Synth_04.ogg" >>  build.prop
	echo "ro.config.notification_sound=OnTheHunt.ogg">>  build.prop
	echo "ro.config.alarm_alert=Alarm_Classic.ogg">>  build.prop

	# set lineage version number for lineage build
	sed -i "/ro.lineage.version/d"  build.prop
	sed -i "/ro.lineage.display.version/d"  build.prop
	sed -i "/ro.modversion/d"  build.prop
	echo "ro.lineage.version=$versionNumber" >>  build.prop
	echo "ro.lineage.display.version=$versionNumber" >>  build.prop
	echo "ro.modversion=$versionNumber" >>  build.prop

 
	# LMK - for Android Kernel that support it - e
	echo "ro.lmk.debug=true" >>  build.prop
	
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
	
	# Debug Huawei Off
	echo "persist.sys.hiview.debug=0" >> build.prop
	echo "persist.sys.huawei.debug.on=0" >> build.prop
	

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
	# ANE- Huawei P20 Lite 2017
	if [ "$model" == "ANE-LX1" ];then
	
		for img in $(cd "$origin/files-patch/system/etc/charger/1080x2280"; echo *);do
			cp "$origin/files-patch/system/etc/charger/1080x2280/$img" etc/charger/1080x2280/$img
			xattr -w security.selinux u:object_r:system_file:s0 etc/charger/1080x2280/$img
		done
	
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
		
	fi
		
	# Fix LD_PRELOAD in vndk
	cp "$origin/files-patch/system/etc/init/vndk.rc" etc/init/vndk.rc
	xattr -w security.selinux u:object_r:system_file:s0  etc/init/vndk.rc
	
	# Tee Deamon
	cp "$origin/files-patch/system/bin/tee_auth_daemon" bin/tee_auth_daemon
	xattr -w security.selinux u:object_r:system_file:s0  bin/tee_auth_daemon
	cp "$origin/files-patch/system/bin/79b77788-9789-4a7a-a2be-b60155eef5f4.sec" bin/79b77788-9789-4a7a-a2be-b60155eef5f4.sec
	xattr -w security.selinux u:object_r:system_file:s0  bin/79b77788-9789-4a7a-a2be-b60155eef5f4
	
	
	
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
	

		
	#----------------------------- SELinux rules -----------------------------------------------------	
	
	# Fix platform_app, system_app
	echo "(allow platform_app nfc_service (service_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow platform_app cameradaemon_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_app default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_app cameradaemon_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	# oeminfo_nvm
	echo "(allow oeminfo_nvm block_device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow oeminfo_nvm device (chr_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow oeminfo_nvm self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow oeminfo_nvm default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	
	# hal_audio_default
	echo "(allow hal_audio_default hal_broadcastradio_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_audio_default audioserver (fifo_file (write)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_audio_default config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_audio_default default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_audio_default odm_etc_audio_algorithm (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_audio_default system_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	# Fix Google GMS denied 
	echo "(allow gmscore_app mnt_modem_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow gmscore_app mnt_media_rw_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil

	# Fix WPA suppliant	(cust_conn)
	echo "(allow wpa_hisi hi110x_cust_data_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow wpa_hisi default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow wpa_hisi config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow aptouch_daemon system_prop (file (open read write setattr getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow hisecd default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow hisecd config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow storage_info default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	# hi110x_daemon
	# Fix ls ioctl cmd	: 0x5413 : TIOCGWINSZ 
	echo "(allowx hi110x_daemon hi110x_daemon (ioctl fifo_file (0x5413)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hi110x_daemon default_prop (file (read open write getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hi110x_daemon self (fifo_file (ioctl)))" >> etc/selinux/plat_sepolicy.cil

		
	# FSCK
	echo "(allow fsck block_device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck mnt_modem_file (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck modem_secure_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck modem_fw_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck modem_nv_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck modem_log_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	
	# Vold	
	echo "(allow vold sys_block_mmcblk0 (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold vdc (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold system_server  (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold sysfs_zram (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold block_device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil

	# Vendor Init
	echo "(allow vendor_init device (chr_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vendor_init system_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vendor_init system_data_file (lnk_file (create getattr setattr relabelfrom unlink)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vendor_init teecd_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vendor_init teecd_data_file_system (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	# Fix ls ioctl cmd	FS_IOC_SET_ENCRYPTION_POLICY and FS_IOC_GET_ENCRYPTION_POLICY: 0x6613, 0x6615
	echo "(allowx vendor_init teecd_data_file (ioctl dir (0x6613 0x6615)))" >> etc/selinux/plat_sepolicy.cil 
	# here
	#echo "(allow vendor_init block_device (blk_file (open read write ioctl)))" >> etc/selinux/plat_sepolicy.cil	
 	echo "(allow vendor_init splash2_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vendor_init splash2_data_file (file (create open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vendor_init splash2_data_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vendor_init default_prop (file (open read write setattr getattr)))" >> etc/selinux/plat_sepolicy.cil	
	
	# Init
	echo "(allow init sys_dev_block (lnk_file (ioctl read write create getattr setattr lock append unlink link rename open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init sysfs_zram (lnk_file (ioctl read write create getattr setattr lock append unlink link rename open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init sysfs_led (file (setattr read open write)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow init cust_data_file (file (open write read ioctl getattr setattr relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init teecd_data_file (dir (mounton)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init teecd_data_file (filesystem (relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init splash2_data_file (filesystem (relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init splash2_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom mounton)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow init system_teecd_exec (file (open write read ioctl getattr setattr relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init system_teecd (file (open write read ioctl getattr setattr relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck splash2_data_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck cache_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck teecd_data_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil


	# Teecd
	echo "(allow teecd_data_file self (filesystem (relabelto relabelfrom associate)))" >> etc/selinux/plat_sepolicy.cil


	# kernel
	echo "(allow kernel self (capability (dac_override mknod fsetid)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel system_data_root_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel system_data_root_file (file (create open write read append ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel system_data_file (dir (add_name create search read open write setattr getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel system_data_file (file (create read open write getattr setattr append)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow kernel device (dir (search read open write getattr add_name)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel device (chr_file (create open write read getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel sysfs_devices_system_cpu (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel unlabeled (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel splash2_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom)))" >> etc/selinux/plat_sepolicy.cil

	# installd	
	echo "(allow installd splash2_data_file (filesystem (quotaget)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow installd self (capability (sys_ptrace)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow installd system_server (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow installd system_server (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow installd system_server (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow installd teecd_data_file (filesystem (quotaget)))" >> etc/selinux/plat_sepolicy.cil
	
	# tee
	echo "(allow tee hal_keymaster_default (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow tee hal_gatekeeper_default (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow tee self (capability (sys_ptrace)))" >> etc/selinux/plat_sepolicy.cil


	# PHH SU Daemon
	echo "(allow phhsu_daemon self (capability (fsetid)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon teecd_data_file (filesystem (relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_secure_file (filesystem (relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_log_file (filesystem (relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_fw_file (filesystem (relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_nv_file (filesystem (relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon kernel (system (syslog_console)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon dmd_device (chr_file (create open write read getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon splash2_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon splash2_data_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon teecd_data_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_secure_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_log_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_fw_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_nv_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allowx phhsu_daemon device (ioctl blk_file (0x125d 0x127c)))" >> etc/selinux/plat_sepolicy.cil

	# system_server
	echo "(allow system_server sysfs (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server userspace_reboot_exported_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server userspace_reboot_config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server exported_camera_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server sysfs_zram (lnk_file (ioctl read write create getattr setattr lock append unlink link rename open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server vendor_file (file (execute getattr map open read)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow system_server default_android_service (service_manager (find add)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow platform_app default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server isolated_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow linkerconfig self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow ueventd dmd_device (chr_file (create open write read getattr setattr)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow fsck mnt_modem_file (dir (search read open write getattr)))" >> etc/selinux/plat_sepolicy.cil
	

	
	# --------------- A11 specifique -------------------- 
	echo "(allow adbd self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow audioserver vendor_default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow blkcginit self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow blkid_untrusted self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow bootanim userspace_reboot_exported_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow bootanim system_data_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow boringssl_self_test self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow fsverity_init self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gpsdaemon self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_hwhiview_default self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app modem_fw_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app modem_nv_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app modem_secure_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app priv_app (dir (search read open write getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app priv_app (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app priv_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app teecd_data_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gpsdaemon default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gpsdaemon system_data_file (lnk_file (read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_camera_default config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_camera_default default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_camera_default system_data_file (lnk_file (read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_drm_widevine default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_fingerprint_default default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_health_default config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_health_default default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_keymaster_default config_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_nfc_default config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_nfc_default default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_nfc_default system_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_usb_default self (capability (dac_override sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow healthd self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hinetmanager self (capability (sys_admin dac_override)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hi110x_daemon default_prop (file (read open write getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hi110x_daemon self (fifo_file (ioctl)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hinetmanager self (capability (dac_override)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hwemerffu_service proc (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow mac_addr_normalization self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow migrate_legacy_obb_data self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow modprobe self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow isolated_app content_capture_service (service_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow netutils_wrapper hinetmanager (fd (use)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow netutils_wrapper hinetmanager (fifo_file (write)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow netutils_wrapper self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow otapreopt_slot self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow rootfs labeledfs (filesystem (associate)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow rootfs sysfs_zram (filesystem (relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow splash2_data_file splash2_data_file (filesystem (associate)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow su splash2_data_file (file (create open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow su splash2_data_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow ueventd unlabeled (lnk_file (read create getattr setattr relabelfrom unlink)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow unrmd self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow update_verifier self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow usbd self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vdc self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold_prepare_subdirs self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow zygote exported_camera_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil


	echo "(allow priv_app gmscore_app (dir (search read open write getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow priv_app gmscore_app (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow priv_app gmscore_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow rild config_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow rild system_data_file (lnk_file (read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow rild system_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow rootfs labeledfs (filesystem (relabelto relabelfrom associate mount )))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger bootanim (dir (search read open write getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger bootanim (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil

	# --------------- A12 specifique --------------------
	echo "(allow surfaceflinger bootanim (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger gmscore_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger platform_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger priv_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger system_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger system_server (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger untrusted_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger untrusted_app_29 (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server audioserver (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server bluetooth (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server cameraserver (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server gatekeeperd (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server gmscore_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server keystore (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server mediaextractor (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server mediametrics (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server mediaprovider (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server mediaprovider_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server netd (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server network_stack (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server nfc (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server permissioncontroller_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server platform_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server priv_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server radio (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server secure_element (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server shared_relro (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server shell (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server statsd (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server storaged (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server surfaceflinger (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server system_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server traceur_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server untrusted_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server untrusted_app_29 (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server vold (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow uniperf system_data_file (lnk_file (read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow wpa_hisi hi110x_cust_data_file (lnk_file (ioctl read write create getattr setattr lock append unlink link rename open)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow hi110x_daemon self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow profcollectd self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow adbroot self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow odsign self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	
	#echo "(allow vendor_init default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil

 	echo "(allow init vendor_file (file (open write read ioctl getattr setattr lock relabelfrom rename unlink append execute_no_trans)))" >> etc/selinux/plat_sepolicy.cil
 	echo "(allow init hwservicemanager (binder (call)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init untrusted_app_visible_hisi_hwservice (hwservice_manager (find add)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init hwservicemanager (binder (transfer)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow init hidl_base_hwservice (hwservice_manager (find add)))" >> etc/selinux/plat_sepolicy.cil
	
 	echo "(allow hwservicemanager init (dir (search ioctl read open write getattr lock)))" >> etc/selinux/plat_sepolicy.cil	
 	echo "(allow hwservicemanager init (file (open write read ioctl getattr setattr lock relabelfrom rename unlink append execute_no_trans)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hwservicemanager init (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
 	echo "(allow hwservicemanager init (binder (call)))" >> etc/selinux/plat_sepolicy.cil
	
	
 	echo "(allow shell pstorefs (dir (search ioctl read open write getattr lock)))" >> etc/selinux/plat_sepolicy.cil	
 	echo "(allow aptouch_daemon aptouch_daemon_service (service_manager (add)))" >> etc/selinux/plat_sepolicy.cil
 	

	
	# Log splash2
	echo "(allow kernel anr_data_file (file (create open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel anr_data_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel anr_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel splash2_data_file (file (create open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel splash2_data_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel splash2_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom)))" >> etc/selinux/plat_sepolicy.cil

	# TeeLogCat splash2
	echo "(allow tlogcat self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow tlogcat device (chr_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(type system_teecd_exec)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r system_teecd_exec)" >> etc/selinux/plat_sepolicy.cil
	echo "/system/bin/tee_auth_daemon   u:object_r:system_teecd_exec:s0" >> etc/selinux/plat_file_contexts
	
	
    # --------------------------- Kirin EMUI 9 properties -------------------

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


	# ------------------- etc/selinux/plat_property_contextsl ------------------

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
	

)

sleep 1

umount d

e2fsck -f -y s-ab-raw.img || true
resize2fs -M s-ab-raw.img

# Make android spare image
img2simg s-ab-raw.img s-ab.img


