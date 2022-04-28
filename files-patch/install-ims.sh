#!/sbin/sh

#	chmod 644 /system/overlay/treble-overlay-hw-ims.apk
#	restorecon /system/overlay/treble-overlay-hw-ims.apk
	
	chmod 644 /system/app/HuaweiIMS/HuaweiIMS.apk
	restorecon /system/app/HuaweiIMS/HuaweiIMS.apk


    echo " " >> /system/build.prop;
    echo "# Ims" >> /system/build.prop;
    echo "persist.sys.phh.ims.hw=true" >> /system/build.prop;
	echo "persist.radio.calls.on.ims=1" >> /system/build.prop;
    echo "persist.dbg.ims_volte_enable=1" >> /system/build.prop;
    echo "persist.dbg.volte_avail_ovr=1" >> /system/build.prop;
    echo "persist.dbg.vt_avail_ovr=0" >> /system/build.prop;
    echo "persist.dbg.wfc_avail_ovr=0" >> /system/build.prop;
	
	# Huawei config specific on EMUI 8 (Android 8)
	echo "ro.config.hw_volte_dyn=true" >> /system/build.prop;
    echo "ro.config.hw_volte_on=true" >> /system/build.prop;
    echo "ro.config.hw_volte_icon_rule=0" >> /system/build.prop;	
	
	# Iceows enable volte for my IMS Huawei
	echo "ro.hw.volte.enable=1" >> /system/build.prop;

    echo " " >> /system/etc/prop.default;
    echo "# Ims" >> /system/etc/prop.default;
    echo "persist.sys.phh.ims.hw=true" >> /system/etc/prop.default;
	echo "persist.radio.calls.on.ims=1" >> /system/etc/prop.default;
    echo "persist.dbg.ims_volte_enable=1" >> /system/etc/prop.default;
    echo "persist.dbg.volte_avail_ovr=1" >> /system/etc/prop.default;
    echo "persist.dbg.vt_avail_ovr=0" >> /system/etc/prop.default;
    echo "persist.dbg.wfc_avail_ovr=0" >> /system/etc/prop.default;
	
	# Huawei config specific on EMUI 8 (Android 8)
	echo "ro.config.hw_volte_dyn=true" >> /system/etc/prop.default;
    echo "ro.config.hw_volte_on=true" >> /system/etc/prop.default;
    echo "ro.config.hw_volte_icon_rule=0" >> /system/etc/prop.default;	
	
	# Iceows enable volte for my IMS Huawei
	echo "ro.hw.volte.enable=1" >> /system/etc/prop.default;	

    exit 0;
