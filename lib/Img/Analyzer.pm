use v5.18;
package Img::Analyzer {
    use Moo;
    use Imager;
    use List::MoreUtils 'uniq';

    sub analyze {
        my ($self, $file) = @_;
        my $img = Imager->new( file => $file ) or die Imager->errstr;
        $img = $img->convert( preset => "noalpha" )->scale( xpixels => 100, ypixels => 100, type => "nonprop", qtype => "preview" );
        my $doc = {};
        for my $channel (0 .. $img->getchannels-1) {
            my $img = $img->convert( preset => "channel${channel}" );
            my $mat = [];
            for my $y (0..$img->getheight-1) {
                $mat->[$y] = [map { sprintf('%x', ($_->rgba)[0]) } $img->getscanline(y=>$y)];
            }
            my $feature = [];
            my $feature3x3 = [];
            for my $y (0..$img->getheight-3) {
                for my $x (0..$img->getwidth-3) {
                    push @$feature, $mat->[$y][$x];
                    push @$feature3x3, join(
                        "",
                        $mat->[$y][$x],
                        $mat->[$y][$x+1],
                        $mat->[$y][$x+2],
                        $mat->[$y+1][$x],
                        $mat->[$y+1][$x+1],
                        $mat->[$y+1][$x+2],
                        $mat->[$y+2][$x],
                        $mat->[$y+2][$x+1],
                        $mat->[$y+2][$x+2],
                    );
                }
            }
            push @{$doc->{feature3x3}}, @$feature3x3;
            push @{$doc->{feature}}, @$feature;
        }
        $doc->{feature} = [uniq(@{$doc->{feature}})];
        $doc->{feature3x3} = [uniq(@{$doc->{feature3x3}})];
        return $doc;
    }
};
1;
