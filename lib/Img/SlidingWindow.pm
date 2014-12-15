use v5.18;
package Img::SlidingWindow {
    use Moo;
    use Img;
    use Img::ImagePatch;

    has width  => (is => "ro", required => 1);
    has height => (is => "ro", required => 1);
    has image  => (is => "ro", required => 1);

    has step => ( is => "rw", default => 1 );
    has top  => ( is => "rw", default => 0 );
    has left => ( is => "rw", default => 0 );

    sub reset {
        my $self = shift;
        $self->top(0);
        $self->left(0);
    }

    sub next {
        my $self = shift;
        my $x = $self->left;
        my $y = $self->top;

        if ( $x + $self->width >= $self->image->getwidth ) {
            $x = 0;
            $y += $self->step;
            if ( $y + $self->height >= $self->image->getheight ) {
                return;
            }
        } else {
            $x += $self->step;
        }

        my $w = $self->image->crop(left => $x, top => $y, width => $self->width, height => $self->height);

        $self->top($y);
        $self->left($x);

        return Img::ImagePatch->new(
            top => $y,
            left => $x,
            image => $self->image,
            patch => $w,
        );
    }
};
1;
