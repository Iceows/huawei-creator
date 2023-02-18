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
	
	# rw-system custom for Huawei device
	cp "$origin/files-patch/system/bin/rw-system.sh" bin/rw-system.sh
	xattr -w security.selinux u:object_r:phhsu_exec:s0 bin/rw-system.sh
	
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



