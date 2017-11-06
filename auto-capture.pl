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

    my $fr = 25;
    my @cmd = (
        "ffmpeg",
        # overwrite file name at end
        "-y",
        # Lots of things going on, let there be many threads
        "-threads", "auto",
        # Video input, force frame rate to be $fr, use medium queue
        #"-thread_queue_size", "32",
        "-r", "$fr",
        "-f", "v4l2", "-ts", "abs", "-i", "/dev/video0",
        # Audio input, use larger queue
        "-thread_queue_size", "256",
        "-f", "alsa", "-i", "hw:1,0",
        #"-force_key_frames", "00:00:00.000",
        # Video encoding parameters
        "-r", "$fr",
        "-vcodec", "libx264", "-x264opts", "crf=18",
        "-preset", "ultrafast",
        "-aspect", "4:3", "-pix_fmt", "yuv420p",
        "-maxrate", "8M", "-bufsize", "16M",
        #"-vsync", "1",
        # Audio encoding parameters
        "-acodec", "aac", "-ac", "2", "-ar", "48000",
        "-async", "1",
        "$out_file",

        # Output image parameters
        "-an", "-r", "1/$image_seconds", "-vf", "scale=-1:72", "-updatefirst", "1", "$out_image",
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
        if ($1 < 40 && $2 < 10 && $3 > 200) {
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

my $capture_file = "capture/$dt.ts";
my $preview_image = "capture/preview.jpg";
my $preview_seconds = 4;
my $max_blanks = 4; # Max $preview_seconds*$max_blanks seconds before quit

# Fork off the ffmpeg capture process
my $pid = fork();
if (!$pid) {
    my $r = capture($capture_file, $preview_image, $preview_seconds);
    exit($r);
}

# Watch the preview image. If too many consecutive previews
# are blank, then stop the capture.
my $next_time = time() + $preview_seconds*3;
my $blank_count = 0;

# For WNOHANG
use POSIX ":sys_wait_h";

while (1) {
    my $time_left = $next_time - time();
    while ($time_left > 0) {
        sleep $time_left;
        $time_left = $next_time - time();
    }

    my $res = waitpid($pid, WNOHANG);
    if ($res < 0) {
        last;
    }

    if (is_blank_pic($preview_image)) {
        $blank_count++;
        if ($blank_count >= $max_blanks) {
            print "\nFound $blank_count consecutive blank frames\n";
            print "Killing pid $pid\n";
            kill SIGINT, $pid;
            last;
        }
    } else {
        $blank_count = 0;
    }
    $next_time = $t + $preview_seconds;
}

print "\nWaiting for ffmpeg($pid) to finish\n";
waitpid($pid, 0);

print "\nFinished: $capture_file\n";

