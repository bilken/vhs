#!/bin/bash

vd="v4l2:///dev/video0"
ad="--input-slave=alsa://hw:1,0"
dt=cap/`date "+%Y%m%d.%H%M%S"`

ts="--sout=#transcode{vcodec=h264,vb=800,scale=Auto,acodec=mp4a,ab=128,channels=2,samplerate=48000}:duplicate{dst=file{mux=ts,dst=$dt.ts,no-overwrite}} --sout-avcodec-strict=-2"
mp4="--sout=#transcode{vcodec=h264,acodec=mpga,ab=128,channels=2,samplerate=44100}:duplicate{dst=file{mux=mp4,dst=$dt.mp4,no-overwrite},dst=display}"

gop="--sout-x264-keyint=150 --sout-x264-min-keyint=150"

vlc $vd $ad $ts $gop --sout-keep
#vlc $vd $ad $mp4 --sout-keep --sout-display

