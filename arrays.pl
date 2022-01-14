#!/usr/bin/env perl

@summer_months = ("June", "July", "August");

print "$summer_months[0]\n";	# Prints index zero of array @summer_months.

$summer_months[2] = "Blah"; # Change August to Blah

$winter_months[0] = "December"; # Creates @winter_months array.

print "$#winter_months\n";	# Returns 2 because there are three elements in the zero
						# based array.

$a1 = $#autumn_months;	# We don't have an @autumn_months, so this is -1.
$#winter_months = 0;	# Now @winter_months only contains "December".

print "@winter_months\n";
