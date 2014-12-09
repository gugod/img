use v5.18;
package Img::Analyzer {
    use Moo;
    use Imager;
    use List::MoreUtils 'uniq';

    use Img::Hashing;

    sub analyze {
        my ($self, $file) = @_;
        my $doc = {};
        my $img = Imager->new( file => $file ) or die Imager->errstr;

        for my $hashing (qw< average_hash difference_hash >) {
            my $method = Img::Hashing->can($hashing);
            my @tokens;
            my $hash = $method->($img);
            for my $i (0..63) {
                my $b = ($hash & (1<<$i)) >> $i;
                push @tokens, $i . "_" . $b;
            }
            $doc->{$hashing} = \@tokens;
        }

        return $doc;
    }
};
1;
