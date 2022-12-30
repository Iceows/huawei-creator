#!/bin/bash

#Usage:
#bash build-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"



srcDateFile="$1"


cd ../leaos-aosp
bash aosp_build_leaos/build.sh treble 64BVN
bash aosp_build_leaos/build.sh treble 64BGN

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
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS" "VTR-L09" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-vtr.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvN.img "LeaOS" "POT-LX1" "Y"
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-pot.img
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-ane.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-fig.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-fig.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-stf.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-stf.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-cor.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-cor.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-vtr.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-vtr.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-pot.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-pot.xz

# Google
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "ANE-LX1" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "FIG-LX1" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-fig.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "STF-L09" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-stf.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "COR-AL00" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-cor.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "VTR-L09" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-vtr.img
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgN.img "LeaOS" "POT-LX1" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-pot.img

xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-fig.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-fig.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-stf.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-stf.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-cor.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-cor.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-vtr.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-vtr.xz
xz -c /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-pot.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-pot.xz

