#!/usr/bin/env perl
# This script tails a log by the amount of time provided. For example, you
# could use it to get the last 10 minutes of the Apache access log lines.
# Log timestamps must be formatted: DD/MM/YYYY:HH:MM:SS
# Written by John R., Dec. 2023

use strict;
use warnings;

use Getopt::Long;
use DateTime;
use Date::Parse;
use File::ReadBackwards;

# Change this as needed!
my $DEFAULT_LOG = '/var/log/apache2/access.log';

sub usage {
    my $err_msg = shift;
    print "$err_msg\n" if $err_msg;
    print <<~EOF;
      Name:
              ttail.pl - Tail a log file using increments of time

      Usage:
              ttail.pl [options]
      
      Options (required):
          -time [m|h|s]             Amount of time worth of log to tail

      Options (optional):
          -help                     Print this help menu
          -log [logfile]            Logfile to tail (Defaults to web access log)

    EOF
    exit;
}

my %O = (
    log => $DEFAULT_LOG,
);

GetOptions(\%O,
    'help',
    'log=s',
    'time=s',
) or usage();

# Time is a required arg.
usage("Error: Missing required arg -time!") unless $O{time};

if ($O{time} =~ /^\d+[shmd]?$/) {
    $O{time} = _convert_time();
} else {
    die("Error: Only (s)econds (h)ours (m)inutes (d)ays are supported in string-based time!");
}

# Subtract converted time from current epoch time.
my $TIME_DELTA = time() - $O{time};

# Convert that new time back into recognizable 23hr log format.
my $DT = DateTime->from_epoch( epoch => $TIME_DELTA );
my $TIME_AGO = $DT->ymd('/') . ':' . $DT->hms;

# Loop over log lines in reverse until either timestamp matching converted time
# is encountered or timestamp older than converted time is encountered. Store
# results in queue, then re-reverse queue to get lines in correct order.
my $REV_LOG = File::ReadBackwards->new($O{log}) or
    die("Error: Problem reading $O{log}!");

my @LINES;
while(defined(my $log_line = $REV_LOG->readline)) {
    # Last if line is exact match.
    last if $log_line =~ /$TIME_AGO/;

    # Otherwise, check if line timestamp is older than time ago.
    if ($log_line =~ /(\d\d\/[\w]{3}\/[\d]{4}:\d\d:\d\d:\d\d)/) {
        my $epoch = str2time($1) or die("Error: Failed to convert timestamp!");
        last if ($TIME_DELTA > $epoch);
    } else { next; }
    push @LINES, $log_line;
}
$REV_LOG->close;

die("Error: No lines found!\n") if !@LINES;

foreach (reverse @LINES) { print $_; }

exit;

## Subs.

sub _convert_time {
    my $time = $O{time};

    my %CONVERT = ( s => 1, m => 60, h => 60 * 60, d => 60 * 60 * 24, );
    if ($time =~ /^(\d+)(\D)$/) {
        return $CONVERT{$2} * $1
    } else { return $time }
}

