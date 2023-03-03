#!/bin/bash

#Usage:
#bash sftp-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"

srcDateFile="$1"


# LeaOS Vanilia + Google
for model in ane fig stf cor vtr pot;do
 	lftp sftp://altairfr:xxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/LeaOS-20.0 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-${model}.img.xz; bye"
 	lftp sftp://altairfr:xxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/LeaOS-20.0 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-${model}.img.xz; bye"
 done




