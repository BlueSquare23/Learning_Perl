#!/usr/bin/env perl
# This script shoots holes in files.
# Written by John R., Nov. 2023

use strict;
use warnings;

use lib "$ENV{HOME}/perl5/lib/perl5";
use Getopt::Long;
use File::Slurp qw(read_file);
use File::JSON::Slurper qw(read_json write_json);
use File::Touch 0.12;
use IPC::Cmd 'run_forked';
use String::ShellQuote;
use Data::Dumper;
use JSON;

# Change as needed. Tested and should work with `aplay` and `mpv` on Ubuntu.
my $AUDIO_PLAYER = '/usr/bin/mpv';

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
          -quiet                    Mute sound effect
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
    'check',
    'quiet',
) or usage();

$O{verbose}++ if $O{debug};
$O{verbose} =  0 if $O{quiet};

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

reload() if $O{reload};
check() if $O{check};
exit unless $O{target};
die("Target file does not exits!") unless -e $O{target};
die("Target file must be plain text!") unless -f $O{target};
die("Target file must be under 1 GB!") if -s $O{target} > (1024 * 1024);

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
    unless ($O{quiet}) {
        for (my $i = 0; $i < $num_rounds; $i++) {
            print "Loading shot $i\n" if $O{verbose};
            run_forked(join(" ", $AUDIO_PLAYER, "$O{type}_reload.wav"));
        }
    }
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

    my $r = int rand(3);
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
                my %pattern0 = (0=>[6,7],
                             1=>[1,2,6,7],
                             2=>[1,2,11,12],
                             3=>[6,7,11,12],
                             4=>[1,2,6,7],
                             5=>[1,2,9,10],
                             6=>[9,10]);
                my %pattern1 = (0=>[1,2,9,10],
                             1=>[1,2,9,10],
                             2=>[5,6],
                             3=>[1,5,6,10,11],
                             4=>[1,2,10,11],
                             5=>[6,7],
                             6=>[6,7]);
                my %pattern2 = (0=>[5,6,7],
                             1=>[1,2,6,10,11],
                             2=>[1,2,10,11],
                             3=>[5,6,7],
                             4=>[1,2,6],
                             5=>[1,2,10],
                             6=>[9,10]);
                my %buck = (0 => \%pattern0,
                            1 => \%pattern1,
                            2 => \%pattern2);

                $line[$h_offset] = " " if grep {$_ == $h} @{$buck{$r}->{$v}};
            } elsif ($O{load} eq 'slug') {
                my %pattern0  = (0=>[5,6,7], 1=>[5,6]);
                my %pattern1 = (0=>[5,6], 1=>[5,6,7]);
                my %pattern2 = (0=>[5,6], 1=>[4,5,6]);
                my %slug = (0 => \%pattern0,
                            1 => \%pattern1,
                            2 => \%pattern2);
                $line[$h_offset] = " " if grep {$_ == $h} @{$slug{$r}->{$v}};
            } else {
                my %pattern0 = (0=>[6],
                                1=>[3,9],
                                2=>[6],
                                3=>[3],
                                4=>[1,6,10],
                                5=>[4],
                                6=>[0,7]);
                my %pattern1 = (0=>[6],
                                1=>[3,9],
                                2=>[6,11],
                                3=>[3,7,9],
                                4=>[6,10],
                                5=>[4,9],
                                6=>[7,11]);
                my %pattern2 = (0=>[6,9],
                                1=>[2,4,7],
                                2=>[5,9],
                                3=>[1,7],
                                4=>[6],
                                5=>[3,6,9],
                                6=>[5]);
                my %bird = (0 => \%pattern0,
                            1 => \%pattern1,
                            2 => \%pattern2);
                $line[$h_offset] = " " if grep {$_ == $h} @{$bird{$r}->{$v}};
            }
            $lines[$v_offset] = join('', @line);
        }
    }

    open my $fh, '>', $O{target} or die("Unable to open target file!");
    foreach (@lines) {
        print $fh $_;
    }
    close $fh;

    # For dramatic effect.
    print "POW!\n" and return if $O{quiet};
    run_forked(join(" ", $AUDIO_PLAYER, "$O{type}.wav"));
    print "POW!\n";
    run_forked(join(" ", $AUDIO_PLAYER, "shot.wav"));
}

sub check {
    $MAG = read_json($MAG_FILE) or die("Problem reading mag file!");
    print JSON->new->ascii->pretty->encode($MAG);
}

