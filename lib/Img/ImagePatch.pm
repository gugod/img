use v5.18;
package Img::ImagePatch {
    use Moo;
    use Imager;
    has image => (
        is => "ro",
        required => 1,
    );
    has patch => (
        is => "ro",
        required => 1,
    );
    has top => ( is => "ro", "required" => 1 );
    has left => ( is => "ro", "required" => 1 );
};
1;
