use 5.20.1;

package wall;

use Time::HiRes qw(gettimeofday usleep nanosleep);
use Term::ReadKey;
use POSIX;
use Term::ANSIColor;
use utils;

$SIG{INT} = sub { unlink "pid"; exit "sigint"; };

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
    my ( $obj, $config, $name, $opts ) = @_;
    my $pack = $name;
    my $configAge = $utils::configAge;

    $obj->{hashsize} =
      @{ $config->{UI}->{$pack}->{checks} };
    
    my $line = "\n";
    # Initialize with a newline. This is will cause an unnecessary newline on startup, but will make sure
    # a sighup will work fine.

    while (1) {
      $utils::config->{DB}->commit;

       if ( $configAge ne $utils::configAge ) {
           return "continue";
        }
        my $linestart = gettimeofday;
        my ( $wchar, $hchar, $wpixels, $hpixels ) = GetTerminalSize();
        my $config = $utils::config;
        $config->{dbh}->{worsttime} = 0;
        unless ( exists $config->{main}->{i} ) { $config->{main}->{i} = 0; }
        unless ( $config->{main}->{i}++ % ( $hchar - 2 ) ) {
            my $first = 0;
            foreach ( @{ $obj->{checks} } ) {
                if ($first++){$line.= color("bright_yellow") . '│'};
                $line .=  color("bright_green")
                  . utils::widen( $wchar, $_, $obj->{hashsize}, 1, " " )
                  .  color("reset");
            }
            $line .= "\n";

            print $line;
            $line = "";
        }
        my $i = 0;
        foreach ( @{ $obj->{checks} } ) {

            my $currentCheck = $config->{checks}->{$_};
            if ( ( ++$i != 1 ) and ( $i - 1 != $obj->{hashsize} ) ) {
                $line .= color("bright_yellow") . '│' . color("reset");
            }
            $currentCheck->execute();
            my $tup = $currentCheck->{returnVal};

            my $metric = $tup->[0];
            my $unit   = $currentCheck->{units}[0] or "";
            my $status = $tup->[1];
            my $clr    = "White";
            if ( int($status) >= 1 ) { $clr = "Yellow"; }
            if ( int($status) >= 2 ) { $clr = "Red"; }

            $line .=
              color($clr)
              . utils::widen( $wchar, $metric . $unit, $obj->{hashsize}, 1,
                " " )
              . color("reset");
            print $line;
            $line = "";
        }
        $line = "\n";
        $| = 1;
        
        #$utils::config->{DB}->commit;
        my $timetosleep =
          ( $obj->{updatetime} - ( gettimeofday- $linestart ) * 1000000 );
        if ( $timetosleep < 0 ) {
            utils::ErrLog ("Queries take too long for loop!", "WALL", "WARN");
            $timetosleep = 0;
        }
        usleep $timetosleep;
    }

}

1;
