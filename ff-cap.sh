#!/bin/bash

set -x
set -e

vi="-f v4l2 -i /dev/video0"
vo="-vcodec libx264 -r 30 -g 3 -x264opts crf=18:keyint=90:min-keyint=15 -bitrate 933k -preset ultrafast -aspect 4:3 -pix_fmt yuv422p"
ai="-f alsa -i hw:1,0"
ao="-acodec aac -ac 2 -ar 48000"
dt=cap/`date "+%Y%m%d.%H%M%S"`

ffmpeg -y $vi $ai -force_key_frames 00:00:00.000 $vo $ao $dt.ts

