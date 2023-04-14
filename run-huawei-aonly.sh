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
bootanim="$4"

if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash run-huawei-aonly.sh [/path/to/system.img] [version] [model] [bootanim : Y/N]"
	echo "VERSION=LeaOS, LeaOS-PHH , crDRom v316 - Mod Iceows , LiR v316 - Mod Iceows , Caos v316 - Mod Iceows"
	echo "model=PRA-LX1 , FIG-LX1, AGS2-W09"
	exit 1
fi

"$origin"/simg2img "$srcFile" s-aonly.img || cp "$srcFile" s-aonly.img

rm -Rf tmp
mkdir -p d tmp
e2fsck -y -f s-aonly.img
resize2fs s-aonly.img 3500M
e2fsck -E unshare_blocks -y -f s-aonly.img
mount -o loop,rw s-aonly.img d
(


	#----------------------------- Missing Huawei root folder -----------------------------------------------------		
	cd d
	
	mkdir splash2
	chown root:root splash2
	chmod 777 splash2
	xattr -w security.selinux u:object_r:rootfs:s0 splash2
	
	mkdir modem_log
	chown root:root modem_log
	chmod 777 modem_log
	xattr -w security.selinux u:object_r:rootfs:s0 modem_log
		
	#----------------------------- Make a-only image ------------------------------------------------------	
	
	cp init.environ.rc "$origin"/tmp

	find -maxdepth 1 -not -name system -not -name . -not -name .. -exec rm -Rf '{}' +
	mv system/* .
	rmdir system


	# remove apex v28, v29
	rm -Rf system_ext/apex/com.android.vndk.v28
	rm -Rf system_ext/apex/com.android.vndk.v29
	rm -Rf apex/*.apex
	rm -Rf system_ext/apex/*.apex
	
	rm -rf lib64/vndk-28
	rm -rf lib64/vndk-29
	rm -rf lib64/vndk-sp-28
	rm -rf lib64/vndk-sp-29	
	
	sed -i \
	    -e '/sys.usb.config/d' \
	    -e '/persist.sys.theme/d' \
	    -e '/ro.opengles.version/d' \
	    -e '/ro.sf.lcd_density/d' \
	    -e '/sys.usb.controller/d' \
	    -e '/persist.dbg.wfc_avail_ovr/d' \
	    -e '/persist.dbg.vt_avail_ovr/d' \
	    -e '/persist.dbg.volte_avail_ovr/d' \
	    -e '/ro.build.fingerprint/d' \
	    -e '/ro.vendor.build.fingerprint/d' \
	 etc/selinux/plat_property_contexts


	xattr -w security.selinux u:object_r:property_contexts_file:s0 etc/selinux/plat_property_contexts

	cp "$origin"/files/apex-setup.rc etc/init/
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/apex-setup.rc

	cp "$origin"/tmp/init.environ.rc etc/init/init-environ.rc
	sed -i 's/on early-init/on init/g' etc/init/init-environ.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/init-environ.rc

	sed -i \
	    -e s/MREMAP_MAYMOVE/1/g \
	    etc/seccomp_policy/mediaextractor.policy \
	    etc/seccomp_policy/mediacodec.policy \
	    system_ext/apex/com.android.media/etc/seccomp_policy/mediaextractor.policy \
	    system_ext/apex/com.android.media.swcodec/etc/seccomp_policy/mediaswcodec.policy
	sed -i '0,/^@include/s/^@include.*/getdents64: 1\n&/' etc/seccomp_policy/mediaextractor.policy \
	  system_ext/apex/com.android.media/etc/seccomp_policy/mediaextractor.policy
	sed -i '0,/^@include/s/^@include.*/rt_sigprocmask: 1\n&/' etc/seccomp_policy/mediaextractor.policy \
	  system_ext/apex/com.android.media/etc/seccomp_policy/mediaextractor.policy
	sed -i '0,/^@include/s/^@include.*/rt_sigprocmask: 1\nrt_sigaction: 1\n&/' etc/seccomp_policy/mediacodec.policy

	xattr -w security.selinux u:object_r:system_file:s0 system_ext/apex/com.android.media/etc/seccomp_policy/mediaextractor.policy system_ext/apex/com.android.media.swcodec/etc/seccomp_policy/mediaswcodec.policy
	xattr -w security.selinux u:object_r:system_seccomp_policy_file:s0 etc/seccomp_policy/mediacodec.policy etc/seccomp_policy/mediaextractor.policy etc/seccomp_policy/mediacodec.policy

	#"lmkd" user and group don't exist
	#"readproc" doesn't exist, use SYS_PTRACE instead
	sed -i -E \
	    -e '/user lmkd/d' \
	    -e 's/group .*/group root/g' \
	    -e 's/capabilities (.*)/capabilities \1 SYS_PTRACE/g' \
	    etc/init/lmkd.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/lmkd.rc

	sed -i -E \
	    -e '/user/d' \
	    -e '/group/d' \
	    etc/init/credstore.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/credstore.rc

	cp system_ext/apex/com.android.media.swcodec/etc/init.rc etc/init/media-swcodec.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/media-swcodec.rc

	cp system_ext/apex/com.android.adbd/etc/init.rc etc/init/adbd.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/adbd.rc

	if [ -f system_ext/apex/com.android.adbd/lib64/libadb_protos.so ];then
		cp system_ext/apex/com.android.adbd/lib64/libadb_protos.so lib64/libadb_protos.so
		xattr -w security.selinux u:object_r:system_file:s0 lib64/libadb_protos.so
	fi

	if [ -f system_ext/apex/com.android.adbd/lib/libadb_protos.so ];then
		cp system_ext/apex/com.android.adbd/lib/libadb_protos.so lib/libadb_protos.so
		xattr -w security.selinux u:object_r:system_file:s0 lib/libadb_protos.so
	fi

	sed -i s/ro.iorapd.enable=true/ro.iorapd.enable=false/g etc/prop.default
	xattr -w security.selinux u:object_r:system_file:s0 etc/prop.default

	cp -R system_ext/apex/com.android.vndk.v27 system_ext/apex/com.android.vndk.v26
	for i in vndkcore llndk vndkprivate vndksp;do
	    mv system_ext/apex/com.android.vndk.v26/etc/${i}.libraries.27.txt system_ext/apex/com.android.vndk.v26/etc/${i}.libraries.26.txt
	done
	find system_ext/apex/com.android.vndk.v26 -exec xattr -w security.selinux u:object_r:system_file:s0 '{}' \;

	vndk=26
	archs="64 32"
	if [ "$targetArch" == 32 ];then
	    archs=32
	fi

	echo libstdc++.so >> system_ext/apex/com.android.vndk.v26/etc/vndksp.libraries.26.txt

	for arch in $archs;do
	    for lib in $(cd "$origin/vendor_vndk/vndk-sp-${vndk}-arm${arch}"; echo *);do
		#TODO: handle "hw"
		[ ! -f "$origin/vendor_vndk/vndk-sp-${vndk}-arm${arch}"/$lib ] && continue
		p=lib
		[ "$arch" = 64 ] && p=lib64
		cp "$origin/vendor_vndk/vndk-sp-${vndk}-arm${arch}/$lib" system_ext/apex/com.android.vndk.v${vndk}/${p}/$lib
		xattr -w security.selinux u:object_r:system_lib_file:s0 system_ext/apex/com.android.vndk.v${vndk}/${p}/$lib
		echo $lib >> system_ext/apex/com.android.vndk.v${vndk}/etc/vndksp.libraries.${vndk}.txt
	    done
	    sort -u system_ext/apex/com.android.vndk.v${vndk}/etc/vndksp.libraries.${vndk}.txt > v
	    mv -f v system_ext/apex/com.android.vndk.v${vndk}/etc/vndksp.libraries.${vndk}.txt
	    xattr -w security.selinux u:object_r:system_file:s0 system_ext/apex/com.android.vndk.v${vndk}/etc/vndksp.libraries.${vndk}.txt
	done

	for vndk in 27 26;do
	    archs="64 32"
	    if [ "$targetArch" == 32 ];then
		archs="32 32-binder32"
	    fi
	    for arch in $archs;do
		t="$origin/vendor_vndk/vndk-${vndk}-arm${arch}"
		[ -d "$t" ] && for lib in $(cd "$origin/vendor_vndk/vndk-${vndk}-arm${arch}"; echo *);do
		    p=lib
		    [ "$arch" = 64 ] && p=lib64
		    cp "$origin/vendor_vndk/vndk-${vndk}-arm${arch}/$lib" system_ext/apex/com.android.vndk.v${vndk}/${p}/$lib
		    xattr -w security.selinux u:object_r:system_lib_file:s0 system_ext/apex/com.android.vndk.v${vndk}/${p}/$lib
		    echo $lib >> system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt
		done
		sort -u system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt > v
		mv -f v system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt
		xattr -w security.selinux u:object_r:system_file:s0 system_ext/apex/com.android.vndk.v${vndk}/etc/vndkcore.libraries.${vndk}.txt
	    done
	done

	sed -i 's/v27/v26/g' system_ext/apex/com.android.vndk.v26/apex_manifest.pb
	xattr -w security.selinux u:object_r:system_file:s0 system_ext/apex/com.android.vndk.v26/apex_manifest.pb

	sed -E -i 's/(.*allowx adbd functionfs .*0x6782)/\1 0x67e7/g' etc/selinux/plat_sepolicy.cil
	xattr -w security.selinux u:object_r:sepolicy_file:s0 etc/selinux/plat_sepolicy.cil

	sed -E -i 's/\+passcred//g' etc/init/logd.rc
	sed -E -i 's/\+passcred//g' etc/init/lmkd.rc
	sed -E -i 's/reserved_disk//g' etc/init/vold.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/vold.rc etc/init/logd.rc etc/init/lmkd.rc

	sed -E -i /rlimit/d etc/init/bpfloader.rc etc/init/cameraserver.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/bpfloader.rc etc/init/cameraserver.rc

	sed -i -e s/readproc//g -e s/reserved_disk//g etc/init/hw/init.zygote64.rc etc/init/hw/init.zygote64_32.rc etc/init/hw/init.zygote32_64.rc etc/init/hw/init.zygote32.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/hw/init.zygote64.rc etc/init/hw/init.zygote64_32.rc etc/init/hw/init.zygote32_64.rc etc/init/hw/init.zygote32.rc

	ln -s /apex/com.android.vndk.v26/lib/ lib/vndk-sp-26
	xattr -sw security.selinux u:object_r:system_lib_file:s0 lib/vndk-sp-26
	ln -s /apex/com.android.vndk.v26/lib/ lib/vndk-26
	xattr -sw security.selinux u:object_r:system_lib_file:s0 lib/vndk-26

	if [ -d lib64 ];then
		ln -s /apex/com.android.vndk.v26/lib64/ lib64/vndk-sp-26
		xattr -sw security.selinux u:object_r:system_lib_file:s0 lib64/vndk-sp-26
		ln -s /apex/com.android.vndk.v26/lib64/ lib64/vndk-26
		xattr -sw security.selinux u:object_r:system_lib_file:s0 lib64/vndk-26
	fi


	#-----------------------------File copy -----------------------------------------------------	
	
	
	
	# rw-system custom for Huawei device
	# cp "$origin/files-patch/system/bin/rw-system.sh" bin/rw-system.sh
	# xattr -w security.selinux u:object_r:phhsu_exec:s0 bin/rw-system.sh
	
	
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
	

	
	# ?
	cp "$origin/files-patch/system/etc/init/android.system.suspend@1.0-service.rc" etc/init/android.system.suspend@1.0-service.rc
	xattr -w security.selinux u:object_r:system_file:s0 etc/init/android.system.suspend@1.0-service.rc

	# offline charging - NFC
	# PRA - Huawei P8/P9 Lite 2017
	if [ "$model" == "PRA-LX1" ];then
		for img in $(cd "$origin/files-patch/system/etc/charger/1080x1920"; echo *);do
			cp "$origin/files-patch/system/etc/charger/1080x1920/$img" etc/charger/1080x1920/$img
			xattr -w security.selinux u:object_r:system_file:s0 etc/charger/1080x1920/$img
		done
		
		# NFC 
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_pra_L31.conf" etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/libnfc-nci.conf" etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_pra_L31.conf" etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/libnfc-nxp_RF.conf" etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 etc/libnfc-nxp_RF.conf
		
		cp "$origin/files-patch/system/etc/NFC/libnfc_brcm_venus_L31.conf" product/etc/libnfc-brcm.conf
		xattr -w security.selinux u:object_r:system_file:s0  product/etc/libnfc-brcm.conf
		cp "$origin/files-patch/system/etc/libnfc-nci.conf" product/etc/libnfc-nci.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nci.conf
		cp "$origin/files-patch/system/etc/NFC/libnfc_nxp_venus_L31.conf" product/etc/libnfc-nxp.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp.conf
		cp "$origin/files-patch/system/etc/libnfc-nxp_RF.conf" product/etc/libnfc-nxp_RF.conf
		xattr -w security.selinux u:object_r:system_file:s0 product/etc/libnfc-nxp_RF.conf
		
	fi
	if [ "$model" == "AGS2-W09" ];then
		echo "log.tag.launcher_force_rotate=VERBOSE" >> etc/prop.default
		echo "lockscreen.rot_override=true" >> etc/prop.default
	fi

	# Add charger animation for 1200x1920
	for img in $(cd "$origin/files-patch/system/etc/charger/1200x1920"; echo *);do
		cp "$origin/files-patch/system/etc/charger/1200x1920/$img" etc/charger/1200x1920/$img
		xattr -w security.selinux u:object_r:system_file:s0 etc/charger/1200x1920/$img
	done

			
	# Add charger animation for 1080x2160
	for img in $(cd "$origin/files-patch/system/etc/charger/1080x2160"; echo *);do
		cp "$origin/files-patch/system/etc/charger/1080x2160/$img" etc/charger/1080x2160/$img
		xattr -w security.selinux u:object_r:system_file:s0 etc/charger/1080x2160/$img
	done


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
	
	# Add Volte IMS
	#chmod 755 app/HuaweiIMS/HuaweiIMS.apk
	#xattr -w security.selinux u:object_r:system_file:s0 a app/HuaweiIMS/HuaweiIMS.apk
				
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
	
	# Media Extractor policy (sas-creator run.sh add this two values)
	# getdents64: 1
	# rt_sigprocmask: 1	
	
	
	#----------------------------- SELinux rules -----------------------------------------------------	
	
	# Fix ls ioctl cmd	: 0x5413=TIOCGWINSZ 
	echo "(allowx hi110x_daemon hi110x_daemon (ioctl fifo_file (0x5413)))" >> etc/selinux/plat_sepolicy.cil 
	
	# Fix ls ioctl cmd	FS_IOC_SET_ENCRYPTION_POLICY and FS_IOC_GET_ENCRYPTION_POLICY: 0x6613, 0x6615
	echo "(allowx vendor_init teecd_data_file (ioctl dir (0x6613 0x6615)))" >> etc/selinux/plat_sepolicy.cil 
	
	# Fix app crashes
	echo "(allow appdomain vendor_file (file (read getattr execute open)))" >> etc/selinux/plat_sepolicy.cil

	# Fix instagram denied 
	echo "(allow untrusted_app dalvikcache_data_file (file (execmod)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow untrusted_app proc_zoneinfo (file (read open)))" >> etc/selinux/plat_sepolicy.cil

	# Fix Google GMS denied 
	echo "(allow gmscore_app splash2_data_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app teecd_data_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app modem_fw_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app modem_nv_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow gmscore_app modem_log_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	# echo "(allow gmscore_app mnt_modem_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil	
	# echo "(allow gmscore_app mnt_media_rw_file (dir (search)))" >> etc/selinux/plat_sepolicy.cil

	# Add type and mapping for displayengine-hal-1.0
	echo "(typeattributeset hwservice_manager_type (displayengine_hwservice))" >> etc/selinux/plat_sepolicy.cil
	echo "(type displayengine_hwservice)" >> etc/selinux/plat_sepolicy.cil
	echo "(roletype object_r displayengine_hwservice)" >> etc/selinux/plat_sepolicy.cil
	echo "(typeattributeset displayengine_hwservice_26_0 (displayengine_hwservice))" >> etc/selinux/mapping/26.0.cil

	# Fix hwservice_manager, service_manager
	#echo "(allow platform_app nfc_service (service_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server default_android_service (service_manager (add)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server vendor_file (file (execute getattr map open read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_app default_android_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil

	# SELinux radio
	echo "(allow hal_audio_default hal_broadcastradio_hwservice (hwservice_manager (find)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hal_audio_default audioserver (fifo_file (write)))" >> etc/selinux/plat_sepolicy.cil
		
	# SELinux to allow disk operation and camera
	echo "(allow fsck block_device (blk_file (open read write ioctl)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server sysfs (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server vfat (dir (open read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server system_data_root_file (dir (create add_name write)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server exported_camera_prop (file (open read getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server userspace_reboot_exported_prop (file (open read write getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow system_server userspace_reboot_config_prop (file (open read write getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	# Misc
	echo "(allow bootanim userspace_reboot_exported_prop (file (open getattr read write)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vndservicemanager device (file (open getattr write read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vndservicemanager device (chr_file (open write read getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow hw_ueventd kmsg_device (chr_file (open write read getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow logd device (file (open getattr read write)))" >> etc/selinux/plat_sepolicy.cil
	

	# Specific zygote
	echo "(allow zygote exported_camera_prop (file (open getattr read write)))" >> etc/selinux/plat_sepolicy.cil
		
	# Specific Honor 8x
	echo "(allow credstore self (capability (sys_resource)))" >> etc/selinux/plat_sepolicy.cil
		
	# PHH SU Daemon
	echo "(allow phhsu_daemon kernel (system (syslog_console)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon dmd_device (chr_file (open write read getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon self (capability (fsetid)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon splash2_data_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon teecd_data_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon modem_fw_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon modem_nv_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow phhsu_daemon modem_log_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	
	# Add to enable file encryption (vold) - Fix permission on folder /data/unencrypted and /data/*/0
	echo "(allow vold block_device (blk_file (open read write)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold dm_device (blk_file (ioctl)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold system_data_root_file (file (create unlink read write)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold_prepare_subdirs kernel (system (module_request)))" >> etc/selinux/plat_sepolicy.cil	
	echo "(allow vold_prepare_subdirs system_data_file (dir (create setattr search write read add_name)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold_prepare_subdirs vold_prepare_subdirs (capability (fsetid)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow vold_prepare_subdirs system_data_root_file (dir (create setattr search write read add_name)))" >> etc/selinux/plat_sepolicy.cil

	# Fix init
	echo "(allow init device (chr_file (open write read getattr setattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init splash2_data_file (filesystem (getattr)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init system_file (dir (relabelfrom setattr write read)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init system_file (file (relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init sysfs_zram_uevent (file (relabelfrom)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow init cust_block_device (lnk_file (relabelto)))" >> etc/selinux/plat_sepolicy.cil

	# e2fsck
	echo "(allow fsck block_device (blk_file (open read write ioctl)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow fsck tmpfs (lnk_file (open read write ioctl)))" >> etc/selinux/plat_sepolicy.cil
	echo "(allow installd tmpfs (lnk_file (open read write ioctl)))" >> etc/selinux/plat_sepolicy.cil
	
	# Cust
	echo "(allow cust rootfs (file (execute)))" >> etc/selinux/plat_sepolicy.cil


	
	#---------------------------------Setting properties -------------------------------------------------
		

	# Dirty hack to show build properties
	# To get productid : sed -nE 's/.*productid=([0-9xa-f]*).*/\1/p' /proc/cmdline
	#MODEL=$( cat /sys/firmware/devicetree/base/boardinfo/normal_product_name | tr -d '\n')

	
	# build.prop 
   	echo "debug.sf.latch_unsignaled=1" >> build.prop
	echo "ro.surface_flinger.running_without_sync_framework=true" >> build.prop;
		
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

	
	echo "persist.sys.usb.config=hisuite,mtp,mass_storage" >> etc/prop.default
	echo "sys.usb.config=mtp" >> etc/prop.default
	echo "sys.usb.configfs=1" >> etc/prop.default
	echo "sys.usb.controller=hisi-usb-otg" >> etc/prop.default
	echo "sys.usb.ffs.aio_compat=true" >> etc/prop.default
	echo "sys.usb.ffs.ready=0" >> etc/prop.default
	echo "sys.usb.ffs_hdb.ready=0" >> etc/prop.default
	echo "sys.usb.state=mtp" >> etc/prop.default
   	
	# Color
	echo "persist.sys.sf.native_mode=1" >> etc/prop.default
	echo "persist.sys.sf.color_mode=1.0" >> etc/prop.default
	echo "persist.sys.sf.color_saturation=1.1" >> etc/prop.default

	# LMK - for Android Kernel that support it
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
	
	
)
sleep 1

umount d

e2fsck -f -y s-aonly.img || true
resize2fs -M s-aonly.img 


#xz -c s-aonly.img -T0 > s-aonly-vanilla.xz


