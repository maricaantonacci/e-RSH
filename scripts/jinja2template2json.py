import jinja2 
import os
import json
import argparse
import sys


parser = argparse.ArgumentParser()
parser.add_argument('--template', nargs=1, type=str, action='store', dest='template_file', required=True, help="template filename")
parser.add_argument('--parameters', nargs=1, type=str, action='store', dest='parameters_file', required=True, help="parameters filename")

results = parser.parse_args()

params_filename=results.parameters_file[0]
template_filename=results.template_file[0]

with open(params_filename) as data_file:    
     data = json.load(data_file)
   
loader=jinja2.FileSystemLoader(os.getcwd())
jenv = jinja2.Environment(loader=loader, trim_blocks=True, lstrip_blocks=True)
template = jenv.get_template(template_filename)
print template.render(data)



