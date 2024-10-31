#!/usr/bin/perl

use warnings;
use strict;

use Data::Dumper;

use lib '.';
use CaesarCipher;

# Sanity checks.
sub help { die "Usage: caesar_cipher.pl [encode|decode]\n" };
help() if not defined $ARGV[0];
help() if $ARGV[0] =~ /'encode'|'decode'/;

print "Enter message: ";
my $message = <STDIN>;
print "Enter shift value: ";
my $shift_value = <STDIN>;

my $cipher = CaesarCipher->new({shift_index => $shift_value, message => $message});
#print Dumper $cipher;

if ($ARGV[0] eq 'decode') {
    my $decoded_msg = $cipher->decode_msg();
    print "Decoded message: $decoded_msg\n";
    exit;
}

# Default to encode.
my $encoded_msg = $cipher->encode_msg();
print "Encoded message: $encoded_msg\n";

