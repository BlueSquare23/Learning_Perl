# Learning Perl

This is a series of notes and scripts I've taken while trying to learn Perl.

I'm using [this guide](https://www.perl.com/pub/2000/10/begperl1.html/) from
[perl.com](https://www.perl.com/) as a starting point.

## First Program

`hello_world.pl`

```
#!/usr/local/bin/perl
print "Hello World!\n";
```

## Functions and Statements

Functions in perl work similar to commands in a normal shell session. Almost
all functions accept a comma-separated list of arguments.

One of the most common functions in perl is the print function.

`print_examples.pl`

```
#!/usr/local/bin/perl
print "This is a single statement.\n";
print "This ", "is ", "a ", "list!";
```

In perl, a *Statement* is any function + args terminated by a semicolon.
Statements don’t need to be on separate lines; there may be multiple statements
on one line or a single statement can be split across multiple lines.

`statement_example.pl`

```
#!/usr/local/bin/perl
print "This is two statements "; print "on one line.\n";
print "This is one statement ",
	"on two lines.\n";
```

## Datatypes

In perl there are two fundamental datatypes, numbers and strings. Perl is
considered a dynamically typed language. Dynamically typed languages are
described thusly by
[Wikipedia](https://en.wikipedia.org/wiki/Type_system#DYNAMIC).

> Dynamic type checking is the process of verifying the type safety of a
> program at runtime.

## Strings & Quotes

In perl strings are a collection of characters within either double or single
quotes.

Single quotes are string literals, meaning their content is not interpreted.
Whereas, strings within double quotes are interpreted, meaning special
character sequences such as \n are converted to their non-ascii meaning.


`single_vs_double_quotes.pl`

```
#!/usr/local/bin/perl
print 'Hello there!\n';
print "Hello there!\n";
```

## Variables

Perl has three types of variables: scalars, arrays and hashes. Think of them as
"things," "lists," and "dictionaries.

### Scalars

Scalars are a single value. They can be a number or a string. The name of a
scalar begins with a dollar sign, like the variable names in bash.

`scalars.pl`

```
#!/usr/local/bin/perl

$i = 5;
$pie_flavor = 'apple';
$constitution1789 = "We the People, etc.";
```

You can do arithmetic operations on scalars as well using the `+`, `-`, `*`, `/`
symbols.

```
$a = 5;
$b = $a + 10;       # $b is now equal to 15.
$c = $b * 10;       # $c is now equal to 150.
$a = $a - 1;        # $a is now 4, and algebra teachers are cringing.
```

There are also shorthand notations for doing assignment arithmetic using these
symbols:  `++`, `--`, `+=`, `-=`, `/=` and `*=`.

```
$a = 5;
$a++;        # $a is now 6; we added 1 to it.
$a += 10;    # Now it's 16; we added 10.
$a /= 2;     # And divided it by 2, so it's 8.
```

You can also concatenate strings using the `.` character. Trying to add strings
using the `+` character won't work in perl. However, perl will convert numbers
in quotes to their numeric value for the operation.

```
$var1 = 5;
$var2 = "blah";
$var3 = "3";
$var4 = $var2 . $var3;	# Concatination of strings.
$var5 = $var1 + $var3;	# Automatic type conversion and addition (only works on numbers).
print "$var4\n";
print "$var5\n";
```

### Arrays

In perl, an array is just a list of scalars. Array names always begin with the
`@` character. You define arrays by listing their contents in parentheses,
separated by commas.

`arrays.pl`

```
#!/usr/local/bin/perl
@summer_months = ("June", "July", "August");
```

To retrieve the elements of an array, you replace the @ sign with a $ sign. In
perl arrays have a zero based index (i.e. first element is at index 0).

```
print "$summer_months[0]\n";	# Prints index zero of array @summer_months.
```

You can change an element in an array by referencing its index number.

```
$summer_months[2] = "Blah"; # Change August to Blah
```

If you assign an element to a non-existent array, Perl will create the array.

```
$winter_months[0] = "December"; # Creates @winter_months array.
```

You can use the `$#array_name` notation in order to find the length of an array.

```
print "$#winter_months\n";	# Returns 2 because there are three elements in the zero
							# based array.
$a1 = $#autumn_months;		# We don't have an @autumn_months, so this is -1.
$#winter_months = 0;		# Now @winter_months only contains "December".
print "@winter_months\n";	
```

### Hash Tables / Dictionaries

In perl an associative array is called a hash table or dictionary. These hash
tables contain key-value pairs.

Dictionary definitions are prefixed by the `%` character. The key value pairs
in a hash table are defined by comma-separated list. Like an array where each
index contains two elements.

`dictionaries.pl`

```
#!/usr/local/bin/perl
%days_in_month = ( "June" => 30, "July" => 31, "August" => 31 );
```

You can retrieve value by specify its key and using the `$` character notation
like with arrays. 

```
print "$days_in_month{June}\n";
```

To get a list of all keys in an associative array use the `keys` function.

```
@month_list = keys %days_in_month
print "@month_list\n";
```

## Numeric Comparison Operators

Perl uses the following typical comparison operators for comparing scalar
values.

`<`, `>`, `==`, `!=`, `<=`, & `>=`

These compairson operators can either return true or false.

## Conditional Statements 

Conditional statements form much of the core logic of perl. They are related to
comparison operators, as the test case inside of the conditionals parenthesis
often involves compairison operators. However, conditionals can be used to test
anything that returns either true or false.

### If Statements

The simplest conditional statement is the `if` statement.

`conditionals.pl`

```
#!/usr/local/bin/perl

$a = 1000;

# Test if variable $a is true (aka has non-zero value).
if ( $a ){
	print "\n";
}

# Test if a is equal to 1000.
if ( $a == 1000){
	print "The value of A, $a\n";
}
```

### Unless Statements

Perl has a special kind of conditional called an `unless` statement. The unless
statement is triggered whenever the test inside of the conditional parenthesis
fails.

```
$bank_ballance = 0;

unless ($bank_ballance > 0){
	print "I'm broke!\n";
}
```

### Elsif and Else Statements

You can use the `elsif` and `else` conditional statements to provide additional
conditionality to a program.

```
if ($a > 10000){
	print "I'm rich!\n";
} elsif ($a >= 1000){
	print "I've got some cash.\n";
} else ($a < 1000){
	print "I'm broke :(\n";
}
```

## String Comparison Operators

Just as there are numeric comparison operators, there are string comparison
operators. The following are the string comparison operators in perl.

`eq`, `ne`, `lt`, `gt`, `le`, `ge`

These mean Equal, Not Equal, Less than, Greater than, Less than or equal, and
Greater than or equal respectively.

`string_compare.pl`

```
#!/usr/local/bin/perl

$a = "blah";
$b = "fart";

if ($a eq "blah") {
	print "Strings are the same.\n";
}

if ($b ne $a) {
	print "Strings are not the same.\n";
}

# The lt, gt, le and ge operators compare by alphebetical order. The string
# blah starts with a 'b' so it is *less than* fart which starts with an 'f'.
# Think which one is further down along the alphabet.
if ($a lt $b) {
	print "$a is alphebetically less than $b.\n";
}

# Blah starts with 'b' which is further along the alphabet than the letter 'a'.
if ($a gt "a") {
	print "$a is alphebetically greater than the letter 'a'.\n";
}

if ($a le "blai") {
	print "$a is alphebetically less than or equal to the string 'blai'.\n";
}

if ($a ge "blag") {
	print "$a is alphebetically greater than or equal to the string 'blag'.\n";
}

```

## Loops

Perl, like any modern programming language, has loops. 

### For Loops

One of the most usful loops in perl is the for loop. A for loop iterates over
an array of data runs the same code over and over again until its reached the
end of the list.

`forloops.pl`

```
#!/usr/local/bin/perl
for $i (1, 2, 3, 4, 5){
	print "$i\n";
}
```

The above code prints the numbers 1 through 5 on seperate lines.

You can use `..` as shorthand for x through y.

```
for $i (6 .. 10){
	print "$i\n";
}
```

Looping over the elements of an array.

```
@summer_months = ("June", "July", "August");

for $month (@summer_months){
	print "$month\n";
}
```

It is also possible to loop over an associative array.

```
%days_in_month = ( "June" => 30, "July" => 31, "August" => 31 );

for $i in (key %days_in_month){
	print "The month of $i has $days_in_month{$i} days in it.\n";
}
```

### While & Until Loops

The next classic loop in programming generally and in perl specifically is the
`while` loop. With a while loop the condition within the parenthesis is first
checked. If that condition returns true then the while loop continues on to
execute the code in the loop body.

Similar to the while loop is the `until` loop. In perl, the until loop runs
*until* a certain condition is true.

`while_and_until_loops.pl`

```
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
```
















