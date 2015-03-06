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
    my ( $obj, $config ) = @_;
    my $output;
    my $separator = ',';
    my $minRuns = 1; #Unless we use subtractions, a single run is sufficient.
                     #If there are subtractions(or deltas), run twice
for (my $i=0; $i < $minRuns; $i++){
$output = '';
  if (($minRuns > 1) and (exists $obj->{updatetime})){usleep $obj->{updatetime}; }
    foreach ( @{ $obj->{checks} } ) {
        my $currentCheck = $config->{checks}->{$_};
        if( ($currentCheck->{isDelta})and(not exists $currentCheck->{oldmetric}) ){$minRuns = 2;}
        $currentCheck->execute();
        my $tup = $currentCheck->{returnVal};
        unless($output eq ''){$output.=$separator;};
        $output .= $tup->[0];
    }
}
    if ($config->{Reattachable} == 1){utils::cacheConfig($config); }

   say $output;

}

1;
