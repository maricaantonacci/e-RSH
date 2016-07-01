#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Usage: ./`basename $0` <TOSCA J2 TEMPLATE> <INPUTs JSON FILE>"
	exit 1
fi

TOSCA_J2TEMPLATE=$1
INPUTS_J2TEMPLATE=$(basename $TOSCA_J2TEMPLATE .j2)_inputs.j2
REQUEST_FILE=$(basename $TOSCA_J2TEMPLATE .j2)_request.j2

cat <<EOF > $REQUEST_FILE
{
    "parameters":{ 
$(cat $INPUTS_J2TEMPLATE)
    },
    "template": "$(cat $TOSCA_J2TEMPLATE | tr '\n' '@' | sed 's/@/\\n/g')"
} 
EOF

BIN_DIR=$(dirname $0)
python "$BIN_DIR"/jinja2template2json.py --template $REQUEST_FILE --parameters $2

rm $REQUEST_FILE
