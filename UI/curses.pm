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
    my ( $obj, $config ) = @_;
    my $output = {};
    my $cui = new Curses::UI( -color_support => 1 );

    my $n        = 1;
    my $widclock = $cui->add(
        $_, 'Window',
        -border => 1,
        -height => 5,
        -padtop => 10,
        -x      => ( rand() * 100 ) % 50,
        -width  => 35
    );
        $winclock::label = $widclock->add(
            'wmainlabel', 'Label',
            -text  => $_ . "init",
            -bold  => 0,
            height => 15,
            -width => 15
        );
my $me = $winclock::label;
        $cui->set_timer(
            'update_timer' . $_,
            sub {

my $args = '';
    foreach ( @{ $obj->{checks} } ) {
my $currentCheck = $config->{checks}->{$_};
$currentCheck->execute();

$args.= $_.':'.$currentCheck->{returnVal}[0].'\n';
}

                $winclock::label->{'-text'} = $args;
            },
            1
        );    # call back in here

        #        sub call {
        #            my $currentCheck = $config->{checks}->{$_};
        #            $currentCheck->execute();
        #            my $tup = $currentCheck->{returnVal};
        #            $output->{$_} = $tup;
        #
        #            $winclock::label->{'-text'} = 'das';
        #        }

    
    $cui->set_binding( sub { exit(0); }, "\cQ" );
    $cui->set_binding( sub { exit(0); }, "\cC" );

    #$cui->set_timer('update_timer',\&call,$n); # call back in here
    $cui->mainloop();

    #sub call{
    #$winclock::label->{'-text'}='das';
    #}

}

1;
