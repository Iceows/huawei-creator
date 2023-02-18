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

"$origin"/simg2img "$srcFile" s.img || cp "$srcFile" s.img

rm -Rf tmp
mkdir -p d tmp
e2fsck -y -f s.img
resize2fs s.img 5000M
e2fsck -E unshare_blocks -y -f s.img
mount -o loop,rw s.img d
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
	
	# Dirty hack to show build properties
	# To get productid : sed -nE 's/.*productid=([0-9xa-f]*).*/\1/p' /proc/cmdline
	#MODEL=$( cat /sys/firmware/devicetree/base/boardinfo/normal_product_name | tr -d '\n')
	


	
	# set default sound
	echo "ro.config.ringtone=Ring_Synth_04.ogg" >>  build.prop
	echo "ro.config.notification_sound=OnTheHunt.ogg">>  build.prop
	echo "ro.config.alarm_alert=Argon.ogg">>  build.prop


 
	# Debug LMK - for Android Kernel that support it
	echo "ro.lmk.debug=false" >>  build.prop
	
	# Debug Huawei Off - if on  start service logcat 
	echo "persist.sys.hiview.debug=0" >> build.prop
	echo "persist.sys.huawei.debug.on=0" >> build.prop

	
	# Enable wireless display (Cast/Miracast)
	echo "persist.debug.wfd.enable=1" >>  build.prop
	

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
	
	# rw-system custom for Huawei device (safety version)
	#cp "$origin/files-patch/system/bin/rw-system-safety.sh" bin/rw-system.sh
	#xattr -w security.selinux u:object_r:phhsu_exec:s0 bin/rw-system.sh
	
	cp "$origin/files-patch/system/bin/vndk-detect" bin/vndk-detect
	xattr -w security.selinux u:object_r:phhsu_exec:s0 bin/vndk-detect

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

	if [ "$model" == "FIG-LX1" ];then
	
		# NFC 
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_anne_L31.conf" etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nci_anne_L31.conf" etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_anne_L31.conf" etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_RF_anne_L31.conf" etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp_RF.conf
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
	
	# Fingerprint 
	cp "$origin/files-patch/system/phh/huawei/fingerprint.kl" phh/huawei/fingerprint.kl
	xattr -w security.selinux u:object_r:system_file:s0  phh/huawei/fingerprint.kl


	#----------------------------- offline charging fix ----------------------------------------
	
	
	if [ "$bootanim" == "Y" ];then
		
		# remove AOSP charger img
		rm -rf etc/charger
		
		# unzip new img for all resolution
		unzip "$origin/files-patch/system/etc/charger-emui9.zip" -d etc/
		find etc/charger -type f -exec xattr -w security.selinux u:object_r:system_file:s0  {} \;
		find etc/charger -type d -exec xattr -w security.selinux u:object_r:system_file:s0  {} \;
		chmod -R 777 etc/charger
		xattr -w security.selinux u:object_r:system_file:s0 etc/charger
		

		# cp new offline charger executable
		cp "$origin/files-patch/system/bin/offlinecharger" bin/offlinecharger
		chown root:2000 bin/offlinecharger
		xattr -w security.selinux u:object_r:charger_exec:s0 bin/offlinecharger
		chmod 755 bin/offlinecharger


		# Change init.rc to include huawei charger init	
		cp "$origin/files-patch/system/etc/init/init.charger.emui9.huawei.rc" etc/init/init.charger.huawei.rc
		chown root:root etc/init/init.charger.huawei.rc
		xattr -w security.selinux u:object_r:system_file:s0 etc/init/init.charger.huawei.rc
		chmod 755 etc/init/init.charger.huawei.rc
		
		sed -i '13iimport /system/etc/init/init.charger.huawei.rc' etc/init/hw/init.rc
	else
		# Change init.rc to include GSI Huawei charger init	
		cp "$origin/files-patch/system/etc/init/init.charger.emui9.gsi.rc" etc/init/init.charger.huawei.rc
		chown root:root etc/init/init.charger.huawei.rc
		xattr -w security.selinux u:object_r:system_file:s0 etc/init/init.charger.huawei.rc
		chmod 755 etc/init/init.charger.huawei.rc
		
		sed -i '13iimport /system/etc/init/init.charger.huawei.rc' etc/init/hw/init.rc
	fi
	
	


	# --------------AGPS Patch ---------------------- #
	
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
	mkdir etc/gnss/config
	cp "$origin/files-patch/system/etc/gnss/config/gnss_suplconfig_hisi.xml" etc/gnss/config/gnss_suplconfig_hisi.xml
	cp "$origin/files-patch/system/etc/gnss/config/gnss_lss_config_thirdparty.bin" etc/gnss/config/gnss_lss_config_thirdparty.bin
	cp "$origin/files-patch/system/etc/gnss/config/gnss_lss_rfg_key_thirdparty.pem" etc/gnss/config/gnss_lss_rfg_key_thirdparty.pem
	cp "$origin/files-patch/system/etc/gnss/config/gnss_lss_slp_thirdparty.p12" etc/gnss/config/gnss_lss_slp_thirdparty.p12
	
	# Add RC
	cp "$origin/files-patch/system/etc/init/init-gnss.rc" etc/init/init-gnss.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/init-gnss.rc
	
	
	# Set owner and permissions (system:system)
	chmod 755 bin/gnss_watchlssd_thirdparty
	chown 1000:1000 bin/gnss_watchlssd_thirdparty

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
	
	# Fix system ntp_server (europe pool)
	set global ntp_server europe.pool.ntp.org

	# Allow agps an set config
	echo "persist.sys.pgps.config=1"  >> build.prop;
	echo "assisted_gps_enabled=1"  >> build.prop;

	# Uncomment to Debug GPS
	# echo "log.tag.GnssConfiguration=DEBUG" >> /system_root/system/build.prop;
	# echo "log.tag.GnssLocationProvider=DEBUG" >> /system_root/system/build.prop;
	# echo "log.tag.GnssManagerService=DEBUG" >> /system_root/system/build.prop;
	# echo "log.tag.NtpTimeHelper=DEBUG" >> /system_root/system/build.prop;
	
	# active le mode journalisation
	# echo "ro.control_privapp_permissions=log" >> /system_root/system/build.prop;
	
	#----------------------------- SELinux rules -----------------------------------------------------	
	
	# Fix platform_app
	echo "(allow platform_app nfc_service (service_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow platform_app cameradaemon_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil

	
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
	echo "(allow fsck mnt_modem_file (dir (search read open write getattr)))" >> etc/selinux/plat_sepolicy.cil
	
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
	# This rules make a bootloop
	# echo "(allow vendor_init block_device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil	
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
	#echo "(allow init block_device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow init sys_block_mmcblk0 (lnk_file (ioctl read write create getattr setattr lock append unlink link rename open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init hwservicemanager (binder (call transfer)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init sys_block_mmcblk0 (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil

	# FSCK
	echo "(allow fsck splash2_data_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck cache_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck teecd_data_file (dir (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck mnt_modem_file (dir (search read open write getattr)))" >> etc/selinux/plat_sepolicy.cil
	

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
	echo "(allow phhsu_daemon modem_log_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_fw_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_nv_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon device (blk_file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon kernel (system (syslog_console)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon dmd_device (chr_file (create open write read getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon splash2_data_file (dir (create search getattr open read setattr ioctl write add_name remove_name rmdir relabelto relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon splash2_data_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon teecd_data_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow phhsu_daemon modem_secure_file (filesystem (getattr relabelto relabelfrom associate mount)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allowx phhsu_daemon device (ioctl blk_file (0x125d 0x127c)))" >> etc/selinux/plat_sepolicy.cil

	# system_server
	echo "(allow system_server sysfs (file (open write read ioctl getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server userspace_reboot_exported_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server userspace_reboot_config_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server exported_camera_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server sysfs_zram (lnk_file (ioctl read write create getattr setattr lock append unlink link rename open)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server default_android_service (service_manager (find add)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server vendor_file (file (execute getattr map open read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server cameradaemon_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow system_server isolated_app (process (getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	echo "(allow platform_app default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow linkerconfig self (capability (sys_admin)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow ueventd dmd_device (chr_file (create open write read getattr setattr)))" >> etc/selinux/plat_sepolicy.cil



























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


)

sleep 1

(
cd d
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

e2fsck -f -y s.img || true
resize2fs -M s.img

mv s.img s-vndklite.img



