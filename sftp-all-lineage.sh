#!/bin/bash

#Usage:
#bash sftp-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"

srcDateFile="$1"


# LeaOS Vanilia + Google
for model in pot;do
 	lftp sftp://altairfr:xxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/LeaOS-21.0 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-iceows-google-${model}.img.xz; bye"
 done

# LeaOS-GSI Vanilia + Google
for model in arm64_byN;do
	lftp sftp://altairfr:xxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/LeaOS-21.0 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS/21.0/LeaOS-21.0-${srcDateFile}-${model}.img.xz; bye"
done

