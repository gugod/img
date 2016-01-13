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

    my %seen;
    find_overlaps_and_merge(
        \@bbox, sub {
            my ($box) = @_;
            my $b = join(",", @$box);
            unless ($seen{$b}++) {
                say $b;
                say $fh_out $b;
            }
        });

    close($fh_out);
}
main(@ARGV);

sub find_overlaps_and_merge {
    my ($bbox, $cb) = @_;

    my @points;
    my %idx_p2b;
    for my $i ( 0 ... @$bbox-1) {
        my $bb = $bbox->[$i];
        my @bb_points = (
            [$bb->[2], $bb->[0], $i],
            [$bb->[2], $bb->[1], $i],
            [$bb->[3], $bb->[0], $i],
            [$bb->[3], $bb->[1], $i],
        );
        push @points, @bb_points;
        $bb->[5] = \@bb_points;
    }

    my @points_i_sorted_by_x = sort { $points[$a][0] <=> $points[$b][0] } (0...@points-1);
    for my $i (0..@$bbox-1) {
        my $bb = $bbox->[$i];
        my @points_inside_bb;
        for my $j (@points_i_sorted_by_x) {
            my $p_x = $points[$j][0];
            my $p_y = $points[$j][1];
            if ( $bb->[2] <= $p_x && $p_x <= $bb->[3] ) {
                if ( $bb->[0] <= $p_y && $p_y <= $bb->[1] ) {
                    push @points_inside_bb, $points[$j];
                }
            }
        }

        my $merged_bb = merge_bboxes($bb, map { $bbox->[$_->[2]] } @points_inside_bb);
        $cb->($merged_bb);
    }
}

sub merge_bboxes {
    my @boxes = @_;
    return [
        min(map { $_->[0] } @boxes),
        max(map { $_->[1] } @boxes),
        min(map { $_->[2] } @boxes),
        max(map { $_->[3] } @boxes),
    ]
}
