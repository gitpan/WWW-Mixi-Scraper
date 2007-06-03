package WWW::Mixi::Scraper::Mech;

use strict;
use warnings;
use Encode;
use WWW::Mechanize;
use WWW::Mechanize::DecodedContent;
use WWW::Mixi::Scraper::Utils qw( _uri );

sub new {
  my ($class, %options) = @_;

  my $email    = delete $options{email};
  my $password = delete $options{password};

  $options{agent} ||= "WWW-Mixi-Scraper/$WWW::Mixi::Scraper::VERSION";
  $options{cookie_jar} ||= {};

  my $mech = WWW::Mechanize->new( %options );
  my $self = bless { mech => $mech }, $class;

  if ( $email && $password ) {
    $self->login( $email, $password );
  }

  $self;
}

sub login {
  my ($self, $email, $password) = @_;

  $self->{mech}->post( 'http://mixi.jp/login.pl' => {
    next_url => '/home.pl',
    email    => $email,
    password => $password,
    sticky   => 'on',
  });

  $self->may_have_errors('Login failed');
}

sub logout {
  my $self = shift;

  $self->get('/logout.pl');

  $self->may_have_errors('Failed to logout');
}

sub may_have_errors {
  my $self = shift;

  $self->{mech}->success or $self->_error(@_);
}

sub _error {
  my ($self, $message) = @_;

  $message ||= 'Mech error';

  die "$message: ".$self->{mech}->res->status_line;
}

sub get {
  my ($self, $uri) = @_;

  $uri = _uri($uri) unless ref $uri eq 'URI';

  $self->{mech}->get($uri);
}

sub content {
  my $self = shift;

  $self->{mech}->decoded_content;
}

sub get_content {
  my ($self, $uri, $encoding) = @_;

  my $content = $self->get($uri) ? $self->content : undef;

  if ( $content && $encoding ) {
    $content = encode( $encoding => $content );
  }
  $content;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Mech

=head1 SYNOPSIS

    use WWW::Mixi::Scraper::Mech;
    my $mech = WWW::Mixi::Scraper::Mech->new;
       $mech->login( 'foo@bar.com' => 'password' );

       $mech->may_have_errors('Cannot login');

    my $html = $mech->get_content('/new_friend_diary.pl');

    $mech->logout;
 
=head1 DESCRIPTION

Mainly used internally.

=head1 METHODS

=head2 new

creates an object. Optional hash is passed to WWW::Mechanize, except for 'email' and 'password', which are used to login.

=head2 get

gets content of the uri.

=head2 content

returns (hopefully) decoded content. See WWW::Mechanize::DecodedContent for decoding policy.

=head2 get_content

As name suggests, this does both 'get' and 'content'. If you pass an additional encoding (which must be Encode-understandable), this returns encoded content.

=head2 login

tries to log in to mixi. As of writing this, password obfuscation and ssl login are not implemented.

=head2 logout

tries to log out from mixi.

=head2 may_have_errors

dies with error message and status code if something is wrong (this may change)

=head1 SEE ALSO

L<WWW::Mechanize>, L<WWW::Mechanize::DecodedContent>

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut