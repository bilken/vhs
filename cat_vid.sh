#!/bin/bash

# Sometimes the capture would stop (my fault or computer)
# When that happens, this script pastes the clips back together.

set -x

pathname=`dirname $1`

sep="/"
list=$dt.txt
for f in $*; do
    echo "file '$f'" >> $list
    bn=`basename $f | sed 's;.MP4;;g'`
    pathname="$pathname$sep$bn"
    sep="-"
done
#ffmpeg -f concat -i $list -c copy $pathname.mkv
ffmpeg -f concat -i $list -c copy $pathname.MP4
rm $list

