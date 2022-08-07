#!/usr/bin/env perl
# This script is used to easily Email error messages / bug reports.
# Requires a working `sendmail` compatible SMTP agent and `sudo`.
# Written by John R., Aug. 2022

=head1 NAME

bug-track.pl - An Email Wrapper for Submitting Error Messages / Bug Reports

=head1 SYNOPSIS

        bug-track.pl [options]

    Options:

  --help                Prints this help menu

  --error-file=<file>   Submit error via a file

  --error-cmd=<"cmd">   Submit error via broken cmd

  --user=<username>     User context for above broken cmd

  --no-preview          Omits the message preview and just sends

=head1 DESCRIPTION

This script is meant to be used to easily Email error messages to a hardcoded
address for bug tracking purposes. 

Your can either submit errors via a file or by entering the bad command and
having the script run it (within a particular users context).

=head1 EXAMPLES

* Submitting a bug report via the `--error-cmd` flag: 

Note: Make sure to put quotes around multi-word commands.

    bug-track.pl --user johnny --error-cmd "./misc-script --flag arg"

* Submitting a bug report using the `--error-file` switch:

    bug-track.pl --error-file /path/to/error_file.txt

Note: When `--error-file` is supplied error text is read from the file and
error cmd is NOT executed.

    bug-track.pl --error-file error_file.txt --error-cmd "./broken-script --args"

=head1 CREDITS

  Author : John R.
  Written: August 2022

=cut

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

# Root EUID Check.
if ($<){
	print "This script must be run as root!\n";
	exit;
}

my $HELP;
my $ERROR_FILE;
my $ERROR_CMD;
my $USER_CONTEXT;
my $NO_PREVIEW;
my $TO_ADDR = "";
my $FROM_ADDR = "";

GetOptions(
	"help",             \$HELP,
	"error-file=s",  => \$ERROR_FILE,
	"error-cmd=s"    => \$ERROR_CMD,
	"user=s"         => \$USER_CONTEXT,
    "no-preview"     => \$NO_PREVIEW
) or pod2usage(1);

pod2usage(1) if $HELP;

sub sendBugReport {
	my @ops = @_;
	my $subject = $ops[0];
	my $body    = $ops[1];
	my $date    = localtime();

	open(MAIL, "|/usr/sbin/sendmail -t");
	
	# Email Header
	print MAIL "To: $TO_ADDR\n";
	print MAIL "From: $FROM_ADDR\n";
	print MAIL "Subject: $subject\n\n";
	print MAIL "Date: $date\n\n";
	# Email Body
	print MAIL $body;
	
	close(MAIL);
	print "Email Sent Successfully\n";
}

sub formatAndSend {
	my @ops = @_;
	my $subject     = $ops[0];
	my $script_name = $ops[1];
	my $error_text  = $ops[2];

	my $body = <<~"EOF";
	Dear Devs,

	The script "$script_name" is erroring.
	
	Script Output
	---------------------------------------------
	$error_text
	---------------------------------------------

	Please resolve at your earliest convience.

	Sincerely, 
	MGMT

	EOF

	if ($NO_PREVIEW){
		&sendBugReport($subject, $body);
		exit;
	}

	print <<~"EOF";

	    Preview of Message
	    ------------------

	$subject

	$body
	EOF

	print "Do you want to send this message? (y/n): ";
	my $answer = <STDIN>;
	chomp $answer;

	if ($answer ne "y"){
		print "Aborting, message NOT sent!\n";
		exit;
	}

	&sendBugReport($subject, $body);
}

if ($ERROR_FILE){
	open(ERROR_FILE, $ERROR_FILE) 
		or die "Could not open file '$ERROR_FILE' $!";

	my $i=0;
	my @error_file_contents;

	for my $line (<ERROR_FILE>){
		@error_file_contents[$i] = $line;
		$i++;
	}
	close ERROR_FILE;

	# If called with both `--error-file` and `--error-cmd`, presume output of
	# error file came from error cmd and just send notice. Under this case,
	# error cmd is not run.
	if (! $ERROR_CMD){
		print "\t\\/  Please enter the exact erroring command  \\/\n> ";
		$ERROR_CMD = <STDIN>;
		chomp $ERROR_CMD;
	}

	my @error_cmd = split(/ /, $ERROR_CMD);
	my $script_name = $error_cmd[0];

	my $subject = "Script Problem: $script_name";
	my $error_text = join(' ', @error_file_contents);

	&formatAndSend($subject, $script_name, $error_text);

} elsif ($ERROR_CMD){
	my @error_cmd = split(/ /, $ERROR_CMD);
	my $script_name = $error_cmd[0];

	sub getErrorOutput {
		my $username = $_[0];
		print "Running '$ERROR_CMD' as $username...\n";
		my $script_output = `sudo -u $username "$ERROR_CMD" 2>&1`;
		my $error_text = $ERROR_CMD . "\n" . $script_output;
		return $error_text;
	}

	sub checkUserContext {
		my $username = $_[0];
		my $valid_user = `grep -qw $username /etc/passwd && echo 0 || echo 1`;
		chomp $valid_user;

		if ($valid_user eq 1){
			print "Invalid username!\n";
			exit 7;
		}
		my $subject = "Script Problem: $script_name";
		my $error_text = &getErrorOutput($username);
		&formatAndSend($subject, $script_name, $error_text);
	}

	if (! $USER_CONTEXT){
		print "What user should the script be run as? : ";
		my $username = <STDIN>;
		chomp $username;
		$USER_CONTEXT = $username;
	}

	&checkUserContext($USER_CONTEXT);
	
} else {
	pod2usage(-verbose => 2, -noperldoc => 1);
}

