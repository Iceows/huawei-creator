#!/bin/bash

#Usage:
#sudo bash run-huawei-aonly.sh  [/path/to/system.img] [version] [model device] [huawei animation]

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
bootanim="$4"


if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash run-huawei-ab.sh [/path/to/system.img] [version] [model] [bootanimation]"
	echo "version=LeaOS, LeaOS-PHH , crDRom v316 - Mod Iceows , LiR v316 - Mod Iceows , Caos v316 - Mod Iceows"
	echo "model=ANE-LX1"
	echo "bootanimation=Y or N"
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
	
	# Fix hwservice_manager, service_manager
	echo "(allow platform_app nfc_service (service_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server default_android_service (service_manager (add)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server vendor_file (file (execute getattr map open read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_app default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	
	# SELinux to allow disk operation and camera
	echo "(allow oeminfo_nvm block_device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow oeminfo_nvm device (chr_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil	
	
	# SELinux radio
	echo "(allow hal_audio_default hal_broadcastradio_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_audio_default audioserver (fifo_file (write)))" >> etc/selinux/plat_sepolicy.cil
	
	# Fix Google GMS denied 
	echo "(allow gmscore_app mnt_modem_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow gmscore_app mnt_media_rw_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil

	# Fix WPA suppliant	(cust_conn)
	echo "(allow wpa_hisi hi110x_cust_data_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow wpa_hisi default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow wpa_hisi config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow vendor_init default_prop (file (open read write setattr getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow aptouch_daemon system_prop (file (open read write setattr getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow hisecd default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow hisecd config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	
	echo "(allow storage_info default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	# PHH SU Daemon
	echo "(allow phhsu_daemon self (capability (fsetid)))" >> etc/selinux/plat_sepolicy.cil
	
	# --------------- A12 --------------------
	echo "(allow system_server platform_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server radio (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server bluetooth (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server audioserver (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server cameraserver (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server storaged (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server mediametrics (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server gmscore_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server priv_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server untrusted_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server permissioncontroller_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server system_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server mediaextractor (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server statsd (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server shared_relro (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server network_stack (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server secure_element (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server nfc (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server mediaprovider_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server untrusted_app_29 (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server traceur_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server mediaprovider (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server vold (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server shell (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server netd (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server surfaceflinger (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server keystore (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow priv_app gmscore_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app priv_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	
	echo "(allow tee hal_keymaster_default (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow tee hal_gatekeeper_default (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	
	echo "(allow priv_app gmscore_app (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app priv_app (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow priv_app gmscore_app (dir (search read open write getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app priv_app (dir (search read open write getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app modem_secure_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app modem_nv_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app modem_fw_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app teecd_data_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger gmscore_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	

	

	echo "(allow surfaceflinger bootanim (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger bootanim (dir (search read open write getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger bootanim (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger system_server (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger system_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger platform_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger priv_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger untrusted_app_29 (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow surfaceflinger untrusted_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow wpa_hisi hi110x_cust_data_file (lnk_file (ioctl read write create getattr setattr lock append unlink link rename open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck mnt_modem_file (dir (search read open write getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	
	echo "(allow kernel device (dir (search read open write getattr add_name)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel device (chr_file (create open write read getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel self (capability (mknod)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel sysfs_devices_system_cpu (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil

		
	echo "(allow vendor_init device (chr_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	#echo "(allow vendor_init block_device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	#echo "(allow vendor_init system_data_file (lnk_file (ioctl read write create getattr setattr lock append unlink link rename open)))" >> etc/selinux/plat_sepolicy.cil
	
	
	echo "(allow fsck block_device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow init sys_dev_block (lnk_file (ioctl read write create getattr setattr lock append unlink link rename open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init sysfs_zram (lnk_file (ioctl read write create getattr setattr lock append unlink link rename open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init sysfs_led (file (setattr read open write)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow init cust_data_file (file (open write read ioctl getattr setattr relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init teecd_data_file (dir (mounton)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init teecd_data_file (filesystem (relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow teecd_data_file self (filesystem (relabelto relabelfrom associate)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow vold sys_block_mmcblk0 (file (read open write)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow isolated_app content_capture_service (service_manager (find)))" >> etc/selinux/plat_sepolicy.cil

	
	# Set encryption policy on dirs in /data
	# allowxperm vendor_init teecd_data_file_type:dir ioctl {
	#   FS_IOC_GET_ENCRYPTION_POLICY
	#   FS_IOC_SET_ENCRYPTION_POLICY
	# };
	# Fix ls ioctl cmd	FS_IOC_SET_ENCRYPTION_POLICY and FS_IOC_GET_ENCRYPTION_POLICY: 0x6613, 0x6615
	echo "(allowx vendor_init teecd_data_file (ioctl dir (0x6613 0x6615)))" >> etc/selinux/plat_sepolicy.cil 
	
	echo "(allow vendor_init teecd_data_file_system (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vendor_init system_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vendor_init teecd_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vendor_init system_data_file (lnk_file (create getattr setattr relabelfrom unlink)))" >> etc/selinux/plat_sepolicy.cil
	
	# echo "(allow vendor_init block_device (blk_file (open read write ioctl)))" >> etc/selinux/plat_sepolicy.cil	

    # vold
	echo "(allow vold vdc (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold system_server  (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold sysfs_zram (file (create read open write getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold block_device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	

	# To allow /data/hisi_logs
	echo "(allow kernel self (capability (dac_override)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel system_data_root_file (dir (add_name create search read open write setattr getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel system_data_root_file (file (create read open write getattr setattr append)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel system_data_file (dir (add_name create search read open write setattr getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel system_data_file (file (create read open write getattr setattr append)))" >> etc/selinux/plat_sepolicy.cil	
		
	
	echo "(allow hal_audio_default default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_audio_default config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_audio_default system_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_nfc_default default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_nfc_default config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_nfc_default system_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hi110x_daemon default_prop (file (read open write getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_health_default default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_drm_widevine default_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow rild config_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow rild system_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gpsdaemon default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow oeminfo_nvm default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_fingerprint_default default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_camera_default default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_camera_default system_data_file (lnk_file (read)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow hal_camera_default config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow audioserver vendor_default_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_keymaster_default config_prop (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil

	
	echo "(allow rild system_data_file (lnk_file (read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gpsdaemon system_data_file (lnk_file (read)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow system_server sysfs_zram (lnk_file (read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow netutils_wrapper hinetmanager (fd (use)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow fsck modem_secure_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck modem_fw_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck modem_nv_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow hwemerffu_service proc (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow hal_health_default config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow uniperf system_data_file (lnk_file (read)))" >> etc/selinux/plat_sepolicy.cil
	

	echo "(allow phhsu_daemon modem_secure_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon modem_fw_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon modem_nv_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon device (blk_file (ioctl)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allowx phhsu_daemon device (ioctl blk_file(0x125d 0x127c)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon kernel (system (syslog_console)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon dmd_device (chr_file (setattr)))" >> etc/selinux/plat_sepolicy.cil

	
	echo "(allow netutils_wrapper hinetmanager (fifo_file (write)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hinetmanager self (capability (dac_override)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow kernel unlabeled (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hi110x_daemon self (fifo_file (ioctl)))" >> etc/selinux/plat_sepolicy.cil	
	

	echo "(allow bootanim system_data_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_usb_default self (capability (dac_override)))" >> etc/selinux/plat_sepolicy.cil

	echo "(allow installd self (capability (sys_ptrace)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow installd system_server (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow installd system_server (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow installd system_server (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow installd teecd_data_file (filesystem (quotaget)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow hal_audio_default odm_etc_audio_algorithm (dir (search)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server gatekeeperd (process (getattr)))" >> etc/selinux/plat_sepolicy.cil	

	echo "(allow rootfs labeledfs (filesystem (relabelto relabelfrom associate mount )))" >> etc/selinux/plat_sepolicy.cil


)

sleep 1

umount d

e2fsck -f -y s-ab-raw.img || true
resize2fs -M s-ab-raw.img

# Make android spare image
img2simg s-ab-raw.img s-ab.img


