#!/usr/bin/perl

my $file=$ARGV[0];
if (not defined $file) {
    die "hls Missing file name\n";
}

sub line_to_tuple {
    my ($line) = @_;
#print "line $line\n";
    if ($line =~ m/time=([\d.]*)/g) {
        my $time = $1;
#print "Got time $time\n";
        if ($line =~ m/pos=([\d]*)/g) {
            my $pos = $1;
#print "Got pos $pos\n";
            if ($pos < 1000) { $pos = 0; } # The first position starts at 0
            return ($time, $pos);
        }
    }
    return (-1, -1);
}

print "#EXTM3U\n";
print "#EXT-X-TARGETDURATION:6\n";
print "#EXT-X-MEDIA-SEQUENCE:0\n";
print "#EXT-X-VERSION:4\n";

sub print_segment {
    my ($time, $pos, $length) = @_;
    printf("#EXTINF:%.1f\n", $time - $last_time);
    print("EXT-X-BYTERANGE:$length\@$pos\n");
    print("$file\n");
}

my $file_size = -s $file;

my $last_time = 0;
my $last_pos = 0;
while (<STDIN>) {
    $line = $_;
    chomp($line);
    my ($time, $pos) = line_to_tuple($line);
    if ($pos < 0) {
#print "Failed $line\n";
        next;
    }
    if ($last_time != 0) {
        print_segment($time - $last_time, $last_pos, $pos - $last_pos);
    }
    $last_time = $time;
    $last_pos = $pos;
}

if ($file_size > $last_pos) {
    # Made up segment duration ...
    print_segment(3.0, $last_pos, $file_size - $last_pos);
}
print("#EXT-X-ENDLIST\n");

