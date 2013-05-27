# vim:ts=4:sw=4:expandtab
# © 2010-2012 Michael Stapelberg (see also: LICENSE)
package RaumZeitChef 1.7;
use v5.14;
use utf8;

# These modules are in core:
use Sys::Syslog;
# All these modules are not in core:
use AnyEvent;
use Method::Signatures::Simple;

use Moose;

has server => (is => 'ro', default => 'irc.hackint.net');
has port => (is => 'ro', default => 6667);
has nick => (is => 'ro', default => 'RaumZeitChef');
has channel => (is => 'ro', default => '#raumzeitlabor');

has cv => (is => 'rw', default => sub { AE::cv });

my @plugins = qw/IRC HTTPD MPD Ping Erinner/;
with(__PACKAGE__ . "::$_") for @plugins;

sub run {
    my ($class) = @_;
    my $self = $class->new();
    my $nick = $self->nick;
    my $server = $self->server;

    openlog('ircbot-chef', 'pid', 'daemon');
    syslog('info', 'Starting up');

    while (1) {
        syslog('info', "Connecting to $server as $nick...");

        $self->irc->connect($self->server, $self->port, { nick => $self->nick, user => 'RaumZeitChef' });
        $self->cv->recv;

        $self->cv(AE::cv);

        # Wait 5 seconds before reconnecting, else we might get banned
        syslog('info', 'Connection lost.');
        sleep 5;
    }
}

1;

__END__


=head1 NAME

RaumZeitMPD - RaumZeitMPD IRC bot

=head1 DESCRIPTION

This module is an IRC bot (nickname RaumZeitMPD) which displays the currently
playing song (querying the MPD) upon !stream and enables a light upon !ping.

=head1 VERSION

Version 1.6

=head1 AUTHOR

Michael Stapelberg, C<< <michael at stapelberg.de> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2012 Michael Stapelberg.

This program is free software; you can redistribute it and/or modify it
under the terms of the BSD license.

=cut
