#!/usr/bin/env perl

$a = "Rhymes is chosen like the weapons of war\n";

open (FILE1, ">file1.txt") or die "No";
open (FILE2, ">>file2.txt") or die "No";

print FILE1 "$a";

print FILE2 "$a";

close FILE1;
close FILE2;
