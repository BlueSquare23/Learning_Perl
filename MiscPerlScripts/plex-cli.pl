#!/usr/bin/env perl
# A simple command line interface for manipulating a plex server via the API.
# Written By, John. R., Aug. 2022

=head1 NAME

plex-cli.pl - Command Line Interface for manipulating the Plex API

=head1 SYNOPSIS

        plex-cli.pl [options]

    Options:

  --help                Prints this help menu

  --refresh=<id|all>    Refreshes library with ID key

  --list-libraries      List libraries & their ID keys

  --list-playing        List currently running video streams


=head1 DESCRIPTION

This script is a simple command line interface for manipulating your plex media
server via the plex XML API.

The Plex API is hosted on your plex server can be access via the following URL.

   http://YOUR_PLEX_IP:32400 (or locally via http://localhost:32400)

=cut

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use XML::LibXML;
use HTTP::Tiny;

my $HELP;
my $REFRESH;
my $LIST_LIBRARIES;
my $LIST_PLAYING;

GetOptions(
	"help",             \$HELP,
	"refresh=s",     => \$REFRESH,
	"list-libraries" => \$LIST_LIBRARIES,
	"list-playing"   => \$LIST_PLAYING
) or pod2usage(1);

pod2usage(1) if $HELP;

my $API_ENDPOINT = "http://localhost:32400";
my $PLEX_TOKEN   = "YOUR_PLEX_TOKEN";

sub get_library_id_hashmap {
	my $url = $API_ENDPOINT . "/library/sections?X-Plex-Token=" . $PLEX_TOKEN;

	# Load the XML from the content.
	my $dom = XML::LibXML->load_xml(
		location => $url
	);

	my %library_id_hash;

	foreach my $video_stream ($dom->findnodes('/MediaContainer/Directory')){
		my $title = $video_stream->findvalue('./@title');
		my $key   = $video_stream->findvalue('./@key');
		
		$library_id_hash{$key} = $title;
	}

	return %library_id_hash
}

if ($LIST_LIBRARIES){
	print "\n\tLibraries & ID Keys\n\n";

	my %library_id_hash = &get_library_id_hashmap;

	while (my ($key, $value) = each %library_id_hash){
		print "  Library: $value\n";
		print "  ID Key:  $key\n";
		print "\n";
	}
} elsif ($LIST_PLAYING){
	my $url = $API_ENDPOINT . "/status/sessions?X-Plex-Token=" . $PLEX_TOKEN;

	# Load the XML from the content.
	my $dom = XML::LibXML->load_xml(
		location => $url
	);

	my $nodes = $dom->findnodes('/MediaContainer/@size');

	if ($nodes eq "0"){
		print "\n\tNo one streaming currently.\n\n";
		exit
	}
	
	print "\n\tUser(s) Watching\n\n";

	foreach my $video_stream ($dom->findnodes('/MediaContainer/Video')){
		my $username = $video_stream->findvalue('./User/@title');
		my $title    = $video_stream->findvalue('./@grandparentTitle');
		my $season   = $video_stream->findvalue('./@parentTitle');
		my $episode  = $video_stream->findvalue('./@index');
		if (! $title){
			$title   = $video_stream->findvalue('./@title');
		}

		my $directors = join ', ', map {
			$_->to_literal();
		} $video_stream->findnodes('./Director/@tag');
		my $writers = join ', ', map {
			$_->to_literal();
		} $video_stream->findnodes('./Writer/@tag');
		my $producers = join ', ', map {
			$_->to_literal();
		} $video_stream->findnodes('./Producer/@tag');

		my $summary  = $video_stream->findvalue('./@summary');
		my @summary  = split(/ /, $summary);
		if (@summary){
			my @short_summary = @summary[0..14];
			push(@short_summary, "\b...");
			$summary = join(" ", @short_summary);
		}
		
		# Ternary ops ftw.
		print $username  ? "  User:        $username\n"  : "";
		print $title     ? "  Title:       $title\n"     : "";
		print $season    ? "  Season:      $season\n"    : "";
		print $episode   ? "  Episode:     $episode\n"   : "";
		print $directors ? "  Director(s): $directors\n" : "";
		print $writers   ? "  Writer(s):   $writers\n"   : "";
		print $producers ? "  Producer(s): $producers\n" : "";
		print $summary   ? "  Summary:     $summary\n"   : "";
		print "\n";
	}
} elsif ($REFRESH){
	my %library_id_hash = &get_library_id_hashmap;
	my $Client = HTTP::Tiny->new();

	if ($REFRESH eq "all"){
	
		while (my ($key, $value) = each %library_id_hash){
			print "Refreshing $value...\n";
			my $url = $API_ENDPOINT . "/library/sections/$key/refresh?force=1&X-Plex-Token=" . $PLEX_TOKEN;
			my $response = $Client->get($url);
			my $status_code = $response->{status};
			print "$value Refresh Responded: $status_code\n";
			sleep 1;
		}
		exit;
	} 

	# If $REFRESH isn't int, print usage.
	pod2usage(1) if ($REFRESH !~ /^(\-|\+)?\d+?$/);

	my $library = $library_id_hash{int($REFRESH)};

	print "Refreshing $library...\n";
	my $url = $API_ENDPOINT . "/library/sections/$REFRESH/refresh?force=1&X-Plex-Token=" . $PLEX_TOKEN;
	my $response = $Client->get($url);
	my $status_code = $response->{status};
	print "$library Refresh Responded: $status_code\n";
} else {
	pod2usage(-verbose => 2, -noperldoc => 1);
}

