# Learning Perl

This is a series of notes and scripts I've taken while trying to learn Perl.

I'm using [this guide](https://www.perl.com/pub/2000/10/begperl1.html/) from
[perl.com](https://www.perl.com/) as a starting point.

The example programs live in the Examples sub directory. Each one of those
scripts is independantly executable. Much of that code is borrowed from the
above guide and only slightly altered.

To see Perl code I've written myself check in the Exercises directory. Within
that folder are a number of perl programs I've written as tests to help me get
better at writing perl.

## First Program

`Examples/hello_world.pl`

```
#!/usr/bin/env perl
print "Hello World!\n";
```

## Functions and Statements

Functions in perl work similar to commands in a normal shell session. Almost
all functions accept a comma-separated list of arguments.

One of the most common functions in perl is the print function.

`Examples/print_examples.pl`

```
#!/usr/bin/env perl
print "This is a single statement.\n";
print "This ", "is ", "a ", "list!";
```

In perl, a *Statement* is any function + args terminated by a semicolon.
Statements don’t need to be on separate lines; there may be multiple statements
on one line or a single statement can be split across multiple lines.

`Examples/statement_example.pl`

```
#!/usr/bin/env perl
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


`Examples/single_vs_double_quotes.pl`

```
#!/usr/bin/env perl
print 'Hello there!\n';
print "Hello there!\n";
```

## Variables

Perl has three types of variables: scalars, arrays and hashes. Think of them as
"things," "lists," and "dictionaries.

### Scalars

Scalars are a single value. They can be a number or a string. The name of a
scalar begins with a dollar sign, like the variable names in bash.

`Examples/scalars.pl`

```
#!/usr/bin/env perl

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

`Examples/arrays.pl`

```
#!/usr/bin/env perl
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

`Examples/dictionaries.pl`

```
#!/usr/bin/env perl
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

These comparison operators can either return true or false.

## Conditional Statements 

Conditional statements form much of the core logic of perl. They are related to
comparison operators, as the test case inside of the conditionals parenthesis
often involves comparison operators. However, conditionals can be used to test
anything that returns either true or false.

### If Statements

The simplest conditional statement is the `if` statement.

`Examples/conditionals.pl`

```
#!/usr/bin/env perl

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
$bank_balance = 0;

unless ($bank_balance > 0){
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

`Examples/string_compare.pl`

```
#!/usr/bin/env perl

$a = "blah";
$b = "fart";

if ($a eq "blah") {
	print "Strings are the same.\n";
}

if ($b ne $a) {
	print "Strings are not the same.\n";
}

# The lt, gt, le and ge operators compare by alphabetical order. The string
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

## Sting Functions

Perl has a few built in functions that we can use to manipulate strings. 

`Examples/string_functions.pl`

```
#!/usr/bin/env perl

# substr(), split() and join()

$a = "With a duffel full of troubles, trunk rattle in the Mazda!\n";
$b = "I'm tryna live to ninety-three and see the old me\n";
$c = "Pop through your bubble vest or double-breasted\n";
```

### Substr()

The `substr()` function is used to retrieve part of a string. It accepts either
two or three arguments. The first argument is the string itself. The second
argument is the character position in the string where you want to start your
substring. The optional third argument is the number of chars you want to grab
after the start of the substring. If the third arg is omitted substr() will
grab to the end of the string.
 
```
print $a; 
print substr($a, 0, 13);    # With a duffel full
print "\n";
print substr($a, 14, 18);   # full of troubles,
print "\n";
print substr($a, 32);       # trunk rattle in the Mazda
```

You can also use the substr() function with a negative index start point to
grab from the end of the line. For example,

```
# Negative index
print substr($a, -6);        # Mazda
```

### Split()

The `split()` function allows you to take one string and spit it into many
according to a regex delimiter. We haven't gone over regex yet so for now we'll
just be using a space as the delimiter.

```
print $b; 
@b = split(/ /, $b);    # Array with containing words of $b string.
print "@b[2..4]\n";     # Range of words in now @b array.
print "@b[5..9]";       # Range of words in now @b array.
```

### Join()

The last string function to touch on is join(). Join() takes an array and
re-stringifies it according to two supplied parameters. The first argument is
the string or character that should connect the items of the array when strung
back together. Typically this will be a space for words in a sentence but it
can be any string. 

```
print $c; 
print join(' ', @c);
print join('-', @c);
print join(' blah ', @c[0..2]);
print "\n";
```

## Loops

Perl, like any modern programming language, has loops. 

### For Loops

One of the most useful loops in perl is the for loop. A for loop iterates over
an array of data runs the same code over and over again until its reached the
end of the list.

`Examples/forloops.pl`

```
#!/usr/bin/env perl
for $i (1, 2, 3, 4, 5){
	print "$i\n";
}
```

The above code prints the numbers 1 through 5 on separate lines.

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

`Examples/while_and_until_loops.pl`

```
#!/usr/bin/env perl

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

## File Input / Output

### Reading from Files

The `open()` function is the tool used in perl to directly interact with the
computer's file system. Open() can be used to read from files and to write to
files. We'll cover writing to files in a bit. Open() takes two arguments, the
filehandle you want to use and the second it the name of the file.

We'll be using a sample logfile.

`Examples/log.txt`

```
Cool Program Log File
01/14/22 04:23:25 - Checking program coolness... 
01/14/22 04:23:27 - Cool program verfied!
01/14/22 04:23:28 - Calculating program dopeness...
01/14/22 04:23:30 - Certified dope software!
01/14/22 04:23:31 - Validating legitness...
01/14/22 04:23:32 - Super legit, best software!
```

`Examples/filehandles.pl`

```
#!/usr/bin/env perl

open (LOGFILE, "log.txt");
```

In perl a filehandle is a construct used to manipulate a file. It can be
different things depending on the way its called. For example, if called as a
scalar the LOGFILE filehandle will become a string containing the first line of
log.txt. Whereas, if called as an iterable the LOGFILE filehandle will come to
represent an array with the individual lines of the file being the elements of
the array. Filehandles in perl are always referenced between `<>` characters

```
$title = <LOGFILE>;

$i=0;

for $line (<LOGFILE>) {
    @logfile[$i] = $line;
    $i++;
}

print "Log Title:\n$title";

print "Log Contents:\n";
print @logfile;

close LOGFILE;
```

After we're done using a filehandle, its good practice to close it. We do so
using the `close` statement.

### Writing to File

We can also use `open()` to write to files. Just like in the shell, there are
two write modes, overwrite and append, represented by the `>` and `>>`
characters respectivly.

`Examples/filewrite.pl`

```
#!/usr/bin/env perl

$a = "Rhymes is chosen like the weapons of war\n";

open (FILE1, ">file1.txt") or die "No";
open (FILE2, ">>file2.txt") or die "No";

print FILE1 "$a";

print FILE2 "$a";

close FILE1;
close FILE2;                          
```

The two files produced by the above script will be identical the first time the
program is ran. However, if run multiple times you'll see the $a string is
appended to the end of file2.txt whereas with file1.txt its overwritten every
time.

* Quick cleanup: `rm file*txt`

## Functions & Subs

User defined functions in perl are created using the `sub` keyword. They work
similar to the way functions work in many other languages. They can accept
arguments and return values.

`Examples/functions_aka_subs.pl`

```
#!/usr/bin/env perl

sub square {
	@ops = @_;
	return $ops[0] * $ops[0];
}

for $i (1..10) {
	print "$i squared is: ", &square($i), "\n";
}
```

You might notice the `&` character before the sub's invocation. That's a legacy
perl thing. If you see it anywhere that's what it means.









