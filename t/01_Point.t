#!/usr/bin/env perl

use Test::Most;
use strict;
use warnings;

use_ok('Math::CG::Point');
use_ok('Math::CG::Triangle');

subtest 'BUILD' => sub {
    my $pt2 = Math::CG::Point->new(x => 0, y => 1);
    my $pt3 = Math::CG::Point->new(x => 2, y => 3, z => 0);
    my $pt31 = Math::CG::Point->new([4, 5, 6]);
    is($pt2->dimensions,  2, 'auto set number of dimensions from new() arguments');
    is($pt3->dimensions,  3, 'auto set number of dimensions from new() arguments');
    is($pt31->dimensions, 3, 'auto set number of dimensions from new() arguments');
    is($pt2->x,           0, 'x dimension from new() arguments');
    is($pt3->z,           0, 'z dimension from new() arguments');
    is($pt31->y,          5, 'y dimension from new() arguments');
};

subtest 'override' => sub {
    my $pt0 = Math::CG::Point->new(x => 0, y => 0);
    is($pt0->as_string, $pt0 . '', 'stringification');
    is($pt0->as_string, '[0,0]',   'stringification');

    my $pt1 = Math::CG::Point->new(x => 2, y => 3);
    my $pt2 = Math::CG::Point->new(x => 2, y => 3);
    cmp_ok($pt0, '!=', $pt1, '!=');
    cmp_ok($pt1, '==', $pt2, '==');
};

subtest 'methods' => sub {
    my $pt0 = Math::CG::Point->new(x => 0, y => 0);
    my $p1  = Math::CG::Point->new(x => 1, y => 0);
    my $p2  = Math::CG::Point->new(x => 0, y => -1);
    ok(!$pt0->left_of($p1, $p2), 'left_of()');
    ok($pt0->left_of($p2, $p1), 'left_of()');
};

done_testing;

