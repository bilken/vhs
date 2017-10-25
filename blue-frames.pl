#!/usr/bin/perl

$file=$ARGV[0];
if (not defined $file) {
    die "Missing file name\n";
}

sub printd {
    #print @_;
}

sub media_seconds {
    my ($file) = @_;

    my $ms = `mediainfo --Inform="Video;%Duration%" $file`;
    my $seconds = int($ms / 1000);

    return $seconds;
}

sub save_frame {
    my ($file, $seconds, $pic) = @_;

    my $seek_opt = "-ss";
    if ($seconds < 0) {
        $seek_opt = "-sseof";
    }
    $cmd = "ffmpeg -loglevel panic $seek_opt $seconds -i $file -frames:v 1 $img -y";
    printd("cmd[$cmd]\n");
    `$cmd`
}

sub is_blue_pic {
    my ($pic) = @_;
    my $cmd = "convert tmp/f.jpg -scale 1x1\! -format '%[pixel:u]' info:-";
    my $rgb = `$cmd`;
    printd("cmd[$cmd] rgb[$rgb]\n");
    if ($rgb =~ m/(\d+),(\d+),(\d+)/g) {
        if ($1 < 40 && $2 < 10 && $3 > 200) {
            return 1;
        }
    }
    return 0;
}

# Search in GOP sized increments
$gop = 3;

# Temp file for conversion
$img = 'tmp/f.jpg';
`mkdir -p tmp`;

$seconds = media_seconds($file);
printd("Clip[$file] Duration[$seconds" . "s]\n");

# Half the duration of the clip in seconds
$half_seconds = $seconds / 2;

$clip_start = 0;
for (my $i = 1; $i < $half_seconds; $i += $gop)
{
    save_frame($file, $i, $img);
    if (not is_blue_pic($img)) {
        printd("Not blue at $i\n");
        last;
    }
    printd("Blue at $i\n");
    $clip_start += $gop;
}

$clip_end = 0;
for (my $i = 1; $i < $half_seconds; $i += $gop)
{
    save_frame($file, -$i, $img);
    if (not is_blue_pic($img)) {
        printd("Not blue at -$i\n");
        last;
    }
    printd("Blue at -$i\n");
    $clip_end += $gop;
}

print "$file $seconds: start $clip_start, end -$clip_end\n"

