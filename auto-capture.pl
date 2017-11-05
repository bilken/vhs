#!/usr/bin/perl

# The '-x264opts crf=*' and '-preset' options control
# the quality vs compression ratio.
#
# The maxrate/bufsize option constrain the maximum video bitrate.
#
# Given these options, the capture targets ~4GB/hour.
#
# I didn't see evidence that a higher bitrate leads to better quality.
# It's just VHS/composite, after all.
#
# Note that blank frame detection relies on keyint/framerate as the
# number of seconds to check (roughly). The "$max_gop".
my $max_gop = 8;

sub start_capture {
    my ($out_file) = @_;

    my $fr = 25;
    my $keyint = $max_gop * $fr;
    my $vi = "-f v4l2 -r $fr -i /dev/video0";
    my $vo = "-vcodec libx264 -r $fr -x264opts crf=18:keyint=$keyint -preset ultrafast" .
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
my $capture_file = "capture/$dt.ts";
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

    $r = system($bf, $capture_file, -($max_gop*2));
    if ($r == 0) {
        $r = system($bf, $capture_file, -$max_gop);
        if ($r == 0) {
            print "Found two consecutive blank frames at end of clip\n";
            last;
        }
    }
    $next_time = $t + $max_gop;
}
kill SIGINT, $pid;
close($fh);

