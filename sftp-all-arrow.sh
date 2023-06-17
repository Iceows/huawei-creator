#!/bin/bash

#Usage:
#bash sftp-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"

srcDateFile="$1"


# LeaOS Vanilia + Google
for model in clt pot ane;do
 	lftp sftp://altairfr:xxxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/Arrow-13.1 ;put /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-${model}.img.xz; bye"
 	lftp sftp://altairfr:xxxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/Arrow-13.1 ;put /media/iceows/Sauvegardes/ice-rom/Arrow/Arrow-A13-${srcDateFile}-iceows-google-${model}.img.xz; bye"
 done




