#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;

use lib grep { -d } qw(../lib ./lib ./t/lib);
use Hash::MostUtils qw(hashmap);
use Test::Easy qw(deep_ok);

our @warnings;
BEGIN { $SIG{__WARN__} = sub { push @warnings, [@_] } }

{
  () = hashmap { $b => $a } (1..10);
  is( scalar @warnings, 2, 'got 2 warnings' );
  my @unexpected = grep { $_ !~ qr/main::[ab].*used.*once/ } map { @$_ } @warnings;
  is( scalar @unexpected, 0, 'no unexpected warnings' );
}
