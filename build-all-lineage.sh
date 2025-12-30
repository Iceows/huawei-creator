#!/bin/bash

#Usage:
#bash build-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"



srcDateFile="$1"


cd ../leaos
#bash lineage_build_leaos/build.sh treble 64YN

cd ../huawei-creator

# --------------------------------- LeaOS Gsi -----------------------------------

# TrebleDroid ab version
cp /home/iceows/build-output/LeaOS-21.0-${srcDateFile}-arm64_byN.img  /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/

xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-arm64_byN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-arm64_byN.img.xz


# --------------------------------- LeaOS lineage 21.0 -----------------------------------

# Google
sudo bash ./run-huawei-emui9-ab-a14.sh /home/iceows/build-output/LeaOS-21.0-${srcDateFile}-arm64_bgN.img "LeaOS" "POT-LX1" "N" "Y"
mv s-erofs.img /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-google-pot.img

xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-google-pot.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-google-pot.img.xz

