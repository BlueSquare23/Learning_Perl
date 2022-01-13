#!/usr/local/bin/perl

for $i (1, 2, 3, 4, 5){
	print "$i\n";
}

for $i (6 .. 10){
	print "$i\n";
}

@summer_months = ("June", "July", "August");

for $month (@summer_months){
	print "$month\n";
}

%days_in_month = ( "June" => 30, "July" => 31, "August" => 31 );

for $i (keys %days_in_month){
	print "The month of $i has $days_in_month{$i} days in it.\n";
}

