#!/usr/bin/perl

my $file=$ARGV[0];
if (not defined $file) {
    die "Missing file name\n";
}

sub media_seconds {
    my ($file) = @_;

    my $ms = `mediainfo --Inform="Video;%Duration%" $file`;
    my $seconds = int($ms / 1000);

    return $seconds;
}

# Search in GOP sized increments
my $gop = 3;

my $seconds = media_seconds($file);
print("Clip[$file] Duration[$seconds" . "s]\n");

# Half the duration of the clip in seconds
my $half_seconds = $seconds / 2;

my $bf = './blank-frame.pl';

$clip_start = 0;
for (my $i = 1; $i < $half_seconds; $i += $gop)
{
    print "\rstart $i";
    $r = system($bf, $file, $i);
    if ($r != 0) {
        last;
    }
    $clip_start += $gop;
}

print "\n";

$clip_end = 0;
for (my $i = 4; $i < $half_seconds; $i += $gop)
{
    print "\rend -$i";
    $r = system($bf, $file, -$i);
    if ($r != 0) {
        last;
    }
    $clip_end += $gop;
}

print "\n";
print "$file $seconds: start $clip_start, end -$clip_end\n"

