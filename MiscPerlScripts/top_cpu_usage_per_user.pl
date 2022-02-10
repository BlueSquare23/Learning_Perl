#!/usr/bin/perl
# This script collects information about total %CPU usage per user. It exists
# to wrap and sum up the output of `ps` which only presents information about
# individual processes. Re-written in Perl for speed!
# Written by John R., Feb. 2022

use strict;
use warnings;

# Saves ps command output to multi-line @top_pids array.
my @top_pids = `ps -axo %cpu,uid|sort -nr|sed '/CPU/q'|grep -v UID`;

# Gets @top_uids array by parsing @top_pids further.
my @top_uids;

for my $line (@top_pids){
    # Remove leading and trailing spaces and trailing newlines.
    $line =~ s/^\s+|\s+$//g;

    # Arrayifies $line string.
    my @line_array = split(/ {1,}/, $line);
    my $uid = $line_array[1];

    # Checks if $uid already in @top_uids array. Aka uniqify @top_uids.
    if ( not grep { $_ eq $uid } @top_uids ){
        push(@top_uids, $uid);
    }
}

# Print & justify output header.
printf("%5s\t", "CPU%"); print "Username\n";
printf("%5s\t",  "----"); print "----\n";

my %user_cpu_percent_table;

# Loop over @top_uids array.
for my $uid (@top_uids){

    my $user_cpu_percent = 0.0;

    # Loop over @top_pids array line by line.
    for my $line (@top_pids){

        # If $line contains $uid substring,
        if (index($line, $uid) != -1){

            # Lefttrim leading space from $line string.
            $line =~ s/^\s+//; 

            # Arrayify $line string.
            my @line = split(/[\s]+/, $line);

            # Keep track of running CPU% total for current $uid.
            my $pid_percentage = $line[0];
            $user_cpu_percent = $pid_percentage + $user_cpu_percent;
        } 
    }
    
    my $user = `id -un -- $uid`;

    # Creates & populates %user_cpu_percent_table hash table.
    $user_cpu_percent_table{$user} = $user_cpu_percent;
}

# Sorts the keys of the %user_cpu_percent_table hash table highest to lowest
# and prints corrisponding sorted table.
for my $sorted_user (sort { $user_cpu_percent_table{$b} <=> $user_cpu_percent_table{$a} } keys %user_cpu_percent_table){
    printf "%5.1f\t", $user_cpu_percent_table{$sorted_user}; print "$sorted_user";
}

