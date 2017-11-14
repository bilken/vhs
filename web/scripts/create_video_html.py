#!/usr/bin/python

import sys
import getopt
import json
import os

help_text = """
create_video_html.py f.meta f.m3u8 f.jpg
    From the specified metadata, m3u8 and jpg, output html for video
"""

template_filename = os.path.join(os.path.dirname(__file__), 'video.template')
with open(template_filename, 'r') as template_file:
    html_template = template_file.read()

if len(sys.argv) != 2:
    print 'Please specify a metadata, m3u8 and jpg file to link'
    sys.exit(1)

with open(sys.argv[1]) as meta_file:
    meta = json.load(meta_file)

path = os.path.dirname(sys.argv[1])

# Note, there has to be an hls or this doesn't work
title = meta.get('title', meta['hls'])

html = html_template. \
    replace('{title}', title). \
    replace('{width}', meta.get('width', '640')). \
    replace('{height}', meta.get('height', '480')). \
    replace('{hls}', "%s" % ( meta['hls'])). \
    replace('{jpg}', "/%s/%s" % (path, meta.get('jpg', '')))

print html

sys.exit(0)

