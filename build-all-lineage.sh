#!/bin/bash

#Usage:
#bash build-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"



srcDateFile="$1"


cd ../leaos
#bash lineage_build_leaos/build.sh treble 64ON
#bash lineage_build_leaos/build.sh treble 64YN

cd ../huawei-creator

# --------------------------------- LeaOS Gsi -----------------------------------

# TrebleDroid ab version
cp ~/build-output/LeaOS-21.0-${srcDateFile}-arm64_byN.img  /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/
cp ~/build-output/LeaOS-21.0-${srcDateFile}-arm64_boN.img  /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/

xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-arm64_byN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-arm64_byN.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-arm64_boN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-arm64_boN.img.xz

# --------------------------------- LeaOS lineage 21.0 -----------------------------------

# Google
sudo bash ./run-huawei-emui9-ab-a14.sh ~/build-output/LeaOS-21.0-${srcDateFile}-arm64_byN.img "LeaOS" "POT-LX1" "N" "Y"
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-google-pot.img
sudo bash ./run-huawei-emui9-ab-a14.sh ~/build-output/LeaOS-21.0-${srcDateFile}-arm64_byN.img "LeaOS" "ANE-LX1" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-google-ane.img

# Vanilia
sudo bash ./run-huawei-emui9-ab-a14.sh ~/build-output/LeaOS-21.0-${srcDateFile}-arm64_boN.img "LeaOS" "POT-LX1" "N" "Y"
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-pot.img
sudo bash ./run-huawei-emui9-ab-a14.sh ~/build-output/LeaOS-21.0-${srcDateFile}-arm64_boN.img "LeaOS" "ANE-LX1" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-ane.img

# Potter
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-pot.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-pot.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-google-pot.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-google-pot.img.xz

# Ane
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-ane.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-google-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-google-ane.img.xz


