#!/usr/bin/python

import sys
import getopt
import json

help_text = """
metadata.py [--field=name[:value]] filename.meta
    If no options are specified, return metadata file contents
    For each field name with no value specified, the field and
        its value are returned
    For each field name with a value specified, the field value
        is set and the field and its value are returned
    All contents are returned in JSON form
"""

try:
    opts, args = getopt.getopt(sys.argv[1:], "hf:P", ['field='])
except getopt.GetoptError:
    print help_text
    sys.exit(1)

if len(args) != 1:
    print 'Please specify a single metadata file to read/write'
    sys.exit(1)

# Fields from original file
org_json = {}

# Modified fiels (org/starting fields + mod fields)
mod_json = {'title':'', 'year':''}

try:
    with open(args[0]) as org_file:
        org_json = json.load(org_file)
        mod_json = org_json
except:
    pass    # will get written later

filename = args[0]
print_and_exit = False

for opt, arg in opts:
    if opt == '-h':
        print help_text
        sys.exit(0)
    if opt == '-P':
        print_and_exit = True
    if opt in ('-f', '--field'):
        field_parts = arg.split(':')
        field = field_parts[0]
        value = field_parts[1] if len(field_parts) > 1 else None

        if value:
            mod_json[field] = value
        elif field in mod_json:
            value = mod_json[field]
        else:
            value = ''
        if print_and_exit:
            print value
            exit(0)

# If the json blob has changed, rewrite the file
if org_json != mod_json:
    with open(args[0], 'w') as f:
        json.dump(mod_json, f)
    print json.dumps(mod_json)
    sys.exit(0)

print json.dumps(org_json)
sys.exit(0)

