#!/bin/bash

#Usage:
#bash sftp-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"

srcDateFile="$1"


# LeaOS Vanilia + Google
for model in ane fig stf vtr cor stk;do
 	lftp sftp://altairfr:xxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/LeaOS-20.0 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-${model}.img.xz; bye"
 	lftp sftp://altairfr:xxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/LeaOS-20.0 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-iceows-google-${model}.img.xz; bye"
 done

# LeaOS-GSI Vanilia + Google
for model in arm64_bvN arm64_bgN;do
	lftp sftp://altairfr:xxx@frs.sourceforge.net -e "cd /home/frs/project/altairfr-huawei/LeaOS-20.0 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS/20.0/LeaOS-20.0-${srcDateFile}-${model}.img.xz; bye"
done

