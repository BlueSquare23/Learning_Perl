#!/usr/bin/env perl
# John's easy byte conversion sub.

use strict;
use warnings;

die "Usage: convert_bytes int\n" unless defined $ARGV[0];
die "Arg must be an integer!\n" unless $ARGV[0] =~ /^\d+$/;

print convert_bytes($ARGV[0]) . "\n";

sub convert_bytes {
    my $bytes = shift;
    my @units = ('B', 'KB', 'MB', 'GB', 'TB');

    foreach my $unit (@units) {
        if ($bytes < 1024) {
            return sprintf("%.2f %s", $bytes, $unit);
        }
        $bytes /= 1024;
    }
}
