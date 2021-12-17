#!/sbin/sh

	# Additional VARs
	SYSPERMDIRFILE=/system/etc/permissions/platform.xml
	BUILDPROP=/system/build.prop
	
	# Edit perm file settings
	printf "1 - Edit perm setting \n" 
	#sed -i '/<group gid=\"sdcard_rw\" \/>/a\        <group gid="sdcard_all" />\' $SYSPERMDIRFILE
	#sed -i '/<permission name=\"android\.permission\.WRITE\_EXTERNAL\_STORAGE\" \/>/a\        <group gid=\"sdcard_r\" />\n\ \       \<group gid="sdcard_rw\" />\n\ \       \<group gid="media_rw\" /> ' $SYSPERMDIRFILE
	# chmod 644 $SYSPERMDIRFILE/platform.xml
	
	
	# Check if selinux must to be toggle into permissive mode
	printf "2 - Check if selinux must to be toggle into permissive mode \n" 
	#if grep -wqs '8' $SYSTEMLESSPROP
	#	if grep -qs 'j5xnlte\|tissot_sprout\|kenzo\|manning\|ha3g\|D5803\|D2303\|maple_dsds\|a3y17\|Z00A\|dreamlte\|tissot_sprout\|GT-P7510\|hlte\|dreamlteks\|z3c\|sf340n' $SYSTEMLESSPROP; then
	#		mkdir -p $SYSSEMODPATH
	#		printf "setenforce 0" >> $SYSSEMODPATHFILE
	#		adb shell setenforce 0
	#	fi
	#else
	#	rm -f $SYSTEMLESSPROP
	#fi
	
		
	# Check if FUSE is enabled in build.prop file
	printf "3 - Check if FUSE is enabled in build.prop file \n"
	if grep -qs 'ro.sys.sdcardfs=true' $BUILDPROP; then
		sed -i 's/^ro.sys.sdcardfs=true/ro.sys.sdcardfs=false/' $BUILDPROP
	fi
	if grep -qs 'persist.esdfs_sdcard=true' $BUILDPROP; then
		sed -i 's/^persist.esdfs_sdcard=false' $BUILDPROP
	fi
	if grep -qs 'persist.sys.sdcardfs' $BUILDPROP; then
		sed -i 's/^persist.sys.sdcardfs=true/persist.sys.sdcardfs=false/' $BUILDPROP
	fi

	
    exit 0;
