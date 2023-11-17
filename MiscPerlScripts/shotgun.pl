#!/usr/bin/env perl
# This script shoots holes in files.
# Written by John R., Nov. 2023

use strict;
use warnings;

use lib 'perl5/lib/perl5';
use Getopt::Long;
use File::Slurp qw(read_file);
use File::JSON::Slurper qw(read_json write_json);
use File::Touch 0.12;
use IPC::Cmd 'run_forked';
use String::ShellQuote;
use Data::Dumper;
use JSON;

sub usage {
    my $err_msg = shift;
    print "$err_msg\n" if $err_msg;
    print <<~EOF;
      Name:
          shotgun.pl - Shoots holes in files

      Usage:
          shotgun.pl [options]
      
      Options (required, at least one):
          -target                   File you want to shoot holes in
          -reload                   Reload magazine file
          -check                    Check the mag

      Options (optional):
          -help                     Print this help menu
          -type [double|pump]       Shotgun type
          -load [bird|buck|slug]    Type of ammunition
          -shots [int]              Number of shots to fire or load
          -debug                    Debug mode, takes no action
          -verbose                  Verbose mode, more verbose output

      Defaults:
          -type double
          -load bird

    EOF
    exit;
}

my $MAG_FILE = 'mag.txt';

my %O = (
    debug => 0, 
    verbose => 1,
    type => 'double',
    load => 'bird',
    brooklyn => 1,
);

GetOptions(\%O,
    'help',
    'debug',
    'verbose!',
    'target=s',
    'type=s',
    'load=s',
    'shots=i',
    'reload',
    'check',
    'brooklyn!',
) or usage();

$O{verbose}++ if $O{debug};

# Sanity checks.
usage() if $O{help};
usage("Missing required argument!") unless $O{target} or $O{reload} or $O{check};

usage("Invalid shotgun type!") unless($O{type} =~ /double|pump/);
usage("Invalid ammo type!") unless($O{load} =~ /bird|buck|slug/);

unless (-e $MAG_FILE) {
    print "Mag file not found, reloading...\n" if $O{verbose};
    touch($MAG_FILE);
    reload();
}

my $MAG = read_json($MAG_FILE) or die("Problem reading mag file!");

reload() if $O{reload};
check() if $O{check};
exit unless $O{target};
die("Target file does not exits!") unless -e $O{target};
die("Target file must be plain text!") unless -f $O{target};
die("Target file must be under 1 GB!") if -s $O{target} > (1024 * 1024);

unless ($MAG->{$O{type}}) {
    print "Mag for $O{type} not loaded, you'll need to reload!\n";
    exit;
}

if ($MAG->{$O{type}}->{num_rounds} == 0) {
    print "Mag empty, you'll need to reload!\n";
    exit;
}

while ($MAG->{$O{type}}->{num_rounds} > 0) {
    shoot();
    $MAG->{$O{type}}->{num_rounds}--;
    write_json($MAG_FILE, $MAG);
}

exit;

## Subroutines

sub reload {
    my $num_rounds = 2;
    $num_rounds = 5 if $O{type} eq 'pump';
    $num_rounds = $O{shots} if $O{shots} and $O{shots} < $num_rounds;

    my %load = (
        'num_rounds' => $num_rounds,
        'load' => $O{load},
    );

    my %full_load = ($O{type} => \%load);
    write_json($MAG_FILE, \%full_load);
    print "Shotgun reloaded!\n";
    check() if $O{verbose};
}

sub shoot {
    return if $O{debug};
    my @lines = read_file($O{target});

    # We're only going to work in this space. 
    my $height = @lines;
    my $width = 80;

    my $v_buffer = int rand($height);
    my $h_buffer = int rand($width);

    my $v_spread = 7;
    my $h_spread = 13;

    for (my $v=0; $v < $v_spread; $v++) {
        my $v_offset = $v_buffer + $v;

        last if $v_offset >= $height;
        my @line = split '', $lines[$v_offset];

        for (my $h=0; $h < $h_spread; $h++) {
            my $h_offset = $h_buffer + $h;

            # Belt and suspenders.
            last if $h_offset >= @line;
            last if $line[$h_offset] eq "\n";

            if ($O{load} eq 'buck') {
                my @buck = ([6,7], [1,2,6,7], [1,2,11,12], [6,7,11,12], [1,2,6,7], [1,2,9,10], [9,10]);
                for my $holes ($buck[$v]) {
                    $line[$h_offset] = " " if grep {$_ == $h} @$holes;
                }
            } elsif ($O{load} eq 'slug') {
                my @slug = ([5,6,7], [5,6]);
                for my $holes ($slug[$v]) {
                    $line[$h_offset] = " " if grep {$_ == $h} @$holes;
                }
            } else {
                my @bird = ([6], [3,9], [6], [3], [1,6,10], [4], [0,7]);
                for my $holes ($bird[$v]) {
                    $line[$h_offset] = " " if grep {$_ == $h} @$holes;
                }
            }
        }
        $lines[$v_offset] = join('', @line);
    }

    open my $fh, '>', $O{target} or die("Unable to open target file!");
    foreach (@lines) {
        print $fh $_;
    }
    close $fh;

    # For dramatic effect.
    sleep(1) if $O{brooklyn};
    print "POW!\n";
}

sub check {
    $MAG = read_json($MAG_FILE) or die("Problem reading mag file!");
    print JSON->new->ascii->pretty->encode($MAG);
}

