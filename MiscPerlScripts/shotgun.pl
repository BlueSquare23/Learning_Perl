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
      
      Options (required):
          -target                   File you want to shoot holes in
        or
          -reload                   Reload magazine file

      Options (optional):
          -help                     Print this help menu
          -type [double|pump]       Shotgun type
          -load [bird|buck|slug]    Type of ammunition
          -shots [int]              Number of shots to fire
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
) or usage();

# Sanity checks.
usage("Missing required argument!") unless $O{target} or $O{reload};
usage() if $O{help};
$O{verbose}++ if $O{debug};

usage("Invalid shotgun type!") unless($O{type} =~ /double|pump/);
usage("Invalid ammo type!") unless($O{load} =~ /bird|buck|slug/);

reload() if $O{reload};
exit unless $O{target};
die("Target file must be under 1 GB!") if -s $O{target} > 1024 * 1024;
die("Target file must be plain text!") if -f $O{target};

unless (-e $MAG_FILE) {
    print "Mag file not found, reloading...\n" if $O{verbose};
    touch($MAG_FILE);
    reload();
}

my $MAG = read_json($MAG_FILE) or die("Problem reading mag file!");

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
    print "Shotgun reloaded!\n" if $O{verbose};
}

sub shoot {
    return if $O{debug};

   # my @lines = read_file($O{target});
   # foreach $line (@lines) {
   #     
   # }

    # For dramatic effect.
    sleep(1);
    print "POW!\n";
}

