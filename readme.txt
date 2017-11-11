# Digitize my home VHS movies

## Overview

Primarily, I'm trying to back things up. Secondarily, I'd like my family to be able
to watch these clips easily at home on their phones or computers. I have a backup
drive that's exposed via samba. Since these clips are so large (2GB for a 2 hour
movie), I'd like to make them accessible in a segmented format. My first attempt
is to get it working with HLS and a single TS asset via byte-range. If that
doesn't work, I might switch to fragmented mp4 (dash or HLS/fmp4). If that
doesn't work, screw it; I'll just use mp4.

I bought a cheap composite video/audio USB adapter off amazon:
* http://a.co/a7Opzim 

I already had a VCR and my home computer (a mid-range NUC running Ubuntu). I'll
continue to serve these clips via read-only samba and I'll probably add a web
server with some static-ish pages and a player to serve segmented content.

At first, I was using vlc for encoding, but I switched to ffmpeg.

Video just worked. Well, it presents as 25 fps and 720x576. But ffmpeg seems
to not run right on it's own there. I have to manually override the input
and output frame rate at 25. Took me a while to figure that out. Even then
it wants to use "variable frame rate". Not sure why this is complicated.
* Video Input: f4l2, /dev/video0

Audio on Linux is such a pain. I had to modify my /etc/pulse/default.pa
among other non-sensical things. Took a couple hours of fiddling.
* Audio Input: alsa, hw:1,0

## List of scripts

| Tool | Description |
| ---- | ----------- |
| auto-capture.pl | Capture video/audio and stop at end of tape |
| blank-frames.pl | Find blue (the VCR inactive screen) or black (blank video) |
| blank-frame.pl | Find blue (the VCR inactive screen) or black (blank video) at a particular location (in seconds) |
| hls-byte-range.pl | Given the output of probe.pl, generate an HLS byte-range manifest |
| probe.pl | Find key video frames (pts, time and byte offset) |
| makefile.encode | Build compressed content from captures (after auto-capture.pl) |
| makefile.web | Build m3u8 manifest (and other things) for each encoded clip |
| web/scripts/manifest.py | Create/modify json metadata blob for a clip |

## Software Dependencies

The following items are used during capture and encoding:
* ffmpeg
* convert (imagemagick)
* mediainfo

Things that should already be installed on any normal linux-y system:
* perl
* python
* gnu make

When using the web viewer part (but who besides me would do that?):
* lighttpd

## How to: Capture and conversion

To capture content to a new file, `capture/$datetime.ts`:
```
    ./auto-capture.pl
```

When you have some spare cpu cycles (i.e. when you're not capturing), to encode
all existing captures to more compressed variants. The new encodes are stored in
the `content/` directory but have the same name as their sources in `capture/`.
```
    make -j 1 -f makefile.encode
```

Note that this process does not (yet) delete captured sources. I've been
comparing the capture vs content as I tweak encoding settings.

## Todo Items

1 More automation
** auto-delete capture/ content after transcode completes successfully
** run makefile.web after transcode
** create prune tool to detect blank start/end of clip and modify m3u8 accordingly
2 Create web page
** Create page that actually looks nice
** Use clip image as placeholder
*** Instead of using hard-coded time, look for first "interesting" image
** Use clip metadata to sort content (by year or title or other)
** Update clip metadata form on viewer page
** Highlight clips that point to specific sections of content in addition
    to full clips (like, Karen falling at the wedding, etc.)

