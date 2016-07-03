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

# Collect input
cp "$INPUTDIR"/* "$WORKDIR"/ || exit 1
cd "$WORKDIR" || exit 2

echo Run test
# Run Rscript
Rscript testcumul_error.R sde_day_count-09-06.out "$PARAMETER_N" || exit 1

# Collect output
mkdir -p "$OUTPUTDIR"/
cp $(echo "$OUTPUT_FILENAMES" | tr ',' ' ' ) "$OUTPUTDIR"/  || exit 1

echo End at $(date)

sleep 5

umount /onedata/input || exit 1
umount /onedata/output || exit 1
