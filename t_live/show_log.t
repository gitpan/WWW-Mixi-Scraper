use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('show_log.pl');
my $dateformat = date_format('%Y-%m-%d %H:%M');

run_tests('show_log') or ok 'ignored';

sub test {
  foreach my $item ( $mixi->show_log->parse(@_) ) {
    ok $item->{time};
    my $dt = $dateformat->parse_datetime( $item->{time} );
    ok defined $dt;
    ok $item->{name};
    ok $item->{link};
    ok ref $item->{link} && $item->{link}->isa('URI');
  }
}