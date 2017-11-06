#!/usr/bin/perl

$file=$ARGV[0];
$seconds=$ARGV[1];
if (not defined $file or not defined $seconds) {
    die "Missing file name or seconds\n";
}

sub printd {
    print @_;
}

sub save_frame {
    my ($file, $seconds, $pic) = @_;

    my $seek_opt = "-ss";
    if ($seconds < 0) {
        $seek_opt = "-sseof";
    }
    $cmd = "ffmpeg -loglevel panic $seek_opt $seconds -i $file -frames:v 1 $pic -y";
    printd("cmd[$cmd]\n");
    `$cmd`
}

sub is_blank_pic {
    my ($pic) = @_;
    my $cmd = "convert $pic -scale 1x1\! -format '%[pixel:u]' info:-";
    my $rgb = `$cmd`;
    printd("cmd[$cmd] rgb[$rgb]\n");
    if ($rgb =~ m/(\d+),(\d+),(\d+)/g) {
        if ($1 < 40 && $2 < 10 && $3 > 200) {
            return 1;
        }
    } elsif ($rgb =~ m/black/g) {
        return 1;
    }
    return 0;
}

# Temp file for conversion
$img = 'capture/f.jpg';
`mkdir -p capture`;

save_frame($file, $seconds, $img);
if (is_blank_pic($img)) {
    # Blank, return 'true'
    exit 0;
}

# Not blank, return 'false'
exit 1;

