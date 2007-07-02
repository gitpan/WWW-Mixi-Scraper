use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;
use Encode;

my $mixi = login_to('show_calendar.pl');
my $dateformat = date_format('%Y-%m-%d');

run_tests('show_calendar') or ok 'ignored';

sub test {
  my $calendar = $mixi->show_calendar->parse(@_);

require Data::Dump;
  foreach my $item ( @{ $calendar } ) {
    ok $item->{subject};
    ok $item->{link}, Data::Dump::dump($item);
    ok ref $item->{link} && $item->{link}->isa('URI');
    ok $item->{name};
    ok $item->{time};
    my $dt = $dateformat->parse_datetime( $item->{time} );
    ok defined $dt;
    ok $item->{icon};
    ok ref $item->{icon} && $item->{icon}->isa('URI');
  }
}
