#!/usr/bin/env perl
# Test printing a spinner in a fork.

use strict;
use warnings;

use POSIX ":sys_wait_h";
use Time::HiRes;

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
    $|++;
#    my @spin_char = qw(- \ | /);
    my @spin_char = qw(⠈ ⠐ ⠠ ⢀  ⡀ ⠄ ⠂ ⠁);
    my $i = 0;

    while (1) {
        print "\r$spin_char[$i]"; 
        Time::HiRes::sleep(0.05);
        if (@spin_char <= ($i + 1)) {
            $i = 0;
        } else {
            $i++;
        }
    }
}
