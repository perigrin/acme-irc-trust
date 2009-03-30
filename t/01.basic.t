#!/usr/bin/env perl 
use strict;
use Test::More qw(no_plan);

use Acme::IRC::Trust;
my $matrix = {
    perigrin     => 'everywhere',
    stevan       => ['#moose'],
    'mekano-pip' => { '#moose' => 0.25 }
};

ok( my $t = Acme::IRC::Trust->new( trust => $matrix ), 'new trust' );
ok(
    my $trust = $t->check(
        '#moose', 'perigrin!~perigrin@127.0.0.1',
        'stevan!~stevan@127.0.0.1',
    ),
    'we trust perigrin & stevan in #moose'
);

is( $trust->{perigrin}, 'o', 'perigrin has ops' );
is( $trust->{stevan},   'o', 'stevan has ops' );

ok( $trust = $t->check( '#axkit', 'perigrin!~perigrin@127.0.0.1', ),
    'we trust perigrin #axkit' );
is( $trust->{perigrin}, 'o', 'perigrin has ops there too');

ok( !$t->check( '#axkit', 'stevan!~stevan@127.0.0.1', ),
    "we don't stevan in #axkit" );

ok(
    $trust = $t->check( '#moose', 'mekano-pip!pip@127.0.0.1' ),
    'pip has some kind of trust in #moose'
);
is($trust->{'mekano-pip'}, 'v', 'pip has voice');