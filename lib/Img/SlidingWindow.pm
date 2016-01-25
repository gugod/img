use v5.18;
package Img::SlidingWindow {
    use Moo;
    use Img;
    use Img::ImagePatch;

    has offset_top  => ( is => "rw", default => 0 );
    has offset_left => ( is => "rw", default => 0 );

    has width  => (is => "ro", required => 1);
    has height => (is => "ro", required => 1);
    has image  => (is => "ro", required => 1);

    has step => ( is => "rw", default => 1 );
    has top  => ( is => "rw", default => sub { $_[0]->offset_top  } );
    has left => ( is => "rw", default => sub { $_[0]->offset_left } );

    sub reset {
        my $self = shift;
        $self->top( $self->offset_top );
        $self->left( $self->offset_left );
    }

    sub next {
        my $self = shift;
        my $x = $self->left;
        my $y = $self->top;

        if ( $x + $self->width >= $self->image->getwidth ) {
            $x = $self->offset_left;
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
