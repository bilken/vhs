#!/usr/bin/perl

# The '-x264opts crf=*' and '-preset' options control
# the quality vs compression ratio.
#
# The maxrate/bufsize option constrain the maximum video bitrate.
#
# Given these options, the capture targets ~4GB/hour.
#
# I didn't see evidence that a higher bitrate leads to better quality.

# Note that this outputs a preview image
sub capture {
    my ($out_file, $out_image, $image_seconds) = @_;

    my $fr = 26;
    my @cmd = (
        "ffmpeg",
        # overwrite file name at end
        "-y",
        "-hide_banner",

        # Lots of things going on, let there be many threads
        "-threads", "auto",

        # Video input, force frame rate to be $fr, use medium queue
        "-f", "v4l2",
        #"-standard", "NTSC",
        "-thread_queue_size", "512",
        #"-ts", "abs",
        "-i", "/dev/video0",

        # Output image parameters
        "-an", "-r", "1/$image_seconds", "-vf", "scale=-1:144", "-atomic_writing", "1", "-updatefirst", "1", "$out_image",

        # Audio input, use larger queue
        "-f", "alsa",
        "-thread_queue_size", "512",
        "-i", "hw:1,0",

        # Video encoding parameters
        "-vcodec", "libx264",
        "-preset", "superfast",
        "-crf", "18",
        "-aspect", "4:3",
        "-pix_fmt", "yuv420p",
        "-vf", "fps=fps=$fr",
        "-maxrate", "4M", "-bufsize", "8M",

        # Audio encoding parameters
        "-acodec", "libmp3lame", "-b:a", "128k", "-ac", "2", "-ar", "48000",

        "$out_file",
    );

    print "Command: @cmd\n";
    return exec(@cmd);
}

sub is_blank_pic {
    my ($pic) = @_;
    # this ignores stderr since ffmpeg may be rewriting it
    # while this reads it, causing it to fail spuriously
    my $cmd = "convert $pic -scale 1x1\! -format '%[pixel:u]' info:- 2>/dev/null";
    my $rgb = `$cmd`;
    if ($rgb =~ m/(\d+),(\d+),(\d+)/g) {
        if ($1 < 40 && $2 < 12 && $3 > 200) {
            return 1;
        } elsif ($1 <= 1 && $2 <= 1 && $3 <= 1) {
            return 1;
        }
    } elsif ($rgb =~ m/black/g) {
        return 1;
    }
    return 0;
}

my $dt = `date "+%Y%m%d.%H%M%S"`;
chomp($dt);

`mkdir -p capture`;

my $capture_file = "capture/$dt.mkv";
my $preview_image = "capture/preview.jpg";
my $preview_seconds = 4;
my $max_blank_seconds = 20; # Max blank seconds before auto quit

# Fork off the ffmpeg capture process
my $pid = fork();
if (!$pid) {
    my $r = capture($capture_file, $preview_image, $preview_seconds);
    exit($r);
}

# Watch the preview image. If too many consecutive previews
# are blank, then stop the capture.
my $next_time = time() + $preview_seconds*3;
my $blank_stop_time = 0;

# For WNOHANG
use POSIX ":sys_wait_h";

while (1) {
    while (time() < $next_time) {
        sleep($next_time - time());
    }

    my $res = waitpid($pid, WNOHANG);
    if ($res < 0) {
        last;
    }

    if (is_blank_pic($preview_image)) {
        if ($blank_stop_time == 0) {
            $blank_stop_time = $next_time + $max_blank_seconds;
        }
        if ($next_time >= $blank_stop_time) {
            print "\nFound $max_blank_seconds consecutive blank seconds\n";
            print "Killing pid $pid\n";
            kill SIGINT, $pid;
            last;
        }
    } else {
        $blank_stop_time = 0;
    }
    $next_time = $next_time + $preview_seconds;
}

print "\nWaiting for ffmpeg($pid) to finish\n";
waitpid($pid, 0);

print "\nFinished: $capture_file\n";

