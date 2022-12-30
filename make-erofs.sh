#!/bin/bash

#Usage:
#sudo bash make-erofs.sh  [/path/to/system.img]
#cleanups
#A13 version
umount d

set -ex

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"


srcFile="$1"


if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash make-erofs.sh  [/path/to/system.img]"
	exit 1
fi

# Need install sim2img and img2simg before
simg2img "$srcFile" s-ab-raw.img || cp "$srcFile" s-ab-raw.img

rm -Rf tmp

mkdir -p d tmp
e2fsck -y -f s-ab-raw.img
resize2fs s-ab-raw.img 3500M
e2fsck -E unshare_blocks -y -f s-ab-raw.img
mount -o loop,rw s-ab-raw.img d

rm -Rf s-erofs.img
mkfs.erofs -zlz4hc -d2 s-erofs.img d/

umount d

umount test-eros
mount  -o loop,ro -t erofs s-erofs.img test-eros/

img2simg s-erofs.img s-erofs-sparse.img

