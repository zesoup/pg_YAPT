use 5.20.1;

package list;

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
    $obj->{hashsize} =
      @{ $config->{UI}->{$name}->{checks} };
    my $fixwidth = utils::getValueOfOptOrDefault( $opts, "width=", -1 );

    my $line = "\n";

    my $linestart = gettimeofday;
    my ( $wchar, $hchar, $wpixels, $hpixels ) = GetTerminalSize();
    print '['.localtime.']';
    if ( $fixwidth != -1 ) { $wchar = $fixwidth }
    my $first =0;
    my $config = $utils::config;
    foreach ( @{ $obj->{checks} } ) {
        if ( $first++ ) { $line .= color("bright_yellow") . '│' }
        $line .=
           utils::widen( $wchar, $_, $obj->{hashsize}, 1, " " );
    }
    $line .= "\n";

    print $line;
    $line = "";

    my $i = 0;
    foreach ( @{ $obj->{checks} } ) {

        my $currentCheck = $config->{checks}->{$_};
        if ( ( ++$i != 1 ) and ( $i - 1 != $obj->{hashsize} ) ) {
            $line .= '│';
        }
        $currentCheck->execute();
        my $tup = $currentCheck->{returnVal};
#        use Data::Dumper; say STDERR Dumper($tup);
        foreach my $row   ( @{ $tup } ){
       $utils::widenoverflow=0;
        my $numVals = @{$row};
        foreach my $value ( @{ $row } ){
        my $metric = $value->[0];
        my $unit   = $currentCheck->{units}[0] or "";
        my $status = $tup->[1];

        $line .=
           utils::widen( $wchar, $metric . $unit, $numVals,0, " " );
        print $line;
        $line = "";
    }$line .= "\n";
    }
    }
    $line = "\n";
    $|    = 1;

}

1;
