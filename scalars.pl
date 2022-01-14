#!/usr/bin/env perl

$i = 5;
$pie_flavor = 'apple';
$constitution1789 = "We the People, etc.";

$a = 5;
$b = $a + 10;       # $b is now equal to 15.
$c = $b * 10;       # $c is now equal to 150.
$a = $a - 1;        # $a is now 4, and algebra teachers are cringing.

$a = 5;
$a++;        # $a is now 6; we added 1 to it.
$a += 10;    # Now it's 16; we added 10.
$a /= 2;     # And divided it by 2, so it's 8.

$var1 = 5;
$var2 = "blah";
$var3 = "3";
$var4 = $var2 . $var3;	# Concatination of strings.
$var5 = $var1 + $var3;	# Automatic type conversion and addition (only works on numbers).
print "$var4\n";
print "$var5\n";
