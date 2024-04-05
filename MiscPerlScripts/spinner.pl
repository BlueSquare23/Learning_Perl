#!/usr/bin/env perl
# Test printing a spinner in a fork.

use strict;
use warnings;
use locale;

use POSIX ":sys_wait_h";
use Time::HiRes;

$|++;

print "Doing the needful...\n";

my $pid;
system("tput civis"); # Hide cursor.
# Fork the spinner process.
if (!defined($pid = fork)) {
    die "Cannot fork: $!";
} elsif ($pid == 0) {
    # Child process runs the spinner.
    spinner();
    exit;
}

# Parent process waits for a few seconds, then sends a signal to kill the
# spinner.
sleep 5;
kill('TERM', $pid);

# Wait for the spinner to finish.
waitpid($pid, 0);
system("tput cnorm"); # Show cursor when done.

print "\rNeedful done!\n";
print "Doing some other stuff...\n";

sub spinner {
    my @spin_char;
    my $t;

    # Check for unicode support.
    my $lc_all_exists = exists $ENV{'LC_ALL'};
    my $lc_ctype_exists = exists $ENV{'LC_CTYPE'};
    my $lang_exists = exists $ENV{'LANG'};

    # Check if the environment variables exist and contain UTF-8.
    if (($lc_all_exists && $ENV{'LC_ALL'} =~ /UTF-8/i) ||
        ($lc_ctype_exists && $ENV{'LC_CTYPE'} =~ /UTF-8/i) ||
        ($lang_exists && $ENV{'LANG'} =~ /UTF-8/i)) {
        $t = 0.05;
        @spin_char = qw(⠈ ⠐ ⠠ ⢀  ⡀ ⠄ ⠂ ⠁);
    } else {
        $t = 0.25;
        @spin_char = qw(- \ | /);
    }

    my $i = 0;

    while (1) {
        print "\r$spin_char[$i]"; 
        Time::HiRes::sleep($t);
        if (@spin_char <= ($i + 1)) {
            $i = 0;
        } else {
            $i++;
        }
    }
}
