use v5.18;
package Img {
    use Moo;
    extends 'Imager';
    with qw<Img::Hashing Img::Segmenting Img::Tester>;

    around qw<crop copy to_paletted convert scale> => sub {
        my $orig = shift;
        my $ret = $orig->(@_);
        bless $ret, 'Img';
        return $ret;
    };

};
1;
