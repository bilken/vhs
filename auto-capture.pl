#!/usr/bin/perl

# The '-x264opts crf=*' and '-preset' options control
# the quality vs compression ratio.
#
# The maxrate/bufsize option constrain the maximum video bitrate.
#
# Given these options:
# * The capture phase targets 4GB/hour
# * The transcode phase targets 1GB/hour
#
# I didn't see evidence that a higher bitrate leads to better quality.
# It's just VHS/composite, after all.

sub start_capture {
    my ($out_file) = @_;

    my $vi = "-f v4l2 -i /dev/video0";
    my $vo = "-vcodec libx264 -r 30 -x264opts crf=18 -preset ultrafast" .
             " -aspect 4:3 -pix_fmt yuv420p" .
             " -maxrate 10M -bufsize 20M";
    my $ai = "-f alsa -i hw:1,0";
    my $ao = "-acodec aac -ac 2 -ar 48000 -async 1";

    $cmd = "ffmpeg -y $vi $ai -force_key_frames 00:00:00.000 $vo $ao $out_file";
    print "Capture: $cmd\n";

    my $pid = open(my $fh, "-|", "$cmd 2>&1") or die $!;
    print "Running as pid $pid\n";

    return ($pid, $fh);
}

sub transcode {
    my ($in_file, $out_file) = @_;

    my $vi = "-i $in_file";
    my $vo = "-vcodec libx264 -r 30 -g 10 -x264opts crf=18:keyint=240 -preset slow" .
             " -maxrate 2.5M -bufsize 5M";
    my $ao = "-acodec copy";

    $cmd = "ffmpeg -y $vi $vo $ao $out_file";
    print "Transcode: $cmd\n";

    return system(split(/ /, $cmd));
}

# ffmpeg prints without newlines while processing, so this keeps the main loop running
sub weird_read {
    my ($fh) = @_;
    my $line;
    my $char = 0;
    while (read($fh, $char, 1)) {
        $line .= $char;
        my $o = ord($char);
        if ($o == 10 || $o == 13) {
            print $line;
            return 1;
        }
    }
    return 0;
}

my $dt = `date "+%Y%m%d.%H%M%S"`;
chomp($dt);

`mkdir -p capture`;
`mkdir -p content`;
my $capture_file = "capture/$dt.ts";
my $transcode_file = "content/$dt.ts";
my ($pid, $fh) = start_capture($capture_file);

my $bf = './blank-frame.pl';

my $next_time = time() + 15;

# Make output flush even on a carriage return
select((select(STDOUT), $| = 1)[0]);
while (weird_read($fh)) {
    my $t = time();
    if ($t < $next_time) {
        next;
    }

    $r = system($bf, $capture_file, -10);
    if ($r == 0) {
        $r = system($bf, $capture_file, -5);
        if ($r == 0) {
            print "Found two consecutive blank frames at end of clip\n";
            last;
        }
    }
    $next_time = $t;
}
kill SIGINT, $pid;
close($fh);

my $r = transcode($capture_file, $transcode_file);
print "Finished $r\n";

