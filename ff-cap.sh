#!/bin/bash

set -x
set -e

vi="-f v4l2 -i /dev/video0"
vo="-vcodec libx264 -r 30 -g 3 -x264opts crf=28:keyint=90:min-keyint=15 -preset ultrafast -aspect 4:3 -pix_fmt yuv420p"
ai="-f alsa -i hw:1,0"
ao="-acodec aac -ac 2 -ar 48000"
dt=cap/`date "+%Y%m%d.%H%M%S"`

# command to retransmit
#echo ffmpeg-re -i $dt.ts -vcodec copy -acodec copy -f mpegts udp://127.0.0.1:5001?pkt_size=1316

ffmpeg -y $vi $ai -force_key_frames 00:00:00.000 $vo $ao -f mpegts -async 1 $dt.ts

