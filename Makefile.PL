use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME                => 'Hash::MostUtils',
  AUTHOR              => q{Belden Lyman <belden@cpan.org>},
  VERSION_FROM        => 'lib/Hash/MostUtils.pm',
  ABSTRACT            => 'Pairwise list manipulators',
  LICENSE => 'perl',
  PL_FILES            => {},
  META_MERGE => {
    resources => {
      bugtracker => 'https://github.com/belden/perl-hash-mostutils/issues',
    },
  },
  dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
