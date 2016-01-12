use v5.18;
package Img::Segmenting {
    use Moo::Role;
    use Imager::Color;

    sub bbox_containing_connected_pixels_from {
        my ($img, %args) = @_;
        my ($x,$y) = @args{"x", "y"};

        my $box = { top => $y, bottom => $y, left => $x, right => $x };
        my $anchor_pixel = $img->getpixel(x=>$x, y=>$y);

        my @stack = ([$x,$y]);
        my $scanned = $box->{scanned} = {};
        while (@stack) {
            my $p = shift @stack;
            my ($x,$y) = @$p;
            next if $scanned->{$x}{$y};
            my $px = $img->getpixel(x => $x, y => $y);
            $scanned->{$x}{$y} = 1;
            if ( $px && ($px->rgba)[0] != 255 ) {
                $box->{top}    = $y if $box->{top}    > $y;
                $box->{bottom} = $y if $box->{bottom} < $y;
                $box->{left}   = $x if $box->{left}   > $x;
                $box->{right}  = $x if $box->{right}  < $x;

                push(@stack, [$x+1, $y])   unless $scanned->{$x+1}{$y};
                push(@stack, [$x-1, $y])   unless $scanned->{$x-1}{$y};
                push(@stack, [$x, $y+1])   unless $scanned->{$x}{$y+1};
                push(@stack, [$x, $y-1])   unless $scanned->{$x}{$y-1};
                push(@stack, [$x+1, $y+1]) unless $scanned->{$x+1}{$y+1};
                push(@stack, [$x+1, $y-1]) unless $scanned->{$x+1}{$y-1};
                push(@stack, [$x-1, $y+1]) unless $scanned->{$x-1}{$y+1};
                push(@stack, [$x-1, $y-1]) unless $scanned->{$x-1}{$y-1};
            }
        }

        return $box;
    }
};

1;
