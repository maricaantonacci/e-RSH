#!/bin/bash

TOSCA_J2TEMPLATE=tosca_template.j2
INPUTS_J2TEMPLATE=tosca_template_inputs.j2
REQUEST_FILE=job_request.j2
PARAMETERS_FILE=input_parameters.json

cat <<EOF > $REQUEST_FILE
{
    "parameters":{ 
$(cat $INPUTS_J2TEMPLATE)
    },
    "template": "$(cat $TOSCA_J2TEMPLATE | tr '\n' '@' | sed 's/@/\\n/g')"
} 
EOF

BIN_DIR=$(dirname $0)
python "$BIN_DIR"/jinja2template2json.py --template $REQUEST_FILE --parameters $PARAMETERS_FILE

rm $REQUEST_FILE
