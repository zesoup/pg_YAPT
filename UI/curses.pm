use 5.20.1;

package curses;

use Time::HiRes qw(gettimeofday usleep nanosleep);
use Term::ReadKey;
use POSIX;

#use utf8;
use Term::Cap;

use utils;

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

    my ( $obj, $config ) = @_;
    my $output = {};

    my $t        = Term::Cap->Tgetent;
    my $pidinfos = {};                   # HEAVY BLOAT!
    my $ping     = 0;
    my $i        = 0;
    print `clear`;
    while (1) {
        $utils::widenoverflow = 0;
        my $toprowContent = 0;
        my $linestart     = gettimeofday;
        my ( $wchar, $hchar, $wpixels, $hpixels ) = GetTerminalSize();
        my $wchar = $wchar > 80 ? 80 : $wchar;
        my $symbol = ':';
        if ( $ping++ % 2 ) { $symbol = ' '; }
        print $t->Tgoto( "cm", 20, 0 );    # 0-based
        print( "[" . $symbol . "] pgyapt " . $utils::config->{version} );

        foreach my $currentCheck ( @{ $obj->{checks} } ) {
            if ( $currentCheck eq "linebreak" ) {
                $toprowContent += $wchar - ( $toprowContent % $wchar );
                next;
            }
            utils::ensureCheck($currentCheck);
            $currentCheck->execute($_);
            my $metric;
            my $tup = $currentCheck->{returnVal};
            $metric = $tup->[0][0][0];
            my $unit   = $currentCheck->{base}->{units}[0] or "";
            my $status = $tup->[0][0][1];
            my $clr    = "White";
            my $r      = 1 + int( $toprowContent / $wchar );

            if ( $currentCheck->{position} eq 'bottomlist' ) {

                # special code here
                if ( $currentCheck->{action} eq 'user' ) {
                    print $t->Tgoto( "cm", 0, $r++ );

                    print utils::colorswitch("bold white on_blue");
                    print STDERR "\n";
                    foreach
                      my $colname ( @{ $currentCheck->{base}->{colnames} } )
                    {
                        print( ""
                              . utils::widen( $wchar, $colname . '', 8, 0, " " )
                        );
                    }
                    print utils::colorswitch("reset");
                    foreach my $row ( @{$tup} ) {
                        open my $FH, "/proc/$row->[0][0]/stat";
                        my $procstat = readline($FH);
                        close $FH;
                        my @procvals = split( " ", $procstat );

                        #		    print STDERR $procvals[13]."\n";
                        my $procdelta =
                          $procvals[13] - $pidinfos->{ $row->[0][0] }[0]
                          or 0;
                        $pidinfos->{ $row->[0][0] } = [ $procvals[13] ];
                        push( @{$row}, [$procdelta] );

                        print $t->Tgoto( "cm", 0, $r++ );
                        if ( $row->[4][0] ) {
                            print utils::colorswitch("bold yellow on_red");
                        }
                        elsif ( $row->[6][0] eq 'active' ) {
                            print utils::colorswitch("black on_bright_green");
                        }
                        elsif ( $row->[6][0] eq 'idle in transaction' ) {
                            print utils::colorswitch("black on_yellow");
                        }
                        else {
                            print utils::colorswitch("black on_white");
                        }

                        foreach my $val ( @{$row} ) {
                            if ( $val->[0] eq "idle in transaction" ) {
                                $val->[0] = 'idleIT';
                            }
                            print(
                                ""
                                  . utils::widen(
                                    $wchar, $val->[0] . '',
                                    8, 0, " "
                                  )
                            );
                        }
                        print utils::colorswitch("reset");
                    }
                }

            }
            else {
                my $metricText = '';
                my $iteration  = 0;
                foreach my $col ( @{ $tup->[0] } ) {
                    if ( $iteration++ ) { $metricText .= '/'; }
                    $metricText .=
                      utils::formatter( $col->[0], $unit, $currentCheck );
                }
                $metricText =
                  utils::fillwith( " ",
                    4 + ( $iteration * 2 ) - length($metricText) )
                  . $metricText;
                my $linesize =
                  length( $currentCheck->{identifier} . " " . $metricText );
                if ( ( $toprowContent % $wchar ) > ( $wchar - $linesize ) ) {
                    $toprowContent += $wchar - ( $toprowContent % $wchar );
                }
                print $t->Tgoto(
                    "cm",
                    $toprowContent % $wchar,
                    1 + int( $toprowContent / $wchar )
                );
                $toprowContent += $linesize;

                print(  ""
                      . $currentCheck->{identifier} . ""
                      . utils::colorswitch("bold blue")
                      . $metricText
                      . utils::colorswitch("reset")
                      . "" );

            }
        }
        $utils::config->{DB}->commit;
        print `clear`;
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
        usleep $timetosleep;

    }

}
1;
