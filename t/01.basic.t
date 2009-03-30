#!/usr/bin/env perl 
use strict;
use Test::More qw(no_plan);

use Acme::IRC::Trust;
my $matrix = {
    perigrin     => 'everywhere',
    stevan       => ['#moose'],
    'mekano-pip' => { '#moose' => 0.25 }
};

ok(
    my $t = Acme::IRC::Trust->new( trust => $matrix ),
    'new trust'
);
ok(
    $t->check(
        '#moose',
        'perigrin!~perigrin@127.0.0.1',
        'stevan!~stevan@127.0.0.1',
    ),
    'we trust perigrin & stevan in #moose'
);
ok(
    $t->check(
        '#axkit',
        'perigrin!~perigrin@127.0.0.1',
    ),
    'we trust perigrin #axkit'
);

ok(
    !$t->check(
        '#axkit',
        'stevan!~stevan@127.0.0.1',
    ),
    "we don't stevan in #axkit"
);

ok(
    $t->check( '#moose', 'mekano-pip!pip@127.0.0.1' ),
    'pip has voice in #moose'
);
