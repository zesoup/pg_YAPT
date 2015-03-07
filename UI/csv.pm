use 5.20.1;

package csv;

use Time::HiRes qw(usleep nanosleep);
use Term::ReadKey;
use POSIX;
use Term::ANSIColor;
use utils;

sub new {
    my (%params) = @_;
    my $self = { config => $params{config} };

    bless( $self, __PACKAGE__ );
    return $self;

}

sub loop {
    my ( $obj, $config, $name, $UIopts ) = @_;
    my $output;
    my $separator = ';';
    my $loopagain = -1;    # Unless we use deltas a single run is sufficient.
                           # If there are deltas run twice
                           # If asked to via opt - run forever.
                           # set to -1 on init to identify the first run
    do {
        $output = '';
        if ( ( $loopagain == -1 ) and ( $UIopts =~ "header" ) ) {
            foreach ( @{ $obj->{checks} } ) {
                unless ( $output eq "" ) {
                    $output .= $separator;
                }
                $output .= $_;
            }
            $output .= "\n";
            print $output;
            $output = '';
        }
        $loopagain = 0;

        my $firstcheck = 0;
        foreach ( @{ $obj->{checks} } ) {
            my $currentCheck = $config->{checks}->{$_};
            if (    ( $currentCheck->{isDelta} )
                and ( not exists $currentCheck->{oldmetric} ) )
            {
                $loopagain = 1;
            }
            $currentCheck->execute();
            my $tup = $currentCheck->{returnVal};
            if ( $firstcheck++ ) { $output .= $separator; }
            $output .= $tup->[0] . $currentCheck->{units}[0];
        }

        unless ($loopagain) { say $output; }

        #at this point, loopagain is only set if current values are not valid.

        if ( $config->{Reattachable} == 1 ) { utils::cacheConfig($config); }

        if ( $UIopts =~ "repeat" ) { $loopagain = 1 }

        if ( ($loopagain) and ( exists $obj->{updatetime} ) ) {
            usleep $obj->{updatetime};
        }

    } while ($loopagain);
}

1;
