#!/bin/bash

#Usage:
#bash sftp-all.sh "yyyymmdd"

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"

srcDateFile="$1"


# Vanilia + Google
for model in ane fig stf cor vtr;do
	lftp sftp://altairfr:xxxx@frs.sourceforge.net -e "cd/home/frs/project/altairfr-huawei/LeaOS-A13 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-${model}.xz'; bye"
	lftp sftp://altairfr:xxxx@frs.sourceforge.net -e "cd/home/frs/project/altairfr-huawei/LeaOS-A13 ;put /media/iceows/Sauvegardes/ice-rom/LeaOS-AOSP/A13/LeaOS-A13-${srcDateFile}-iceows-google-${model}.xz'; bye"
done

