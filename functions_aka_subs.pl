#!/usr/bin/env perl

sub square {
	@ops = @_;
	return $ops[0] * $ops[0];
}

for $i (1..10) {
	print "$i squared is: ", &square($i), "\n";
}
