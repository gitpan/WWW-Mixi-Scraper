use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;
use Encode;

my $mixi = login_to('show_friend.pl');

run_tests('show_friend') or ok 'ignored';

sub test {
  my $friend = $mixi->show_friend->parse(@_);

  my $profile = $friend->{profile};
  foreach my $key ( keys %{ $profile } ) {
    ok $key;
    ok defined $profile->{$key}; # may be blank but at least should be defined
  }
}
