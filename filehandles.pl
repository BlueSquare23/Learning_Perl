#!/usr/bin/env perl

open (LOGFILE, "log.txt");

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
