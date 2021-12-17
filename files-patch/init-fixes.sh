#!/sbin/sh



# Recherche la date du patch de securite dans l'image du kernel ou du boot 
fixSPL() {
    img="$(find /dev/block -type l -name kernel"$(getprop ro.boot.slot_suffix)" | grep by-name | head -n 1)"
    [ -z "$img" ] && img="$(find /dev/block -type l -name boot"$(getprop ro.boot.slot_suffix)" | grep by-name | head -n 1)"
    if [ -n "$img" ]; then
        #Rewrite SPL version if needed
		vendordate="$(getSPL "$img" spl)"
		echo "ro.vendor.build.security_patch=$vendordate" >> /system/etc/prop.default;
    fi
}


# Specific Huawei rw-system.sh
	chmod 755 /system/bin/rw-system.sh
	chown root:shell /system/bin/rw-system.sh
	chcon -v u:object_r:phhsu_exec:s0 /system/bin/rw-system.sh

# Fix app crashes
    echo "(allow appdomain vendor_file (file (read getattr execute open)))" >> /system/etc/selinux/plat_sepolicy.cil;

# Fix instagram denied 
    echo "(allow untrusted_app dalvikcache_data_file (file (execmod)))" >> /system/etc/selinux/plat_sepolicy.cil;
    echo "(allow untrusted_app proc_zoneinfo (file (read open)))" >> /system/etc/selinux/plat_sepolicy.cil;

# Fix Google GMS denied 
    echo "(allow gmscore_app splash2_data_file (filesystem (getattr)))" >> /system/etc/selinux/plat_sepolicy.cil;
    echo "(allow gmscore_app teecd_data_file (filesystem (getattr)))" >> /system/etc/selinux/plat_sepolicy.cil;
    echo "(allow gmscore_app modem_fw_file (filesystem (getattr)))" >> /system/etc/selinux/plat_sepolicy.cil;
    echo "(allow gmscore_app modem_nv_file (filesystem (getattr)))" >> /system/etc/selinux/plat_sepolicy.cil;
	
# Dirty hack to show build properties
# To get productid : sed -nE 's/.*productid=([0-9xa-f]*).*/\1/p' /proc/cmdline
    MODEL=$( cat /sys/firmware/devicetree/base/boardinfo/normal_product_name | tr -d '\n')
    PROP="ro.product.model"

	echo "#" >> /system/etc/prop.default;
    echo "## Adding build props" >> /system/etc/prop.default;
    echo "#" >> /system/etc/prop.default;
    cat /system/build.prop | grep "." >> /system/etc/prop.default;
    
	echo "#" >> /system/etc/prop.default;
	echo "## Adding hi6250 props" >> /system/etc/prop.default;
    echo "#" >> /system/etc/prop.default;
    sed -i "/ro.product.model/d" /system/etc/prop.default;
    sed -i "/ro.product.system.model/d" /system/etc/prop.default;
    echo "ro.product.manufacturer=HUAWEI" >> /system/etc/prop.default;
    echo "ro.product.system.model=hi6250" >> /system/etc/prop.default;
    echo "$PROP=$MODEL" >> /system/etc/prop.default;

	 
	echo "persist.sys.usb.config=hisuite,mtp,mass_storage" >> /system/etc/prop.default;
    echo "sys.usb.config=mtp" >> /system/etc/prop.default;
	echo "sys.usb.configfs=1" >> /system/etc/prop.default;
	echo "sys.usb.controller=hisi-usb-otg" >> /system/etc/prop.default;
	echo "sys.usb.ffs.aio_compat=true" >> /system/etc/prop.default;
   	echo "sys.usb.ffs.ready=0" >> /system/etc/prop.default;
	echo "sys.usb.ffs_hdb.ready=0" >> /system/etc/prop.default;
   	echo "sys.usb.state=mtp" >> /system/etc/prop.default; 
   	echo "debug.sf.latch_unsignaled=1" >> /system/build.prop;
	echo "ro.surface_flinger.running_without_sync_framework=true" >> /system/build.prop;
    echo "persist.sys.sf.native_mode=1" >> /system/etc/prop.default;
    echo "persist.sys.sf.color_mode=1.0" >> /system/etc/prop.default;
    echo "persist.sys.sf.color_saturation=1.1" >> /system/etc/prop.default;
	
# LMK - for Android Kernel that support it
	echo "ro.lmk.debug=true" >> /system/etc/prop.default;

    exit 0;
