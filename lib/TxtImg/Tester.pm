use v5.18;
package TxtImg::Tester {
    use Moo::Role;
    use List::Util qw<sum>;

    sub looks_boring {
        my ($img) = @_;
        my @counts = $img->getcolorusage;
        return 0.99 <= ($counts[0] / sum(@counts));
    }
};

1;
