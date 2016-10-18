#!/bin/bash

mkdir -p /onedata/input
mkdir -p /onedata/output

ONECLIENT_AUTHORIZATION_TOKEN="$INPUT_ONEDATA_TOKEN" PROVIDER_HOSTNAME="$INPUT_ONEDATA_PROVIDERS" oneclient --no_check_certificate --authentication token -o ro /onedata/input || exit 1
ONECLIENT_AUTHORIZATION_TOKEN="$OUTPUT_ONEDATA_TOKEN" PROVIDER_HOSTNAME="$OUTPUT_ONEDATA_PROVIDERS" oneclient --no_check_certificate --authentication token -o rw /onedata/output || exit 1

echo Start at $(date)

INPUTDIR="/onedata/input/$INPUT_ONEDATA_SPACE/$INPUT_PATH"
OUTPUTDIR="/onedata/output/$OUTPUT_ONEDATA_SPACE/$OUTPUT_PATH"


WORKDIR=$MESOS_SANDBOX
#WORKDIR="$OUTPUTDIR"

# Extract input
echo Extracting input
#tar xvfz "$INPUTDIR/delft3d_repository.tar.gz" --no-same-owner -C "$WORKDIR" || exit 1
#cd "$WORKDIR"/delft3d_repository/06_delwaq || exit 2

cd /delft3d_repository/examples/06_delwaq || exit 1

if [ ! -z $TEMP ]; then
 sed -i "s/.* ; Temp/$TEMP ; Temp/g" /delft3d_repository/examples/06_delwaq/com-tut_fti_waq.inp || exit 1
 grep "; Temp" /delft3d_repository/examples/06_delwaq/com-tut_fti_waq.inp
fi

echo Run test
# Run Rscript
./run_delwaq.sh || exit 1
tar cvfz "$OUTPUT_FILENAMES" *

# Collect output
mkdir -p "$OUTPUTDIR"/
cp $(echo "$OUTPUT_FILENAMES" | tr ',' ' ' ) "$OUTPUTDIR"/  || exit 1

echo End at $(date)

sleep 5

umount /onedata/input || exit 1
umount /onedata/output || exit 1
