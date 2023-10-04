#!/bin/bash

#Usage:
#bash build-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"



srcDateFile="$1"


cd ../leaos
#bash lineage_build_leaos/build.sh treble 64VN
#bash lineage_build_leaos/build.sh treble 64GN

cd ../huawei-creator


# --------------------------------- LeaOS Gsi -----------------------------------

# TrebleDroid ab version
cp /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bvN.img  /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/
cp /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bgN.img  /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/

xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-arm64_bvN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-arm64_bvN.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-arm64_bgN.img -T0 >  /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-arm64_bgN.img.xz


# --------------------------------- LeaOS lineage 20.0 -----------------------------------

# Vanilia
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bvN.img "LeaOS" "ANE-LX1" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-ane.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bvN.img "LeaOS" "FIG-LX1" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-fig.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bvN.img "LeaOS" "STF-L09" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-stf.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bvN.img "LeaOS" "COR-AL00" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-cor.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bvN.img "LeaOS" "VTR-L09" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-vtr.img

xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-ane.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-fig.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-fig.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-stf.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-stf.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-cor.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-cor.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-vtr.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-vtr.img.xz


# Google
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bgN.img "LeaOS" "ANE-LX1" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-ane.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bgN.img "LeaOS" "FIG-LX1" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-fig.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bgN.img "LeaOS" "STF-L09" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-stf.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bgN.img "LeaOS" "COR-AL00" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-cor.img
sudo bash ./run-huawei-emui9-ab-a13.sh /home/iceows/build-output/LeaOS-20.0-${srcDateFile}-arm64_bgN.img "LeaOS" "VTR-L09" "N" "N"
mv s-vndklite.img /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-vtr.img


xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-ane.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-ane.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-fig.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-fig.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-stf.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-stf.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-cor.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-cor.img.xz
xz -cv /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-vtr.img -T0 > /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-vtr.img.xz


