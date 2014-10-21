package WWW::Mixi::Scraper::Plugin::RecentEcho;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;
use URI;

validator { ( page => 'is_number' ) };

sub scrape {
    my ( $self, $html ) = @_;

    my $scraper = scraper {
        process 'div.archiveList>table>tr', 'recents[]' => scraper {
            process '//td[@class="comment"]//div[1]', id      => 'HTML';
            process '//td[@class="comment"]//div[2]', time    => 'HTML';
            process '//td[@class="comment"]//div[3]', name    => 'HTML';
            process '//td[@class="comment"]//div[4]', comment => 'HTML';
            process '//td[@class="thumb"]//img',      icon    => '@src';
            process
                '//td[@class="comment"]//a[starts-with(@href, "list_echo.pl")]',
                reply_name => [ 'HTML', sub { (/&#62;&#62;(.+)/)[0] } ];
            process
                '//td[@class="comment"]//a[starts-with(@href, "list_echo.pl")]',
                reply_id =>
                [ '@href', sub { (/list_echo.pl\?id=(\d+)\&/)[0] } ];

        };
        result 'recents';
    };

    my $stash = $self->post_process( $scraper->scrape( \$html ) );

    foreach my $echo ( @{ $stash } ) {
        $echo->{reply_id}   ||= '';
        $echo->{reply_name} ||= '';
        $echo->{link}
            = URI->new(
            "http://mixi.jp/view_echo.pl?id=@{[$echo->{id}]}&post_time=@{[$echo->{time}]}"
            );
    }
    return $stash;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::RecentEcho

=head1 DESCRIPTION

This would be equivalent to WWW::Mixi->parse_recent_echo().
(though the latter is not implemented yet as of writing this)

=head1 METHOD

=head2 scrape

returns an array reference of

  {
    link       => 'http://mixi.jp/view_echo.pl?id=xxxx&post_time=xxxx',
    id         => 'xxxx',
    time       => 'yyyymmddhhmmss',
    name       => 'username',
    comment    => 'comment',
    icon       => 'icon',
    reply_name => 'username',
    reply_id   => 'xxxx',
  }

reply_name and reply_id may be blank.

=head1 AUTHOR

Kazuhiro Osawa

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Kazuhiro Osawa.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
