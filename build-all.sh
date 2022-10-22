#!/bin/bash

#Usage:
#bash build-all.sh "path of the gsi"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"



srcFile="$1"


cd ../leaos-aosp
bash aosp_build_leaos/build.sh treble 64BVS
bash aosp_build_leaos/build.sh treble nosync 64BGS

cd ../huawei-creator
bash sudo run-huawei-ab-a13.sh ${srcFile} "LeaOS" "ANE-LX1" "Y"
