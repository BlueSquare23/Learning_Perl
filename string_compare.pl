#!/usr/local/bin/perl

$a = "blah";
$b = "fart";

if ($a eq "blah") {
	print "Strings are the same.\n";
}

if ($b ne $a) {
	print "Strings are not the same.\n";
}


# The lt, gt, le and ge operators compare by alphebetical order. The string
# blah starts with a 'b' so it is *less than* fart which starts with an 'f'.
# Think which one is further down along the alphabet.
if ($a lt $b) {
	print "$a is alphebetically less than $b.\n";
}

# Blah starts with 'b' which is further along the alphabet than the letter 'a'.
if ($a gt "a") {
	print "$a is alphebetically greater than the letter 'a'.\n";
}

if ($a le "blai") {
	print "$a is alphebetically less than or equal to the string 'blai'.\n";
}

if ($a ge "blag") {
	print "$a is alphebetically greater than or equal to the string 'blag'.\n";
}

