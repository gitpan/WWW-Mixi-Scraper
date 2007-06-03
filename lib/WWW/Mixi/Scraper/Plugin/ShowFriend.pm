package WWW::Mixi::Scraper::Plugin::ShowFriend;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;

validator {qw( id is_number )};

sub scrape {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{items} = scraper {
    process 'td[width="80"]',
      key => 'TEXT';
    process 'td[width!="80"]',
      value => 'TEXT';
    result qw( key value );
  };

  $scraper{profile} = scraper {
    process 'table[width="425"]>tr[bgcolor="#FFFFFF"]',
      'items[]' => $scraper{items};
    result qw( items );
  };

  my $stash = $self->post_process($scraper{profile}->scrape(\$html));

  my $profile = {};
  foreach my $item ( @{ $stash } ) {
    next unless $item->{key};
    $profile->{$item->{key}} = $item->{value};
  }

  return { profile => $profile };
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ShowFriend

=head1 DESCRIPTION

This is almost equivalent to WWW::Mixi->parse_show_friend_profile(), though you need one more step to get the hash reference you want.

=head1 METHOD

=head2 scrape

returns a hash reference of the person's profile.

  {
    profile => { 'profile' => 'hash' },
  }

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
