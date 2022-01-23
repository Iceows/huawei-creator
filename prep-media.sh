#!/sbin/sh


	# Reset all, except media folder
	# rm -rf $(ls * | grep -v media)
	rm -rf *;

	# Create all 
	mkdir media;
	mkdir misc;
	mkdir misc_ce;
	mkdir misc_de;
	mkdir vendor;
	#mkdir vendor_ce;
	#mkdir vendor_de;
	mkdir user;
	mkdir user_de;
	#mkdir user_ce;
	mkdir system;
	mkdir system_ce;
	mkdir system_de;

	# Change permission
	chown media_rw:media_rw media;
	chown system:system vendor;
	#chown system:system vendor_ce;
	#chown system:system vendor_de;
	chown system:system user;
	chown system:system user_de;
	#chown system:system user_ce;
	chown system:system system;
	chown system:system system_ce;
	chown system:system system_de;
	chown system:misc misc;
	chown system:misc misc_ce;
	chown system:misc misc_de;
	
	# Create 0 subdir
	mkdir /data/media/0;
	mkdir /data/media/ob;
	
	mkdir /data/system_de/0;
	mkdir /data/system_ce/0;
	mkdir /data/misc_de/0;	
	mkdir /data/misc_ce/0;
	mkdir /data/user_de/0;
	#mkdir /data/user_ce/0;
	#mkdir /data/data
	
	cd media
	
	chown media_rw:media_rw 0;
	chown media_rw:media_rw ob;

exit 0;
