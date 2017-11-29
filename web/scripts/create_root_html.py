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
    div.videos {
        overflow:auto;
    }
    div.v {
        width: 200px;
        height: 160px;
        float:left;
    }
    td {
        text-align: center;
    }
  </style>
</head>
<body>
"""

# One for each clip
html_video_template = """
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

    with open(f) as meta_file:
        meta = json.load(meta_file)

    # The meta file uses relative pathing for m3u8/jpg references
    # so recreate full paths with this where needed
    meta['path'] = os.path.dirname(f)

    metas.append(meta)

metas = sorted(metas, key=lambda m: m['year'])
year = "?"
for meta in metas:

    if meta['year'] != year:
        if year != "?":
            print '</div>'
        year = meta['year']
        print "<div class=\"year\"><h1>%s</h1></div>" % year
        print '<div class="videos">'

    # Note, there has to be an hls or this doesn't work
    title = meta.get('title', meta['hls'])
    html = meta['hls'].replace('.m3u8', '.html')

    div = html_video_template. \
        replace('{title}', title). \
        replace('{html}', "%s/%s" % (meta['path'], html)). \
        replace('{jpg}', "%s/%s" % (meta['path'], meta.get('jpg', '')))

    print div

print '</div>'  # End <div videos>
print html_foot

sys.exit(0)

