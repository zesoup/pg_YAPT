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
                if ( ref $_ eq "HASH" ) { $_ = utils::checkfactory($_) }

                unless ( $output eq "" ) {
                    $output .= $separator;
                }
                $output .= $_->{identifier};
            }
            $output .= "\n";
            print $output;
            $output = '';
        }
        $loopagain = 0;

        my $firstcheck = 0;
        foreach my $currentCheck ( @{ $obj->{checks} } ) {
           # if (    ( $currentCheck->{base}->{isDelta} )
           #     and ( not exists $currentCheck->{oldmetric} ) )
           # {
           #     $loopagain = 1; say STDERR "LOOOP";
           # }
            utils::ensureCheck($currentCheck);

            $currentCheck->execute();
            if ($currentCheck->{needsredo}eq 1){
            $loopagain=1;
            }

            my $tup = $currentCheck->{returnVal};
            if ( $firstcheck++ ) { $output .= $separator; }
            $output .= $tup->[0][0][0] . $currentCheck->{base}->{units}[0];
        }

        unless ($loopagain) { say $output; }

        #at this point, loopagain is only set if current values are not valid.

        if ( $config->{Reattachable} == 1 ) { utils::cacheChecks($obj); }

        if ( $UIopts =~ "repeat" ) { $loopagain = 1 }
        $utils::config->{DB}->commit;
        if ( ($loopagain) and ( exists $obj->{updatetime} ) ) {
            usleep $obj->{updatetime};
        }

    } while ($loopagain);
}

1;
