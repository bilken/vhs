#!/bin/bash

# Sometimes the capture would stop (my fault or computer)
# When that happens, this script pastes the clips back together.

set -x

dt=`date "+%Y%m%d.%H%M%S"`

list=$dt.txt
for f in $*; do
    echo "file '$f'" >> $list
done
#ffmpeg -f concat -i $list -c copy $dt.mkv
ffmpeg -f concat -i $list -c copy $dt.MP4
rm $list

