#!/bin/bash

mkdir -p /onedata/input
mkdir -p /onedata/output

ONECLIENT_AUTHORIZATION_TOKEN="$INPUT_ONEDATA_TOKEN" PROVIDER_HOSTNAME="$INPUT_ONEDATA_PROVIDERS" oneclient --no_check_certificate --authentication token -o ro /onedata/input || exit 1
ONECLIENT_AUTHORIZATION_TOKEN="$OUTPUT_ONEDATA_TOKEN" PROVIDER_HOSTNAME="$OUTPUT_ONEDATA_PROVIDERS" oneclient --no_check_certificate --authentication token -o rw /onedata/output || exit 1

echo Start at $(date)

INPUTDIR="/onedata/input/$INPUT_ONEDATA_SPACE/$INPUT_PATH"
OUTPUTDIR="/onedata/output/$OUTPUT_ONEDATA_SPACE/$OUTPUT_PATH"

mkdir -p "$OUTPUTDIR" # create if it does not exists
TEMPW=$(mktemp -d --tmpdir="$OUTPUTDIR" workspace.XXXXXXXXXX)

WORKDIR="$OUTPUTDIR"/$TEMPW

# Extract input
echo Extracting input

find "$INPUTDIR" -name "*.tar.gz" -exec tar xvfz {} --no-same-owner -C "$WORKDIR" \; || exit 1
cd "$WORKDIR" || exit 2
chmod 777 ./*.sh

echo Editting $D3D_PARAM with value $D3D_VALUE

if [ ! -z $D3D_PARAM ]; then
 sed -i "s/.* ; $D3D_PARAM/$D3D_VALUE ; $D3D_PARAM/g" $INPUT_CONFIG_FILE || exit 1
 grep "; $D3D_PARAM" $INPUT_CONFIG_FILE
fi

echo Run test
# Run Rscript
./run_delwaq.sh || exit 1
# Collect output
tar cvfz "$OUTPUTDIR"/output.tgz * || exit 1

echo Cleaning temp workspace
rm -rf "$WORKDIR"
cd -


echo End at $(date)

sleep 5

umount /onedata/input || exit 1
umount /onedata/output || exit 1
