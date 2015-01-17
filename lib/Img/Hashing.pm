use v5.18;
package Img::Hashing {
    use Moo::Role;

    sub average_hash {
        my ($img0) = @_;
        my $img = $img0->convert(preset=>"grey");
        if (($img->getwidth != 8) || ($img->getheight != 8)) {
            $img = $img->scale(xpixels => 8, ypixels => 8);
        }

        my $sum = 0;
        my @c;
        for my $y (0..7) {
            for my $x (0..7) {
                my $c = ($img->getpixel(y=>$y,x=>$x)->rgba)[0];
                push @c, $c;
                $sum += $c;
            }
        }

        my $hash = 0;
        my $avg = $sum/64;
        for my $i (0..$#c) {
            my $b = ($c[$i] > $avg) ? 1 : 0;
            $hash |= ($b << $i) if $b;
        }
        return $hash;
    }

    sub difference_hash {
        my ($img0) = @_;
        my $img = $img0->scale(xpixels => 9, ypixels => 8)->convert(preset=>"grey");
        my $hash = 0;
        my $i = 0;
        for my $y (0..7) {
            my @l = $img->getscanline(y=>$y);
            for (1 .. $#l) {
                my ($a) = $l[$_-1]->rgba;
                my ($b) = $l[$_]->rgba;
                my $x = $a < $b ? 1 : 0;
                $hash |= $x << $i if $x;
                $i++;
            }
        }
        return $hash;
    }


    sub _dct_1d {
        my $s = shift;
        my $c = @$s +0;
        my $out = [];

        # u == 0
        my $z = 0;
        $z += $s->[$_] for 0 .. $c-1;
        $z *= 0.70710678118654752440; # 1/sqrt(2)
        $out->[0] = $z/2;

        for my $u (1 .. $c-1) {
            $z = 0;
            for (0 .. $c-1) {
                $z += $s->[$_] * cos( 3.14159265358979323846 * $u * (2*$_+1) / (2*$c) );
            }
            $out->[$u] = $z/2;
        }
        return $out;
    }

    sub _dct_2d {
        my $mat = shift;
        my ($x, $y);
        my $dct_matrix = [];
        for $y (0 .. $#$mat) {
            $dct_matrix->[$y] = _dct_1d( $mat->[$y] );
        }
        for $x (0 .. $#{$mat->[0]}) {
            my $dct_col = _dct_1d([ map { $dct_matrix->[$_][$x] } 0..($#$mat) ]);
            for $y (0 .. $#$mat ) {
                $dct_matrix->[$y][$x] = $dct_col->[$y];
            }
        }
        return $dct_matrix;
    }

    sub perceptual_hash {
        my ($img0) = @_;
        my $img = $img0->scale(xpixels => 32, ypixels => 32)->convert(preset=>"grey");
        my $img_mat = [];
        my ($x,$y);
        for $y (0 .. 31) {
            $img_mat->[$y] = [ map { ($_->rgba)[0] } $img->getscanline(y => $y) ];
        }
        my $dct_matrix = _dct_2d($img_mat);

        my (@c, $sum);
        for $x (1 .. 8) {
            for $y (1 .. 8) {
                my $c = $dct_matrix->[$y][$x];
                push @c, $c;
                $sum += $c;
            }
        }

        my $hash = 0;
        my $avg = $sum/64;
        for my $i (0..$#c) {
            my $b = ($c[$i] > $avg) ? 1 : 0;
            $hash |= ($b << $i) if $b;
        }
        return $hash;
    }

};

1;
