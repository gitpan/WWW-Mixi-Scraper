package WWW::Mixi::Scraper::Plugin::ListDiary;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;

validator {qw(
  id     is_number
  page   is_number
  year   is_number
  month  is_number
)};

sub scrape {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{diaries} = scraper {
    process 'td[nowrap]',
      time => 'TEXT';
    process 'td[bgcolor="#FFF4E0"]>a',
      link   => '@href',
      subject => 'TEXT';
    process 'td[bgcolor="#FFFFFF"]>table[cellpadding="3"]>tr>td[class="h120"]',
      description => 'TEXT';
    result qw( time link subject description );
  };

  $scraper{list} = scraper {
    process 'table[width="525"]>tr',
      'diaries[]' => $scraper{diaries};
    result qw( diaries );
  };

  my $stash = $self->post_process($scraper{list}->scrape(\$html));

  my $tmp;
  my @diaries;
  foreach my $item ( @{ $stash } ) {
    if ( $item->{time} ) {  # meta
      $tmp = {
        time    => $item->{time},
        link    => $item->{link},
        subject => $item->{subject},
      };
    }
    elsif ( $item->{description} ) {
      $tmp->{description} = $item->{description};
      push @diaries, $tmp;
    }
  }

  return \@diaries;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ListDiary

=head1 DESCRIPTION

This is almost equivalent to WWW::Mixi->parse_list_diary().

=head1 METHOD

=head2 scrape

returns an array reference of

  {
    subject => 'title of the diary',
    link    => 'http://mixi.jp/view_diary.pl?id=xxxx&owner_id=xxxx',
    description => 'extract of the diary',
    time    => 'mm-dd hh:mm',
  }

Number of comments and image-related info are not available right now.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
