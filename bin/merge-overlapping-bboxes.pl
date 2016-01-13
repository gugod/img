#!/usr/bin/env perl

use v5.18;
use strict;
use warnings;
use autodie;
use List::Util qw(min max);

sub main {
    my ($input, $output) = @_;
    my @bbox;

    open my $fh_out, ">", $output;
    open my $fh, "<", $input;
    while (<$fh>) {
        chomp;
        my @b = split /,/;
        push @bbox, \@b;
    }
    close($fh);

    find_overlaps_and_merge(
        \@bbox, sub {
            my ($box) = @_;
            my $b = join(",", @$box);
            say $b;
            say $fh_out $b;
        });

    close($fh_out);
}
main(@ARGV);

sub find_overlaps_and_merge {
    my ($bbox, $cb) = @_;

    for my $i (0..@$bbox-2) {
        for my $j ($i+1..@$bbox-1) {
            if (overlaps($bbox->[$i], $bbox->[$j])) {
                $cb->( merge_bbox($bbox->[$i], $bbox->[$j]) );
            }
        }
    }
}

sub point_in_box {
    my ($point, $box) = @_;
    return (
        $box->[0] <= $point->[1] && $point->[1] <= $box->[1] &&
        $box->[2] <= $point->[0] && $point->[0] <= $box->[3]
    )
}

sub overlaps {
    my ($box1, $box2) = @_;
    my @p = (
        [$box2->[2], $box2->[0]],
        [$box2->[2], $box2->[1]],
        [$box2->[3], $box2->[0]],
        [$box2->[3], $box2->[1]],
    );
    for my $p (@p) {
        return 1 if point_in_box($p, $box1);
    }
    return 0;
}

sub merge_bbox {
    my ($box1, $box2) = @_;
    return [
        min($box1->[0], $box2->[0]),
        max($box1->[1], $box2->[1]),
        min($box1->[2], $box2->[2]),
        max($box1->[3], $box2->[3]),
    ]
}
