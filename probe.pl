#!/usr/bin/perl

$file=$ARGV[0];
if (not defined $file) {
    die "Missing file name\n";
}

sub printd {
    #print @_;
}

sub print_idr_frames {
    my ($file) = @_;

    my $ffprobe = "ffprobe -select_streams 0:0 -show_frames -i $file 2>&1";
    my @fields = map{'-e ^' . $_} ('.FRAME', 'pkt_pos', 'pkt_pts', 'key_frame');
    my $grep = "grep " . join(' ', @fields);
    my $cmd = "$ffprobe | $grep";
    printd("cmd[$cmd]\n");

    my $cap = 0;
    my @info = ();
    open my $pipe, '-|', "$cmd";
    while (my $line = <$pipe>) {
        #printd("  $line");
        if ($line =~ m/FRAME/) {
            if (@info) {
                chomp(@info);
                print " @info\n";
            }
            $cap = 1;
        } elsif ($cap != 0) {
            if ($line =~ m/key_frame/) {
                $line =~ m/=(.*)/;
                $cap = $1;
                @info = ();
            } else {
                $line =~ m/=(.*)/;
                push @info, $line;
            }
        }
    }
    close $pipe;
}

print "$file IDR frames\n";
print_idr_frames($file);

