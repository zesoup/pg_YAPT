
package querycheck;
use warnings;
use strict;
use POSIX;
use 5.20.1;
use utils;


sub new {
    shift;
    my ($params) = @_;

    $params->{base} =
      $utils::config->{checks}->{ $params->{check} };
    $params->{identifier} = ( $params->{label} || $params->{check} );

    bless( $params, __PACKAGE__ );
    return $params;

}

sub execute {
    my ($obj) = @_;
    my $identifier = $obj->{identifier};
    utils::stampbegin( $obj );
    my $queryparams = undef;    #TODO

    # Call the Query and fetch the result.
    $obj->{metric} =
      $utils::config->{DB}->ask( $obj->{base}->{query}, $obj->{qParams}, $obj );

    # Make sure all values exist
    unless ( defined $obj->{metric} ) {
        $obj->{metric} = $obj->{querytest};
    }
    unless ( exists $obj->{oldmetric} ) {
        $obj->{oldmetric} = $obj->{metric};
    }

    # Start processing.
    if ( exists $obj->{base}->{action} ) {
        $obj->{returnVal} = $obj->{base}->{action}($obj);
    }
    elsif ( ( exists $obj->{base}->{isDelta} ) and ( $obj->{base}->{isDelta} ) ) {
        $obj->{returnVal} =
          [ [ [ $obj->{'metric'}[0][0] - $obj->{'oldmetric'}[0][0], 0 ] ] ];
    }
    else {
        $obj->{returnVal} = [];

        foreach my $row ( @{ $obj->{metric} } ) {
            my $rowArr = [];
            foreach my $val ( @{$row} ) {
                push( @{$rowArr}, [ $val, 0 ] );
            }
            push( @{ $obj->{returnVal} }, $rowArr );
        }
    }
    $obj->{oldmetric} = $obj->{metric};

    utils::stampend( $obj );
    utils::checkTiming($obj);

    return 0;
}

1;
