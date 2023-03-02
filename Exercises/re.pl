#!/usr/bin/env perl
require Devel::REPL;
my $repl = Devel::REPL->new;
$repl->load_plugin($_) for qw(History LexEnv);
$repl->run
