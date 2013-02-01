#!/usr/bin/env perl

use strict;
use warnings; no warnings 'once';

use Test::More tests => 7;

use lib grep { -d } qw(../lib ./lib ./t/lib);
use Hash::MostUtils qw(leach hashmap n_each n_map);
use Test::Easy qw(deep_ok);

{
  my @list = (1..10);
  my @got;
  while (my ($k, $v) = leach @list) {
    push @got, [$k, $v];
  }
  deep_ok( \@got, [hashmap { [$a, $b] } @list], 'list-each works for arrays' );
}

# You can't say:
#    my ($first, $second) = leach 'a'..'f';
# But don't worry, you also can't say:
#    my @one_to_ten = splice 'b'..'f', 0, 0, 'a';
{
  local $. = 0; # the following splice() causes a bogus uninitialized-$. warning
  my $splice_error = do { local $@; eval { () = splice 2..10, 0, 0, 10 }; $@ };
  my $leach_error  = do { local $@; eval { () = leach 1..2 }; $@ };
  like( $splice_error, qr/ARRAY ref/, 'got some error about array references to splice' );
  like( $leach_error, qr/ARRAY ref/, 'got some error about array references to leach' );
}

{
  my @list = (1..9);
  my @got = ();
  while (my ($k, $v1, $v2) = n_each 3, @list) {
    push @got, [$k, $v1, $v2];
  }
  deep_ok( \@got, [n_map 3, sub { [$::a, $::b, $::c] }, @list], 'n_each works' );
}

{
  my @list = (1..10);
  my @got = ();
  while (my ($k, $v) = leach @list) {
    @list = () if $k == 1;
    push @got, [$k, $v];
  }
  deep_ok( \@got, [[1, 2]], 'mutating @list updated $leach object' );
  deep_ok( \@list, [], 'we set @list to ()' );
}

# Aaron Cohen (morninded) pointed out that the implementation of n_each would allow
# this to work. Here's a test to lock it down against refactorings.
{
  my @list = (
    a => 1..1,
    b => 1..2,
    c => 1..3,
    d => 1..4,
    e => 1..5,
    f => 1..6,
    g => 1..7,
  );

  my %hash;
  my $n = 2;
  while (my ($k, @v) = n_each $n++, @list) {
    $hash{$k} = \@v;
  }

  deep_ok( \%hash, +{
    a => [1..1],
    b => [1..2],
    c => [1..3],
    d => [1..4],
    e => [1..5],
    f => [1..6],
    g => [1..7],
  }, 'we can triangle-slice our list' );
}
