use 5.20.1;

package wall;

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
    my ($obj) = @_;
    while (1) {

        my ( $wchar, $hchar, $wpixels, $hpixels ) = GetTerminalSize();

        my $line = "\n";
        if ( utils::checkAndReloadConfig() ) {

            $line .= utils::widen( $wchar, "New Config!", 1, 0, " " ) . "\n";
        }
        my $config = $utils::config;
        $config->{dbh}->{worsttime} = 0;
        unless ( exists $config->{main}->{i} ) { $config->{main}->{i} = 0; }
        unless ( $config->{main}->{i}++ % ( $hchar - 2 ) ) {
            for ( my $i = 0 ; exists $obj->{checks}->{$i} ; $i++ ) {
                $line .= color("Green")
                  . utils::widen( $wchar, $obj->{checks}->{$i},
                    $obj->{hashsize}, 0, "▔" );
            }
            $line .= "\n";
            $line .= utils::fillwith( "▔", $wchar ) . "\n" . color("reset");
        }
        for ( my $i = 0 ; exists $obj->{checks}->{$i} ; $i++ ) {
            my $currentCheck =
              $config->{checks}->{ $obj->{checks}->{$i} };
            if ( $i > 0 ) { $line .= color("yellow") . '│' . color("reset"); }
            $currentCheck->show();
            my $tup    = $currentCheck->{returnVal};
            my $metric = $tup->[0];
            my $status = $tup->[1];
            my $clr    = "White";
            if    ( $status == 1 ) { $clr = "Yellow"; }
            elsif ( $status >= 2 ) { $clr = "Red"; }

            $line .=
                color($clr)
              . utils::widen( $wchar, $metric, $obj->{hashsize}, 1, " " )
              . color("reset");

        }
        print $line;
        $| = 1;

        use Data::Dumper;

        usleep $obj->{updatetime};
    }

}

1;
