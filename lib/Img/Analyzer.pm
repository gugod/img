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

        my @avghash_tokens;
        my $avghash = Img::Hashing::average_hash($img);
        for my $i (0..63) {
            my $b = ($avghash & (1<<$i)) >> $i;
            push @avghash_tokens, $i . "_" . $b;
        }
        $doc->{average_hash} = \@avghash_tokens;

        return $doc;
    }
};
1;
