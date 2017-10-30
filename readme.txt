Digitize my home VHS movies

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

Video just worked. Well, it presents as 25 fps and 720x576 when I think it's
really 30 fps (or maybe 29.97):
* Video Input: f4l2, /dev/video0

Audio on Linux is such a pain. I had to modify my /etc/pulse/default.pa
among other non-sensical things. Took a couple hours of fiddling.
* Audio Input: alsa, hw:1,0

| tool | description |
| ----- | ----- |
| auto-capture.pl | Capture video/audio and stop at end of tape |
| ff-cap.sh | Capture video/audio with ffmpeg to a TS (or mp4) |
| blank-frames.pl | Find blue (the VCR inactive screen) or black (blank video) |
| blank-frame.pl | Find blue (the VCR inactive screen) or black (blank video) at a particular location (in seconds) |
| hls-byte-range.pl | Given the output of probe.pl, generate an HLS byte-range manifest |
| probe.pl | Find key video frames (pts, time and byte offset) |
| prune.pl | (TBD) Given start/end parameters, strips 0..start seconds and -end..media_length |
| vhs-cap.sh | Capture video/audio with vlc to TS (or mp4) |
