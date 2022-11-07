#!/bin/bash

#Usage:
#bash build-all.sh "path of the gsi"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"



srcDateFile="$1"


cd ../leaos-aosp
#bash aosp_build_leaos/build.sh treble 64BVS
#bash aosp_build_leaos/build.sh treble nosync 64BGS

cd ../huawei-creator

# Vanilia
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bvS.img "LeaOS" "ANE-LX1" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-ane.img
#xz -z /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-ane.img

# Google
sudo bash ./run-huawei-ab-a13.sh /home/iceows/build-output/TrebleDroid-A13-${srcDateFile}-treble_arm64_bgS.img "LeaOS" "ANE-LX1" "Y"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.img
#xz -z /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-ane.img

