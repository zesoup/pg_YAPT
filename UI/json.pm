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
    my $output  = {};
    my $minRuns = 1;    #Unless we use subtractions, a single run is sufficient.
                        #If there are subtractions(or deltas), run twice
    for ( my $i = 0 ; $i < $minRuns ; $i++ ) {
        if ( ( $minRuns > 1 ) and ( exists $obj->{updatetime} ) ) {
            usleep $obj->{updatetime};
        }
        foreach ( @{ $obj->{checks} } ) {
            my $currentCheck = $config->{checks}->{ $_->{check} };
            my $checkname = ($_->{label}  or $_->{check} );


            if (    ( $currentCheck->{isDelta} )
                and ( not exists $currentCheck->{$checkname}->{oldmetric} ) )
            {say STDERR $checkname;
#use Data::Dumper; $Data::Dumper::Maxdepth=2; say STDERR Dumper($currentCheck);
                $minRuns = 2;
            }
            $currentCheck->execute( $_ );
            my $tup = $currentCheck->{$checkname}->{returnVal};
            $output->{ $checkname } = $tup->[0][0];
        }
    }
    my $json_text = encode_json $output;
    if ( $config->{Reattachable} == 1 ) { utils::cacheChecks(); }

    say $json_text;

}

1;
