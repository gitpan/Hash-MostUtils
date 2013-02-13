#!/usr/bin/env perl

use strict;
use warnings;

use Test::More; END { done_testing() }

use lib grep { -d } qw(../lib ./lib ./t/lib);
use Hash::MostUtils qw(reindex);

use Test::Easy qw(deep_ok);

subtest reindex => sub {
  plan tests => 1;

  my @start = (1..5);
  my @reindex = reindex { map { $_ => $_ + 1 } 0..$#start } @start;
  deep_ok( \@reindex, [undef, 1..5] );
};
