#!/sbin/sh

	chmod 644 /system/lib/libaptX_encoder.so
	chmod 644 /system/lib/libaptXHD_encoder.so
	chmod 644 /system/lib64/libaptX_encoder.so
	chmod 644 /system/lib64/libaptXHD_encoder.so
	
	chown root:root /system/lib/libaptX_encoder.so
	chown root:root /system/lib/libaptXHD_encoder.so
	chown root:root /system/lib64/libaptX_encoder.so
	chown root:root /system/lib64/libaptXHD_encoder.so
	
	chcon -v u:object_r:system_lib_file:s0 /system/lib/libaptX_encoder.so
	chcon -v u:object_r:system_lib_file:s0 /system/lib/libaptXHD_encoder.so
	chcon -v u:object_r:system_lib_file:s0 /system/lib64/libaptX_encoder.so
	chcon -v u:object_r:system_lib_file:s0 /system/lib64/libaptXHD_encoder.so

exit 0
