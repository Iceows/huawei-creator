#!/sbin/sh

# Fix record screen
# -rw-r--r--
chmod 644 /system/lib/libhidlbase.so
chmod 644 /system/lib64/libhidlbase.so
chmod 644 /system/lib/libhwbinder.so
chmod 644 /system/lib64/libhwbinder.so

chcon -v u:object_r:system_lib_file:s0 /system/lib/libhidlbase.so
chcon -v u:object_r:system_lib_file:s0 /system/lib64/libhidlbase.so
chcon -v u:object_r:system_lib_file:s0 /system/lib/libhwbinder.so
chcon -v u:object_r:system_lib_file:s0 /system/lib64/libhwbinder.so

# Enable wireless display (Cast/Miracast)
echo "persist.debug.wfd.enable=1" >> /system/etc/prop.default;


# Delete all duplicate line if you execute script several times
sed -i '/(typeattributeset hwservice_manager_type (displayengine_hwservice))/d' /system/etc/selinux/plat_sepolicy.cil
sed -i '/(type displayengine_hwservice)/d' /system/etc/selinux/plat_sepolicy.cil
sed -i '/(roletype object_r displayengine_hwservice)/d' /system/etc/selinux/plat_sepolicy.cil
sed -i '/(typeattributeset displayengine_hwservice_26_0 (displayengine_hwservice))/d' /system/etc/selinux/mapping/26.0.cil

sed -i '/(allow system_server default_android_hwservice (hwservice_manager (find)))/d' /system/etc/selinux/plat_sepolicy.cil
sed -i '/(allow system_server default_android_service (service_manager (add)))/d'  /system/etc/selinux/plat_sepolicy.cil
sed -i '/(allow system_server vendor_file (file (execute getattr map open read)))/d' /system/etc/selinux/plat_sepolicy.cil
sed -i '/(allow system_app default_android_hwservice (hwservice_manager (find)))/d' /system/etc/selinux/plat_sepolicy.cil



# Add type and mapping for displayengine-hal-1.0
echo "(typeattributeset hwservice_manager_type (displayengine_hwservice))" >> /system/etc/selinux/plat_sepolicy.cil
echo "(type displayengine_hwservice)" >> /system/etc/selinux/plat_sepolicy.cil
echo "(roletype object_r displayengine_hwservice)" >> /system/etc/selinux/plat_sepolicy.cil
echo "(typeattributeset displayengine_hwservice_26_0 (displayengine_hwservice))" >> /system/etc/selinux/mapping/26.0.cil

# Add allow  for displayengine-hal-1.0
# echo "(allow hal_displayengine_default displayengine_hwservice (hwservice_manager (add find)))" >> /vendor/etc/selinux/nonplat_sepolicy.cil

# Add allow vendor.lineage.livedisplay
echo "(allow system_server default_android_hwservice (hwservice_manager (find)))" >> /system/etc/selinux/plat_sepolicy.cil
echo "(allow system_server default_android_service (service_manager (add)))" >> /system/etc/selinux/plat_sepolicy.cil
echo "(allow system_server vendor_file (file (execute getattr map open read)))" >> /system/etc/selinux/plat_sepolicy.cil
echo "(allow system_app default_android_hwservice (hwservice_manager (find)))" >> /system/etc/selinux/plat_sepolicy.cil


exit 0
