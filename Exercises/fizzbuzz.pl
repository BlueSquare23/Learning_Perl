#!/usr/bin/env perl
# This is my attempt at the classic FizzBuzz challange in perl. The rules of
# FizzBuzz are as follows; increment through the numbers 1 to 100, if the
# number is divisible by 3 say Fizz, if the number is divisable by 5 say Buzz,
# if the number is divisable by 15 say FizzBuzz.
# Writting by John R., Jan. 2022

for $i (1..100) {
	if ($i % 15 == 0) {		# Have to check mod 15 first becuase otherwise
		print "FizzBuzz\n"; # either Fizz or Buzz would be printed for 15
	} elsif ($i % 3 == 0) { # first.
		print "Fizz\n";
	} elsif ($i % 5 == 0) {
		print "Buzz\n";
	} else {
		print "$i\n";
	}
}
