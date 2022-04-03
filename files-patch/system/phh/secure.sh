(getprop ro.vendor.build.security_patch; getprop ro.keymaster.xxx.security_patch) |sort |tail -n 1 |while read v;do
    [ -n "$v" ] && resetprop_phh ro.build.version.security_patch "$v"
done
resetprop_phh ro.build.tags release-keys
resetprop_phh ro.boot.vbmeta.device_state locked
resetprop_phh ro.boot.verifiedbootstate green
resetprop_phh ro.boot.flash.locked 1
resetprop_phh ro.boot.veritymode enforcing
resetprop_phh ro.boot.warranty_bit 0
resetprop_phh ro.warranty_bit 0
resetprop_phh ro.debuggable 0
resetprop_phh ro.secure 1
resetprop_phh ro.build.type user
resetprop_phh ro.build.selinux 0
resetprop_phh ro.adb.secure 1
setprop ctl.restart adbd
