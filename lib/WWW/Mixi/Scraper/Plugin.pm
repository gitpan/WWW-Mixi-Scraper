package WWW::Mixi::Scraper::Plugin;

use strict;
use warnings;
use Web::Scraper;
use String::CamelCase qw( decamelize );
use WWW::Mixi::Scraper::Utils qw( _force_arrayref _uri _datetime );

sub import {
  my $class = shift;
  my $pkg = caller;

  my @subs = qw(
    new parse
    scraper process process_first result
    get_content post_process
    validator build_uri
    _extract_name
  );

  no strict 'refs';
  foreach my $sub ( @subs ) {
    *{"$pkg\::$sub"} = *{"$class\::$sub"};
  }
}

sub new {
  my ($class, %options) = @_;

  bless \%options, $class;
}

sub parse {
  my $self = shift;

  my $res = $self->scrape($self->get_content(@_));

  return ( wantarray and ref $res eq 'ARRAY' )
    ? @{ $res || [] }
    : $res;
}

sub get_content {
  my ($self, %options) = @_;

  my $content = delete $options{html};

  unless ( $content ) {
    $content = $self->{mech}->get_content($self->build_uri(%options));
  }
  die "no content" unless $content;

  # XXX: preserve some tags like <br>?
  $content =~ s/<br(\s[^>]*)?>/\n/g; # at least preserve as a space
  $content =~ s/&nbsp;/ /g;          # as it'd be converted as '?'

  return $content;
}

sub build_uri {
  my ($self, %query) = @_;

  my ($name) = (ref $self) =~ /::(\w+)$/;
  my $path = sprintf '/%s.pl', decamelize($name);
  my $uri = URI->new($path);

  foreach my $key ( keys %query ) {
    if ( $self->_is_valid( $key, $query{$key} ) ) {
      $uri->query_param( $key => $query{$key} );
    }
  }
  return $uri;
}

sub validator ($) {
  my $hashref = shift;
  my $pkg = caller;

  my %rules;
  foreach my $key ( keys %{ $hashref } ) {
    my $rule = $hashref->{$key};
    if ( $rule eq 'is_number' ) {
      $rules{$key} = sub {
        my $value = shift;
        $value && $value =~ /^\d+$/ ? 1 : 0;
      };
    }
    if ( $rule eq 'is_number_or_all' ) {
      $rules{$key} = sub {
        my $value = shift;
        $value && $value =~ /^(?:\d+|all)$/ ? 1 : 0;
      };
    }
    if ( $rule eq 'is_anything' ) {
      $rules{$key} = sub { 1 };
    }
  }

  no strict 'refs';
  *{"$pkg\::_is_valid"} = sub { return $rules{$_[1]}->($_[2]) };
}

sub post_process {
  my ($self, $data, $callback) = @_;

  my $arrayref = _force_arrayref($data);

  foreach my $item ( @{ $arrayref } ) {
    if ( ref $callback eq 'CODE' ) {
      $callback->($item);
    }
    foreach my $key ( keys %{ $item } ) {
      next unless $item->{$key};
      if ( $key =~ /time$/ ) {
        $item->{$key} = _datetime($item->{$key})
      }
      if ( $key =~ /link$/ ) {
        $item->{$key} = _uri($item->{$key});
      }
    }
  }

  $arrayref = [ grep { !$_->{_delete} } @{ $arrayref } ];

  return $arrayref;
}

sub _extract_name {
  my $item = shift;
  my $name = substr( delete $item->{string}, length $item->{subject} );
     $name =~ s/^\s*\(//;
     $name =~ s/\)\s*$//;
  $item->{name} = $name;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin - base class for plugins

=head1 SYNOPSIS

    package WWW::Mixi::Scraper::Plugin::<SamplePlugin>

    use strict;
    use warnings;
    use WWW::Mixi::Scraper::Plugin;

    validator {qw( id is_number )};

    sub scrape {
      my ($self, $html) = @_;

      my %scraper;
      $scraper{...} = scraper {
        process '...',
          text => 'TEXT';
        result 'text';
      };

      return $self->post_process($scraper{...}->scrape(\$html));

      return $arrayref;
    }

    1;

=head1 DESCRIPTION

This is a base class for WWW::Mixi::Scraper plugins. You don't need to C<use base qw( WWW::Mixi::Scraper::Plugin )>; just C<use> it. This exports Web::Scraper functions and several public and private methods/functions of its own.

=head1 METHODS

=head2 new

creates an object.

=head2 parse

gets content from uri, scrape, and returns an array (or hash reference, etc) of data.

=head2 build_uri

used internally to build uri from query paramters (and optional hash)

=head2 get_content

gets content from the uri specified or from an optional html data.

=head2 post_process

does some common tasks such as to make sure the result be an array reference, remove some temporary data to extract exact information, objectify link data (and maybe datetime data in the future?).

=head2 validator

prepares some simple validator for query parameters, though I'm not sure if this is really useful.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
