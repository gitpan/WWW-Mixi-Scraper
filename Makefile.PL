use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME           => 'WWW::Mixi::Scraper',
  AUTHOR         => 'Kenichi Ishigaki <ishigaki@cpan.org>',
  VERSION_FROM   => 'lib/WWW/Mixi/Scraper.pm',
  ABSTRACT_FROM  => 'lib/WWW/Mixi/Scraper.pm',
  PREREQ_PM => {
    'Encode' => 0,
    'Module::Pluggable::Fast' => 0,
    'String::CamelCase' => 0,
    'Test::UseAllModules' => 0,
    'URI' => 0,
    'URI::QueryParam' => 0,
    'Web::Scraper' => 0,
    'WWW::Mechanize' => '1.30',
    'WWW::Mechanize::DecodedContent' => 0,
  },
  ($ExtUtils::MakeMaker::VERSION >= 6.31
    ? (LICENSE => 'perl')
    : ()
  ),
);