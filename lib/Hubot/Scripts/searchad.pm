package Hubot::Scripts::searchad;

# ABSTRACT: Hubot::Scripts::searchad
use strict;
use warnings;

use WWW::Naver::SearchAd;

sub load {
    my ( $class, $robot ) = @_;

    my $ad = WWW::Naver::SearchAd->new;

    $robot->respond(
        qr/searchad (.*)?$/i,
        sub {
            my $msg  = shift;
            my @items = item_filter(split / /, $msg->match->[0]);

            return $msg->send('no items for bidding') unless @items;

            my $autheticated = $ad->signin(
                $ENV{HUBOT_SEARCHAD_NAVER_USERNAME},
                $ENV{HUBOT_SEARCHAD_NAVER_PASSWORD}
            );

            return $msg->send($ad->{error}) unless $autheticated;

            for my $item (@items) {
                my ($bundle_id, $rank) = split /:/, $item;
                if ($ad->refresh($bundle_id, $rank)) {
                    $msg->send("[$bundle_id] ranked to [$rank] successfully");
                } else {
                    $msg->send($ad->{error});
                }
            }
        }
    );
}

sub item_filter {
    my @items = @_;

    my @validated_items;
    for my $item (@items) {
        my ($bundle_id, $rank) = split /:/, $item;
        next if (!$bundle_id || !$rank);
        push @validated_items, $item;
    }

    return @validated_items;
}

1;


=pod

=head1 NAME

Hubot::Scripts::searchad

=head1 SYNOPSIS

    hubot searchad <bundleid>:<rank> ... - start to bidding for each <bundleid> to <rank>

=head1 DESCRIPTION

need more description?

=head1 CONFIGURATION

=over

=item HUBOT_SEARCHAD_NAVER_USERNAME

=item HUBOT_SEARCHAD_NAVER_PASSWORD

=back

=head1 AUTHOR

Hyungsuk Hong <aanoaa@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Hyungsuk Hong.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
