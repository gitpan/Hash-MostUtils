#!/usr/bin/env perl

use strict;
use warnings; no warnings 'once';

use Test::More; END { done_testing }

use lib grep { -d } qw(../lib ./lib ./t/lib);
use Hash::MostUtils qw(n_map n_grep n_apply hashmap hash_slice_of hashgrep hashapply rekey revalue);

use Test::Easy qw(deep_ok);

# sample code from the pod
subtest from_pod => sub {
  plan tests => 2;

  my @sets =
    n_map   6, sub { [$::a, $::b, $::c, $::d, $::e, $::f] },
    n_apply 3, sub { $_ *= 3 for $::a, $::b, $::c },
    n_grep  3, sub { $::c > 4 },
    (1..9);                # @sets = ([12, 15, 18, 21, 24, 27]);

  deep_ok( \@sets, [[12, 15, 18, 21, 24, 27]], 'pieces of eight, sets of three, awk!' );

  # now with some gloss and polish
  sub hex_map (&@)   { unshift @_, 6; goto &n_map }
  sub tri_grep (&@)  { unshift @_, 3; goto &n_grep }
  sub tri_apply (&@) { unshift @_, 3; goto &n_apply }

  @sets =
    hex_map { [$::a, $::b, $::c, $::d, $::e, $::f] }
    tri_apply { $_ *= 3 for $::a, $::b, $::c }
    tri_grep { $::c > 4 }
    (1..9);                # @sets = ([12, 15, 18, 21, 24, 27]);

  deep_ok( \@sets, [[12, 15, 18, 21, 24, 27]], 'pieces of eight, sets of three, round two: fight!' );
};

# hash_slice_of
subtest foo => sub {
  plan tests => 2;

  my %hash = (1..10);
  my %slice =
    hash_slice_of \%hash, qw(5 7 9 11);
  deep_ok( \%slice, {5 => 6, 7 => 8, 9 => 10, 11 => undef}, 'non-existing keys have an undef value' );

  %slice =
    hashgrep { exists $hash{$a} }
    hash_slice_of \%hash, qw(5 7 9 11);
  deep_ok( \%slice, {5 => 6, 7 => 8, 9 => 10}, 'only existing keys are in %slice now' );
};

# rekey and revalue
subtest rekey => sub {
  plan tests => 3;

  my %start = (1..10, apple => 'red', bear => 'brown');
  my %rekey = rekey { (apple => 'manzana', bear => 'oso', 7 => 700) } %start;
  deep_ok( \%rekey, {
    (hash_slice_of(\%start, qw(1 3 5 9))),
    700 => 8,
    manzana => $start{apple},
    oso => $start{bear},
  }, 'rekey works' );

  my @start = (1..10, apple => 'red', bear => 'brown');
  my @rekey = rekey { (apple => 'manzana', bear => 'oso', 7 => 700) } @start;
  deep_ok( \@rekey, [
    (1..6),
    700 => 8,
    (9..10),
    manzana => 'red',
    oso => 'brown',
  ], 'rekey works on hash-like arrays' );

  my @translated =
    rekey { apple => 'manzana' }
    revalue { red => 'rojo', green => 'verde' }
    (apple => 'red', apple => 'green');
  deep_ok( \@translated, [
    manzana => 'rojo',
    manzana => 'verde',
  ], 'rekey + revalue for a hash-like list' );
};
