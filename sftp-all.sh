#!/bin/bash

#Usage:
#bash sftp-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"

srcDateFile="$1"


# LeaOS Vanilia + Google
for model in ane fig stf cor vtr pot;do
	lftp sftp://altairfr:xxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/LeaOS-A13 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-${model}.xz; bye"
	lftp sftp://altairfr:xxxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/LeaOS-A13 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-${model}.xz; bye"
done


# LeaOS-GSI Vanilia + Google
for model in arm64_bvN arm64_bgN arm64_evN arm64_egN arm64_vvN arm64_vgN;do
	lftp sftp://altairfr:xxxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/TrebleDroid-GSI ;put /media/iceows/Sauvegardes/ice-rom/TrebleDroid/TrebleDroid-A13-${srcDateFile}-treble_${model}.xz; bye"
done


