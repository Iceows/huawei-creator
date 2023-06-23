#!/bin/bash

#Usage:
#bash build-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"



srcDateFile="$1"


cd ../leaos-aosp
#bash aosp_build_leaos/build.sh treble 64BVN
#bash aosp_build_leaos/build.sh treble 64BGN

cd ../huawei-creator

# --------------------------------- LeaOS Gsi -----------------------------------

# TrebleDroid ab version
cp /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img /media/iceows/Sauvegardes/ice-rom/TrebleDroid/
cp /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img /media/iceows/Sauvegardes/ice-rom/TrebleDroid/

xz -cv /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img.xz

# TrebleDroid vndklite version
sudo bash ./lite-adapter.sh 64 /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_vvN.img
xz -cv /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_vvN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_vvN.img.xz
sudo bash ./lite-adapter.sh 64 /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_vgN.img
xz -cv /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_vgN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_vgN.img.xz

# TrebleDroid erofs version
sudo bash ./make-erofs.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_evN.img
xz -cv /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_evN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_evN.img.xz
sudo bash ./make-erofs.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_egN.img
xz -cv /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_egN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_arm64_egN.img.xz


# --------------------------------- LeaOS for Huawei -----------------------------------

# Vanilia
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS" "ANE-LX1" "Y" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-ane.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS" "FIG-LX1" "Y" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-fig.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS" "STF-L09" "Y" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-stf.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS" "VTR-L09" "Y" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-vtr.img
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-ane.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-fig.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-fig.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-stf.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-stf.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-vtr.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-vtr.img.xz

# Google
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "ANE-LX1" "Y" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "FIG-LX1" "Y" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-fig.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "STF-L09" "Y" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-stf.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "VTR-L09" "Y" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-vtr.img


xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-fig.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-fig.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-stf.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-stf.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-vtr.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-vtr.img.xz

