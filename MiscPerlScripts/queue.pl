#!/usr/bin/env perl
# I want to use perl queues from the shell.
# Written By John R., Feb. 2024

use strict;
use warnings;
$| = 1;

use lib "$ENV{HOME}/perl5/lib/perl5";
use File::JSON::Slurper qw(read_json write_json);
use File::Touch 0.12;
use Data::Dumper;
use JSON;

my $QUEUE_FILE="$ENV{HOME}/.queue.json";
my ($OP, $QUEUE_NAME, $ITEM) = @ARGV;

#print "Operation: $OP\n";
#print "Queue Name: $QUEUE_NAME\n";
#print "Item: $ITEM\n";

# Help menu.
sub usage {
    my $err_msg = shift;
    print "$err_msg\n" if $err_msg;
    print <<~EOF;
      Name:
          queue.pl - Use perl queues from the shell

      Usage:
          queue.pl [help|pop|push|shift|unshift|list|delete] queue_name [item]
      
    EOF
    exit;
}

# Sanity checks.
usage("Missing required args!") if (@ARGV == 0);
usage() if ($OP eq 'help');
usage("Must supply require arg: pop, push, shift, unshift, list, or delete!") unless ($OP);
usage("First arg must be pop, push, shift, unshift, list, or delete!") unless ($OP =~ /pop|push|shift|unshift|list|delete/);

unless (-e $QUEUE_FILE) {
    touch($QUEUE_FILE);
    write_json($QUEUE_FILE, {});
}

my $QUEUE = read_json($QUEUE_FILE) or die("Problem reading queue file!");

# List mode.
if ($OP eq 'list') {
    # if there's no second arg just list queue names.
    unless ($ARGV[1]) {
        if (keys %$QUEUE) {
            print "Queues: \n";
            print "$_\n" foreach (sort keys %$QUEUE);
        } else {
            print "No queues yet defined!\n";
        }
        exit;
    }

    # If there is a second arg list that queue name.
    unless (exists $QUEUE->{$QUEUE_NAME}) {
        print "No queue named: $QUEUE_NAME!\n";
        exit;
    }

    print "Elements of $QUEUE_NAME: \n";
    print "$_\n" foreach (@{$QUEUE->{$QUEUE_NAME}});
    exit;
}

# Delete mode.
if ($OP eq 'delete') {
    check_queue('delete');
    delete($QUEUE->{$QUEUE_NAME});
    write_json($QUEUE_FILE, $QUEUE);
    print "Queue: $QUEUE_NAME deleted!\n";
}

# Push mode.
if ($OP eq 'push') {
    create_or_add('push');
    print "Item: $ITEM appended to queue: $QUEUE_NAME!\n";
    exit;
}

# Unshift mode.
if ($OP eq 'unshift') {
    create_or_add('unshift');
    print "Item: $ITEM prepended to queue: $QUEUE_NAME!\n";
    exit;
}

# Pop mode.
if ($OP eq 'pop') {
    check_queue('pop');
    print pop(@{$QUEUE->{$QUEUE_NAME}}) . "\n";
    write_json($QUEUE_FILE, $QUEUE);
    exit;
}

# Shift mode.
if ($OP eq 'shift') {
    check_queue('shift');
    print shift(@{$QUEUE->{$QUEUE_NAME}}) . "\n";
    write_json($QUEUE_FILE, $QUEUE);
    exit;
}

exit;

## Subs.

sub check_queue {
    my $mode = shift;
    usage("Missing require arg to $mode: queue_name!") unless ($QUEUE_NAME);
    unless (exists $QUEUE->{$QUEUE_NAME}) {
        print "No queue named: $QUEUE_NAME!\n";
        exit;
    }

    return if $mode eq 'delete';

    if (@{$QUEUE->{$QUEUE_NAME}} == 0) {
        print "Queue is empty, cannot $mode from an empty queue!\n";
        exit;
    }
}


sub create_or_add {
    my $mode = shift;
    usage("Missing require arg to $mode: queue_name!") unless ($QUEUE_NAME);
    usage("Missing require arg to $mode: item!") unless ($ITEM);

    my @items;
    # If the queue doesn't exist, create it.
    unless (exists $QUEUE->{$QUEUE_NAME}) {
        $mode eq 'push' ? push(@items, $ITEM) : unshift(@items, $ITEM);
        @{$QUEUE->{$QUEUE_NAME}} = @items;
        write_json($QUEUE_FILE, $QUEUE);
        exit;
    }

    # Otherwise if push append item, if shift prepend item.
    $mode eq 'push' ? push(@{$QUEUE->{$QUEUE_NAME}}, $ITEM) : unshift(@{$QUEUE->{$QUEUE_NAME}}, $ITEM);
    write_json($QUEUE_FILE, $QUEUE);
}

