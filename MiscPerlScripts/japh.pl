#!/usr/bin/env perl
# John's first japh!
use MIME::Base64;use Compress::Zlib;$s='blue23';$p='japh';@k=split '',crypt($p,
$s);%h=('1'=>'CEgt','Y'=>'CNk=','0'=>'UUjM','Q'=>'Ti0C','w'=>'SEzO','l'=>'Ki0u'
,'2'=>'SC1S','3'=>'yy/J','U'=>undef,'7'=>undef,'x'=>'ylHw','N'=>'AG8p','b'=>'eJ
zz');$japh;foreach (@k){next unless $h{$_};$japh.=$h{$_};};print uncompress(
decode_base64($japh))."\n";
