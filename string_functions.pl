#!/usr/bin/env perl

# substr(), split() and join()

$a = "With a duffel full of troubles, trunk rattle in the Mazda\n";
$b = "I'm tryna live to ninety-three and see the old me\n";
@c = ("Pop", "through your bubble", "vest", "or double-breasted\n");

print $a;
print substr($a, 0, 13);	# With a duffel full
print "\n";
print substr($a, 14, 18);	# full of troubles,
print "\n";
print substr($a, 32);		# trunk rattle in the Mazda
# Negative index
print substr($a, -6);		# Mazda

print $b;
@b = split(/ /, $b);	# Array with containing words of $b string.
print "@b[2..4]\n";		# Range of words in now @b array.
print "@b[5..9]";		# Range of words in now @b array.


print $c;
print join(' ', @c);
print join('-', @c);
print join(' blah ', @c[0..2]);
print "\n";
