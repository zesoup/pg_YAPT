use 5.20.1;

package wall;

use Time::HiRes qw(gettimeofday usleep nanosleep);
use Term::ReadKey;
use POSIX;
use Term::ANSIColor;
use utils;

$SIG{INT} = sub {unlink "pid"; exit "sigint";};

sub new {
    my (%params) = @_;
    my $self = { config => $params{config} };

    bless( $self, __PACKAGE__ );
    return $self;

}

sub loop {
    open my $pidFH, ">", "pid";
    print $pidFH $$;
    close $pidFH;
    my ($obj,$config) = @_; my $pack =  __PACKAGE__;
    $obj->{hashsize} =
      @{$config->{UI}->{$pack}->{checks}};


    while (1) {
if ( $config->{magicnumber} ne $utils::config->{magicnumber}){ return "continue";}
        my $linestart = gettimeofday;
        my ( $wchar, $hchar, $wpixels, $hpixels ) = GetTerminalSize();

        my $line = "\n";
       # if ( utils::checkAndReloadConfig() ) {
       #     $line .= utils::widen( $wchar, "New Config!", 1, 0, " " ) . "\n";
       #     return "continue";
       # }
        my $config = $utils::config;
        $config->{dbh}->{worsttime} = 0;
        unless ( exists $config->{main}->{i} ) { $config->{main}->{i} = 0; }
        unless ( $config->{main}->{i}++ % ( $hchar - 2 ) ) {
            foreach ( @{$obj->{checks}} ) {
               $line .= color("Green")
                  . utils::widen( $wchar, $_,
                    $obj->{hashsize}, 0, " " );
            }
            $line .= "\n";
            $line .= utils::fillwith( "▔", $wchar ) . "\n" . color("reset");
            print $line;
            $line = "";
        }
        my $i = 0;
        foreach  (@{$obj->{checks}}){
            
              my $currentCheck =
              $config->{checks}->{ $_ };
            if (( ++$i != 1)and($i-1 != $obj->{hashsize} ) ) { $line .= color("bright_yellow") . '│' . color("reset"); }
            $currentCheck->execute();
            my $tup    = $currentCheck->{returnVal};
	    #my $tup = [ ceil(1000*($currentCheck->{endstamp} - $currentCheck->{initstamp}) )."ms",0];
            my $metric = $tup->[0];
            my $unit = $currentCheck->{units}[0] or "";
            my $status = $tup->[1];
            my $clr    = "White";
            if    ( $status == 1 ) { $clr = "Yellow"; }
            elsif ( $status >= 2 ) { $clr = "Red"; }

            $line .=
                color($clr)
              . utils::widen( $wchar, $metric.$unit, $obj->{hashsize}, 1, " " )
              . color("reset");
            print $line; $line = "";
        }
        #print $line;
        $| = 1;
	$utils::config->{DB}->{dbh}->commit;
        my $timetosleep = ($obj->{updatetime}- (gettimeofday-$linestart)*1000000);
        if ($timetosleep<0){print STDERR "\n Queries take too long!"; $timetosleep=0;}
        usleep $timetosleep;
    }

}

1;
