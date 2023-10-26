#!/usr/bin/env perl
# John's Awesome Perl Quine!

my $source_str = <<'EOF';
#!/usr/bin/env perl
# John's Awesome Perl Quine!

my $source_str = <<'EOF';
xEOF

my @source = split("\n", $source_str);

for my $line ( @source ) {
    if ( $line =~ /xEOF/ and $line !~ /\/xEOF\// ) {
        print $source_str;
        print "EOF\n";
        next;
    }

    print "$line\n";
}
EOF

my @source = split("\n", $source_str);

for my $line ( @source ) {
    if ( $line =~ /xEOF/ and $line !~ /\/xEOF\// ) {
        print $source_str;
        print "EOF\n";
        next;
    }

    print "$line\n";
}
