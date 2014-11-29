use v5.18;
package Img::Hashing {
    sub average_hash {
        my ($img0) = @_;
        my $img = $img0->scale(xpixels => 8, ypixels => 8)->convert(preset=>"grey");
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
};
1;
