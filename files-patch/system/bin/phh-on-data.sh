#!/system/bin/sh

vndk="$(getprop persist.sys.vndk)"
[ -z "$vndk" ] && vndk="$(getprop ro.vndk.version |grep -oE '^[0-9]+')"

if getprop persist.sys.phh.no_vendor_overlay |grep -q true; then
	for part in odm vendor; do
		mount /mnt/phh/empty_dir/ /$part/overlay
	done
fi

if getprop persist.sys.phh.no_stock_apps |grep -q true; then
	for part in odm vendor; do
		mount /mnt/phh/empty_dir/ /$part/overlay
		mount /mnt/phh/empty_dir/ /$part/app
	done
fi

if getprop persist.sys.phh.caf.media_profile |grep -q true; then
    setprop media.settings.xml "/vendor/etc/media_profiles_vendor.xml"
fi

# Add persist props for Redmi Note 9S/Pro/Max
if getprop ro.vendor.build.fingerprint |grep -iq -e redmi/curtana \
  -e redmi/joyeuse -e redmi/excalibur; then
    setprop persist.sys.phh.disable_audio_effects 1
    setprop persist.sys.phh.disable_a2dp_offload true
    setprop persist.bluetooth.bluetooth_audio_hal.disabled true
    setprop persist.sys.phh.caf.audio_policy 1
    mount -o bind /system/etc/mixer_paths_wcd937x.xml /vendor/etc/mixer_paths_wcd937x.xml
    mount -o bind /system/etc/media_profiles_vendor.xml /vendor/etc/media_profiles_vendor.xml
    setprop ctl.restart vendor.audio-hal-2-0
    setprop persist.sys.phh.linear_brightness false
    setprop persist.sys.phh.backlight.scale 1
    setprop persist.sys.phh.caf.media_profile true
    setprop persist.sys.overlay.minimal_brightness true
    pkill -f com.android.bluetooth
fi

minijailSrc=/system/system_ext/apex/com.android.vndk.v28/lib/libminijail.so
minijailSrc64=/system/system_ext/apex/com.android.vndk.v28/lib64/libminijail.so
if [ "$vndk" = 27 ]; then
    mount $minijailSrc64 /vendor/lib64/libminijail_vendor.so
    mount $minijailSrc /vendor/lib/libminijail_vendor.so
fi

if [ "$vndk" = 28 ]; then
    mount $minijailSrc64 /vendor/lib64/libminijail_vendor.so
    mount $minijailSrc /vendor/lib/libminijail_vendor.so
    mount $minijailSrc64 /system/lib64/vndk-28/libminijail.so
    mount $minijailSrc /system/lib/vndk-28/libminijail.so
    mount $minijailSrc64 /vendor/lib64/libminijail.so
    mount $minijailSrc /vendor/lib/libminijail.so
fi
