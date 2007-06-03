package WWW::Mixi::Scraper::Plugin::NewBBS;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;

validator {qw( page is_number )};

sub scrape {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{entries} = scraper {
    process 'td[width="180"]',
      time => 'TEXT';
    process 'td[width="450"]>a',
      subject => 'TEXT',
      link    => '@href';
    process 'td[width="450"]',
      string => 'TEXT';
    result qw( string subject link time );
  };

  $scraper{list} = scraper {
    process 'tr[bgcolor="#FFFFFF"]',
      'entries[]' => $scraper{entries};
    result qw( entries );
  };

  return $self->post_process(
    $scraper{list}->scrape(\$html) => \&_extract_name
  );
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::NewBBS

=head1 DESCRIPTION

This is equivalent to WWW::Mixi->parse_new_bbs().

=head1 METHOD

=head2 scrape

returns an array reference of

  {
    subject => 'bbs entry extract',
    name    => 'bbs name',
    link    => 'http://mixi.jp/view_bbs.pl?id=xxxx',
    time    => 'yyyy-mm-dd hh:mm'
  }

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut