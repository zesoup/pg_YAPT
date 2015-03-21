use 5.20.1;

package curses;

use Time::HiRes qw(usleep nanosleep);
use Term::ReadKey;
use POSIX;
use utf8;

use utils;
use Curses;
use Curses::UI;

sub new {
    my (%params) = @_;
    my $self = { config => $params{config} };

    bless( $self, __PACKAGE__ );
    return $self;

}

sub exitCurses {
    exit(1);
}

sub loop {
    my ( $wchar, $hchar, $wpixels, $hpixels ) = GetTerminalSize();

    my ( $obj, $config ) = @_;
    my $output = {};
    my $cui = new Curses::UI( -color_support => 1 );

    my $window = $cui->add( 'window1', 'Window', -border => 0, );

    my $pinglab = $window->add(
        'ping', 'Label',
        -border => 0,
        -width  => 5,
        -text   => ''
    );

    my $stat = $window->add(
        'status', 'Label',
        -border        => 0,
        -width         => $wchar,
        -textalignment => 'middle',
        -text          => ''
    );

    my $bars   = 2;
    my $fields = [];
    for ( my $i = 0 ; $i < $bars ; $i++ ) {
        push(
            @{$fields},
            $window->add(
                "label$i", 'Label',
                -width         => $wchar / 2,
                -border        => 0,
                -padtop        => $i + 1,
                -padleft       => 0,
                -textalignment => 'right',
                -text          => '',
            )
        );
    }
    my $ping = 0;

    sub displayTime {
        my $i = 0;
        my $metric;
        foreach ( @{ $obj->{checks} } ) {
            my $currentCheck = $config->{checks}->{$_->{check} };
            my $checkname = ( $_->{label} or $_->{check} );

            $currentCheck->execute( $_ );

            my $tup = $currentCheck->{$checkname}->{returnVal};
            $metric = $tup->[0][0][0];
            my $unit    = $currentCheck->{units}[0] or "";
            my $status  = $tup->[0][0][1];
            my $clr     = "White";
            my $scaling = ( $fields->[$i]->{'-width'} - 5 ) / ($tup->[0][2][0] or 1);
            my $freebackends = ( $tup->[0][0][0] - $tup->[0][1][0] ) * $scaling;
            my $waitingbackends = $tup->[0][1][0] * $scaling;

            if ( $tup->[0][0][0] > 1000 ) {
                $tup->[0][0][0] = '' . int( $tup->[0][0][0] / 1000 ) . 'k';
            }
            if ( $tup->[0][1][0] > 1000 ) {
                $tup->[0][1][0] = '' . int( $tup->[0][1][0] / 1000 ) . 'k';
            }
            my $title = $tup->[0][0][0] . "/" . $tup->[0][1][0];
            $title =
              utils::fillwith( " ",
                8 - length( $tup->[0][0][0] . "/" . $tup->[0][1][0] ) )
              . $title;
            $fields->[ $i++ ]->text( utils::fillwith( "▭", $freebackends )
                  . utils::fillwith( "▬", $waitingbackends ) . ""
                  . $title );

        }
        my $symbol = '⇋';
        if ( $ping++ % 2 ) { $symbol = '⇌'; }
        $pinglab->text( "" . $symbol . "" );
        $stat->text( localtime . " [Still in Development]" );
        $utils::config->{DB}->commit;
    }

    $cui->set_binding( sub { exit; }, "\cQ" );
    $cui->set_binding( sub { exit; }, "\cC" );
    $cui->set_timer( 'update_time', \&displayTime, 1 );
    $cui->mainloop();

}
1;
