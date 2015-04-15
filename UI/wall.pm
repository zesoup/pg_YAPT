use 5.20.1;

package wall;

use Time::HiRes qw(gettimeofday usleep nanosleep);
use Term::ReadKey;
use POSIX;
use utils;

sub new {
    my (%params) = @_;
    my $self = { config => $params{config} };
    bless( $self, __PACKAGE__ );
    return $self;

}


sub loop {
    my ( $obj, $config, $name, $opts ) = @_;
    my $configAge = $utils::configAge;
    my $loopcount = utils::getValueOfOptOrDefault( $opts, "loops=", -1 );
    my $fixwidth  = utils::getValueOfOptOrDefault( $opts, "width=", -1 );
    my $separator = utils::colorswitch("bright_yellow") . '│' . utils::colorswitch("reset")
      unless $utils::config->{delimiter};
    $obj->{hashsize} =
      @{ $config->{UI}->{$name}->{checks} };
    my $line = "\n";
    $| = 1;
# Initialize with a newline. This is will cause an unnecessary newline on startup, but will make sure
# a sighup will work fine.
    while ( $loopcount-- ) {
        $utils::widenoverflow = 0;
        $utils::config->{DB}->commit;

        my $linestart = gettimeofday;
        my ( $wchar, $hchar, $wpixels, $hpixels ) = GetTerminalSize();

        if ( $fixwidth != -1 ) { $wchar = $fixwidth }

        my $config = $utils::config;
        $config->{dbh}->{worsttime} = 0;
        unless ( exists $config->{main}->{i} ) { $config->{main}->{i} = 0; }

        # Repeatable Header
        unless ( $config->{main}->{i}++ % ( $hchar - 1 ) ) {
            my $first = 0;
            foreach ( @{ $obj->{checks} } ) {
                if ( $first++ ) { $line .= $separator; }
                $line .= utils::colorswitch("bright_green")
                  . utils::widen( $wchar, ( $_->{label} or $_->{check} ),
                    $obj->{hashsize}, 1, " " )
                  . utils::colorswitch("reset");
            }
            $line .= "\n";

            print $line;
            $line = "";
        }

        # Actual Check
        my $i           = 0;
        foreach my $currentCheck ( @{ $obj->{checks} } ) {
 if ( ref $currentCheck eq "HASH" )
{ $currentCheck = utils::checkfactory($currentCheck) }

$currentCheck->execute();
            my $tup    = $currentCheck->{returnVal};
            my $maxlen = scalar @{ $tup->[0] };
            my $valuestring = "";
            for ( my $i = 0 ; $i < $maxlen ; $i++ ) {
                my $metric = $tup->[0][$i][0];
                my $unit   = $currentCheck->{base}->{units}[$i];
                my $status = $tup->[0][$i][1];

                if ($i){
                $valuestring .=" "}
                    $valuestring .= utils::formatter($metric, $unit, $currentCheck );
            }
            if ( ( $i++ != 0 ) and ( $i != $obj->{hashsize}+1 ) ) {
                $line .= $separator;
            }

            $line .=
               utils::widen( $wchar, $valuestring, $obj->{hashsize}, 1, " " );
            print $line;
            $line = "";
        }
        $line = "\n";

        $utils::config->{DB}
          ->commit;    # this commit will prevent idle_in_transaction marks.
        my $now = gettimeofday;
        my $timetosleep =
          ( $obj->{updatetime} - ( $now - $linestart ) * 1000000 );

        if ( $utils::config->{sync} ) {
            my $sleepfix = ( $now * 1000 ) % ( $obj->{updatetime} / 1000 );
            if ( $sleepfix * 1000 > $obj->{updatetime} / 2.0 ) {
                $sleepfix = -( $obj->{updatetime} / 1000 - $sleepfix );
            }
            $timetosleep = $timetosleep - 300 * $sleepfix;

        }

        if ( $timetosleep < 0 ) {
            utils::ErrLog( "Queries take too long for loop!", "WALL", "WARN" );
            $timetosleep = 0;
        }
        if ($loopcount) { usleep $timetosleep}
    }

}

1;
