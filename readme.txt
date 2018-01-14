# Digitize my home movies

## Overview

Primarily, I'm trying to back things up. Secondarily, I'd like my family to be able
to watch these clips easily at home on their phones or computers. I have a backup
drive that's exposed via samba. Since these clips are so large (2GB for a 2 hour
movie), I'd like to make them accessible in a segmented format. My first attempt
is to get it working with HLS and a single TS asset via byte-range. If that
doesn't work, I might switch to fragmented mp4 (dash or HLS/fmp4). If that
doesn't work, screw it; I'll just use mp4.

## VHS

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

## 8mm

We have a ton of super 8 film. I bought the "Wolverine Pro" conversion device.
It generates MP4 clips.

The only issue I had is that my device seems to grab the film a little too
tight on the capture tray. When that happens, it stalls and generates duplicate
images (sometimes stalling indefinitely until I manually intervene :-( ).
The content is also pretty grainy (our cameras weren't very nice), so I
down-res from 1440x1080 to 720x540 so it looks a little cleaner.

## List of scripts

| Tool | Description |
| ---- | ----------- |
| auto-capture.pl | Capture video/audio and stop at end of tape |
| makefile | Build compressed content from captures (after auto-capture.pl) |
| web/makefile | Build m3u8 manifests and html to view encoded clips |

Supporting tools:
* blank-frames.pl - Find blue (the VCR inactive screen) or black (blank video)
* blank-frame.pl - Find blue (the VCR inactive screen) or black (blank video) at a particular location (in seconds)
* hls-byte-range.pl - Given the output of probe.pl, generate an HLS byte-range manifest
* probe.pl - Find key video frames (pts, time and byte offset)
* web/scripts/manifest.py - Create/modify json metadata blob for a clip
* web/scripts/create_video_html.py - Create html for a single clip (will probably go away)
* web/scripts/create_root_html.py - Create html to link all clips

## Software Dependencies

The following items are used during capture and encoding:
* ffmpeg
* convert (imagemagick)
* mediainfo

Things that should already be installed on any normal linux-y system:
* perl
* python
* gnu make
* normal unix tools: mv, mkdir, find, file, touch, ln, echo, date, grep, sed

For my web server, using the default config:
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
    make
```

Note that this process does not (yet) delete captured sources. I've been
comparing the capture vs content as I tweak encoding settings.

## Todo Items

0 Backup metadata files
1 More automation
** Add title, year, description metadata to auto-capture somehow
** auto-capture could both start and stop automatically (wait for not blank to start)
** auto-delete capture/ content after transcode completes successfully
** run makefile.web after transcode
** create prune tool to detect blank start/end of clip and modify m3u8 accordingly
*** Or just lop the final 20 seconds off since it's almost always blank
2 Create web page
** Create page that actually looks nice
** Update clip metadata form on viewer page
** Highlight clips that point to specific sections of content in addition
    to full clips (like, Karen falling at the wedding, etc.)
** Link to existing phone mov/mp4 clips
** Integrate with 8mm capture/encode pipeline

