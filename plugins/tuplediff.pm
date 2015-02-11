
package tuplediff;
use warnings;
use strict;

use 5.20.1;

sub new {
    my ( $name, %params ) = @_;
    my $self = { config => $params{config}, name => $params{name} };
    bless( $self, __PACKAGE__ );
    $self->{cache} = [ ["0"] ];
    return $self;
}

sub show {
    my ($obj) = @_;
    my $config = $obj->{config};

    my $params = $obj->{config}->{checks}->{ $obj->{name} };
    my $out    = "";

    my $metric;
    my $packname = __PACKAGE__;

    my $valold = $obj->{cache}[0][0];
    $metric = $config->{dbi}->returnAndStore(
"select sum( coalesce(idx_tup_fetch,0)+coalesce(seq_tup_read,0) ) as reads from pg_stat_user_tables; ",
        $obj->{name}
    );

    my $valnew    = $metric->[0][0];
    my $diffReads = $valnew - $valold;

    $obj->{cache} = $metric;
    $out .= "" . $diffReads . "";
    return $out;
}

1;
