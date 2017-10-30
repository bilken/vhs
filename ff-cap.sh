#!/bin/bash

if [ $# -eq 0 ]; then
    echo Missing capture file name
    echo   use $$path/name.ts for transport stream
    echo   use $$path/name.mp4 for mp4
    exit 1
fi

#set -x
set -e

vi="-f v4l2 -i /dev/video0"
vo="-vcodec libx264 -r 30 -g 3 -x264opts crf=28:keyint=90:min-keyint=15 -preset ultrafast -aspect 4:3 -pix_fmt yuv420p"
ai="-f alsa -i hw:1,0"
ao="-acodec aac -ac 2 -ar 48000 -async 1"

ffmpeg -y $vi $ai -force_key_frames 00:00:00.000 $vo $ao $1

