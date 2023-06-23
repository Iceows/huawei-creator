#!/bin/bash

#Usage:
#bash build-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"



srcDateFile="$1"


cd ../arrow
#bash arrow_build_leaos/build.sh treble 64BGN
#bash arrow_build_leaos/build.sh treble 64BVN

cd ../huawei-creator

# --------------------------------- LeaOS Gsi -----------------------------------

# ArrowOS ab version
cp /home/iceows/build-output/Arrow-A13-${srcDateFile}-treble_arm64_bvN.img /media/iceows/Sauvegardes/ice-rom/Arrow/
cp /home/iceows/build-output/Arrow-A13-${srcDateFile}-treble_arm64_bgN.img /media/iceows/Sauvegardes/ice-rom/Arrow/

xz -cv /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-treble_arm64_bvN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-treble_arm64_bvN.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-treble_arm64_bgN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-treble_arm64_bgN.img.xz

# Arrow erofs version
sudo bash ./make-erofs.sh /home/iceows/build-output/Arrow-A13-${srcDateFile}-treble_arm64_bvN.img
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-treble_arm64_evN.img
xz -cv /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-treble_arm64_evN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-treble_arm64_evN.img.xz
sudo bash ./make-erofs.sh /home/iceows/build-output/Arrow-A13-${srcDateFile}-treble_arm64_bgN.img
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-treble_arm64_egN.img
xz -cv /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-treble_arm64_egN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-treble_arm64_egN.img.xz


# --------------------------------- ArrowOS for Huawei -----------------------------------

# Vanilia
sudo bash ./run-huawei-emui10-ab-a13.sh /home/iceows/build-output/Arrow-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS-Arrow v13.0" "CLT-L29" "Y"
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-clt.img
xz -cv /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-clt.img -T0 > /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-clt.img.xz
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/Arrow-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS-Arrow v13.0" "POT-LX1" "N" "Y"
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-pot.img
xz -cv /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-pot.img -T0 > /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-pot.img.xz
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/Arrow-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS-Arrow v13.0" "ANE-LX1" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-ane.img
xz -cv /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-ane.img.xz

# Google
sudo bash ./run-huawei-emui10-ab-a13.sh /home/iceows/build-output/Arrow-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS-Arrow v13.0" "CLT-L29" "Y"
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-google-clt.img
xz -cv /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-google-clt.img -T0 > /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-google-clt.img.xz
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/Arrow-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS-Arrow v13.0" "POT-LX1" "N" "Y"
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-google-pot.img
xz -cv /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-google-pot.img -T0 > /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-google-pot.img.xz
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/Arrow-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS-Arrow v13.0" "ANE-LX1" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-google-ane.img
xz -cv /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-google-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-google-ane.img.xz


