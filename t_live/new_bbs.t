use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('new_bbs.pl');
my $dateformat = date_format('%Y-%m-%d %H:%M');

run_tests('new_bbs') or ok 'ignored';

sub test {
  foreach my $item ( $mixi->new_bbs->parse(@_) ) {
    ok $item->{subject};
    ok $item->{name};
    ok $item->{time};
    my $dt = $dateformat->parse_datetime( $item->{time} );
    ok defined $dt;
    ok $item->{link};
    ok ref $item->{link} && $item->{link}->isa('URI');
  }
}
