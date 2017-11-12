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

if len(sys.argv) != 4:
    print 'Please specify a metadata, m3u8 and jpg file to link'
    sys.exit(1)

with open(sys.argv[1]) as meta_file:
    meta = json.load(meta_file)

hls = sys.argv[2]
jpg = sys.argv[3]
title = meta['title'] if 'title' in meta else hls

html = html_template.\
    replace('{title}', title). \
    replace('{hls}', hls). \
    replace('{jpg}', jpg)

print html

sys.exit(0)

