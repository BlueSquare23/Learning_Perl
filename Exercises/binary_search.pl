#!/usr/bin/env perl
# This script is my attempt at implementing a binary search algorithm in Perl.
# A binary search algorithm finds the position of a target value within a
# sorted array. "Binary search compares the target value to the middle element
# of the array. If they are not equal, the half in which the target cannot lie
# is eliminated and the search continues on the remaining half, again taking
# the middle element to compare to the target value, and repeating this until
# the target value is found."
# https://en.wikipedia.org/wiki/Binary_search_algorithm
# Written by John R., Jan. 2022.

sub usage {
	print "Usage:\n\t\tbinary_search.pl NUM\n\n";
	print "Where NUM is an integer between 0 and 100.\n";
	exit
}

$target = @ARGV[0];

# Checking user input, must be an int between 0 and 100.
if (not defined $target) {
	usage;
} elsif ($target !~ /^-?\d+$/) {
	usage;
} elsif ($target >= 100 ) {
	usage;
} elsif($target <= 0) {
	usage;
}

@list = (0..100);

sub half {
	return int($_[0] / 2);
}

# Guess index position.
$guess_pos = &half($#list);

# Guess value based on @list.
$guess = $list[$guess_pos];

while ($target != $guess) {
	# If the target is larger than the guess, create a new array containing all
	# of the elements between the guess and the end of the previous array.  
	if ($target > $guess) {
		print "Greater than $guess\n";
		@list = ($guess..$list[-1]);
		# Then get the halfway index of the new array.
		$guess_pos = &half($#list);
		# And use it to obtain the new halved guess value.
		$guess = $list[$guess_pos];
	}
	# Else if the target is smaller than the guess, create a new array
	# containing all of the element between the start of the old list and the
	# guess value.
	else {
		print "Less than $guess\n";
		@list = ($list[0]..$guess); 
		# Then get the halfway index of the new array.
		$guess_pos = &half($#list); 
		# And use it to obtain the new halved guess value.
		$guess = $list[$guess_pos];
	}	
}

print "The target value is: $guess\n";
