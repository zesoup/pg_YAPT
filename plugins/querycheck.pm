
package querycheck;
use warnings;
use strict;
use POSIX;
use 5.20.1;

sub new {
    my ( $identifier, %params ) = @_;

    my $self = { config => $params{config}, name => $params{name} };

    #    bless( $self, __PACKAGE__ );
    return $self;

}

sub execute {
    my ($obj,$params) = @_;
    my $packname = __PACKAGE__;
    my $identifier = ( $params->{label} || $params->{check} );
    utils::stampbegin($obj->{ $identifier });
    my $queryparams = $params->{"param"};
my $test = 6;
    # Call the Query and fetch the result.
    $obj->{$identifier}->{metric} =
      $obj->{config}->{DB}->returnAndStore( $obj->{query}, $identifier , $queryparams);

    # Make sure all values exist
    unless ( defined $obj->{$identifier}->{metric} ) {
        $obj->{$identifier}->{metric} = $obj->{querytest} ;
    }
    unless ( exists $obj->{$identifier}->{oldmetric} ) {
        $obj->{$identifier}->{oldmetric} = $obj->{$identifier}->{metric};
    }


    # Start processing.
    if ( exists $obj->{action} ) { $obj->{$identifier}->{returnVal} = $obj->{action}($obj->{$identifier}); }
    elsif ( ( exists $obj->{isDelta} ) and ( $obj->{isDelta} ) ) {
        $obj->{$identifier}->{returnVal} =
          [ [ [ $obj->{$identifier}->{'metric'}[0][0] - $obj->{$identifier}->{'oldmetric'}[0][0], 0 ] ] ];
    }
    else {
        $obj->{$identifier}->{returnVal} = [];

        foreach my $row ( @{ $obj->{$identifier}->{metric} } ) {
            my $rowArr = [];
            foreach my $val ( @{$row} ) {
                push( @{$rowArr}, [ $val, 0 ] );
            }
            push( @{ $obj->{$identifier}->{returnVal} }, $rowArr );
        }
    }
    $obj->{$identifier}->{oldmetric} = $obj->{$identifier}->{metric};


    utils::stampend($obj->{$identifier});
    if (
            ( exists $obj->{config}->{timing} )
        and ( $obj->{config}->{timing} >= 0 )
        and ( ( $obj->{$identifier}->{endstamp} - $obj->{$identifier}->{initstamp} ) * 1000 >=
            $obj->{config}->{timing} )
      )
    {
        utils::ErrLog(
            ceil( 1000 * ( $obj->{endstamp} - $obj->{initstamp} ) ) . "ms",
            $obj->{name}, "INFO" );
    }

    return 0;
}

1;
