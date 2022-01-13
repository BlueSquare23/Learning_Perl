#!/usr/local/bin/perl

$a = 0;

while ($a <= 7) {
	print "Incrementing $a\n";
	$a++;
}

print "\n";

until ($a == 0) {
	print "Decrementing $a\n";
	$a--;
}
