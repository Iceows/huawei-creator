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

# Vanilia
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS" "ANE-LX1" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-ane.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS" "FIG-LX1" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-fig.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS" "STF-L09" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-stf.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS" "COR-AL00" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-cor.img
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-ane.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-fig.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-fig.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-stf.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-stf.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-cor.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-cor.xz

# Google
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "ANE-LX1" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "FIG-LX1" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-fig.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "STF-L09" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-stf.img
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-fig.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-fig.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-stf.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-stf.xz



