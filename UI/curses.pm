use 5.20.1;

package curses;

use Time::HiRes qw(usleep nanosleep);
use Term::ReadKey;
use POSIX;
use Term::ANSIColor;
use utils;

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

    my $i = 0;
    my $window = $cui->add( 'window1', 'Window', -border => 0, );


    my $stat = $window->add(
'status','Label',
-border=>0,
-width=>$wchar,
-textalignment=>'middle',
-text=>''
);
    my $lab1 = $window->add(
        'label1', 'Label',
        -width => $wchar/2,
        -border=>0,
        -padtop=>1,
        -padleft=>0,
        -textalignment=>'right',
        -text  => '',
    );

    my $i = 0;
    my $ping = 0;
    sub displayTime {
       my $metric;
        foreach ( @{ $obj->{checks} } ) {

            my $currentCheck = $config->{checks}->{$_};

            $currentCheck->execute();
            my $tup    = $currentCheck->{returnVal};
            $metric = $tup->[0][0][0];
            my $unit   = $currentCheck->{units}[0] or "";
            my $status = $tup->[0][0][1];
            my $clr    = "White";

my $scaling = ($lab1->{'-width'}-5) /  $tup->[0][2][0];
my $freebackends = ($tup->[0][0][0] - $tup->[0][1][0])* $scaling;
my $waitingbackends = $tup->[0][1][0]* $scaling;
    $lab1->text(  
utils::fillwith
( ".", $freebackends )
. utils::fillwith
(":",$waitingbackends)."".$tup->[0][0][0]."/".$tup->[0][1][0] );


        }
if($ping){$ping =0}
    else{$ping=1}

my $symbol = '↓';
if ($ping){$symbol='↡';}
$stat->text( $symbol.localtime."Still in Development!" );
    $utils::config->{DB}->commit;
    }

    $cui->set_binding( sub { exit; }, "\cQ" );
    $cui->set_binding( sub { exit; }, "\cC" );
    $cui->set_timer( 'update_time', \&displayTime ,1);

   $cui->mainloop();

}

1;
