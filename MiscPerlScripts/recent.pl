#!/usr/bin/env perl
# John's simple reimplementation of recent.pl for home use.

use strict;
use warnings;

=head1 NAME

    recent.pl - Lists recent domains and IPs from the Apache access logs.

=head1 DESCRIPTION
 
    Usage: recent.pl [options]
 
    Options (Defaults):
        num_lines = -1          Tail number of log lines (-1 = all lines)
        num_results = 10        Number of results printed
=cut

use Data::Dumper;
use Pod::Usage;
use Getopt::Long;

# Base Apache access.log format.
# LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined

my %O = (
    num_lines   => -1,
    num_results => 10,
);

GetOptions(\%O,
    'help',
    'num_lines=i',
    'num_results=i') or die();

pod2usage(-verbose => 2, -noperldoc => 1) if $O{help};

die "Must be run as root!\n" if($>);

# Global hashes to store top stats.
my %TOP_IPS;
my %TOP_DOMS;
my %TOP_PATHS;

my $ACCESS_LOG = '/var/log/apache2/access.log';
my $TMP_LOG = '/tmp/tmp.log'; # Hacky short term solution.
my $LOG = $ACCESS_LOG; # Default to whole log.

# If num_lines specified, tail that man lines from access.log.
if ($O{num_lines} >= 0) {
    system("tail -$O{num_lines} $ACCESS_LOG > $TMP_LOG");
    $LOG = $TMP_LOG;
}

open(my $fh, '<:encoding(UTF-8)', $LOG)
    or die "Could not open file '$LOG' $!";

while (my $line = <$fh>) {
    chomp $line;
    # Ignore lines without a valid request type.
    next unless $line =~ /GET|POST|OPTIONS|HEAD|PUT/;
    my @line_arr = split / /, $line;

    $TOP_IPS{$line_arr[1]}++;
    $TOP_DOMS{$line_arr[0]}++;
    $TOP_PATHS{$line_arr[7]}++;
}

close ($fh);

print "\n\t### Top Domains\n\n";
&sort_items(\%TOP_DOMS);
print "\n\t### Top IPs\n\n";
&sort_items(\%TOP_IPS);
print "\n\t### Top Requested Paths\n\n";
&sort_items(\%TOP_PATHS);
print "\n";

exit;

# Subs.

# Sort's hashes by value using a hash slice.
# https://stackoverflow.com/questions/10901084/how-can-i-sort-a-perl-hash-on-values-and-order-the-keys-correspondingly-in-two
sub sort_items {
    my $h = shift;
    my @keys = reverse sort { $h->{$a} <=> $h->{$b} } keys(%$h);
    my $i = 0;
    foreach my $key (@keys) {
        last if ($i >= $O{num_results});
        print "\t\t@{$h}{$key}\t\t$key\n";
        $i++;
    }
}

