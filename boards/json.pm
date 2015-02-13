use 5.20.1;

package json;

use Time::HiRes qw(usleep nanosleep);
use Term::ReadKey;
use POSIX;
use Term::ANSIColor;
use utils;
use JSON;

sub new {
    my (%params) = @_;
    my $self = { config => $params{config} };

    bless( $self, __PACKAGE__ );
    return $self;

}

sub loop {
    my ( $obj, $config ) = @_;
    my $output = {};

    foreach ( @{ $obj->{checks} } ) {
        my $currentCheck = $config->{checks}->{$_};
        $currentCheck->execute();
        my $tup = $currentCheck->{returnVal};
        $output->{$_} = $tup;
    }

    my $json_text = encode_json $output;

    say $json_text;

}

1;
