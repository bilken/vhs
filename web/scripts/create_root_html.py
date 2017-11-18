#!/usr/bin/python

import sys
import getopt
import json
import os

help_text = """
create_root_html.py a.meta [b.meta c.meta ...]
    From the specified video metadata, output the root html
"""

html_head = """
<!DOCTYPE html>
<html>
<head>
  <title>Videos</title>
  <style>
    div.v {
        float: left;
        width: 200px;
        height: 160px;
    }
    td {
        text-align: center;
    }
  </style>
</head>
<body>
"""

# One for each clip
html_div_template = """
<div class="v">
  <table>
  <tr><td>
    <a href="{html}"><img src="{jpg}" height="90" /></a>
  </td></tr>
  <tr><td>
    {title}
  </td></tr>
  </table>
</div>
"""

html_foot = """
</body>
</html>
"""

if len(sys.argv) < 2:
    print 'Please specify video metadata file(s) to reference'
    sys.exit(1)

print html_head

metas = []
for f in sys.argv[1:]:

    # The meta file uses relative pathing for m3u8/jpg references
    # so recreate full paths with this where needed
    path = os.path.dirname(f)

    with open(f) as meta_file:
        meta = json.load(meta_file)
    metas.append(meta)

metas = sorted(metas, key=lambda m: m['year'])

for meta in metas:

    # Note, there has to be an hls or this doesn't work
    title = meta.get('title', meta['hls'])
    html = meta['hls'].replace('.m3u8', '.html')

    div = html_div_template. \
        replace('{title}', title). \
        replace('{html}', "%s/%s" % (path, html)). \
        replace('{jpg}', "%s/%s" % (path, meta.get('jpg', '')))

    print div

print html_foot

sys.exit(0)

