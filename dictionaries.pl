#!/usr/local/bin/perl

%days_in_month = ( "June" => 30, "July" => 31, "August" => 31 );

print "$days_in_month{June}\n";

@month_list = keys %days_in_month;
print "@month_list\n";
