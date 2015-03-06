use strict;
use warnings;
use 5.20.1;

package pg_dbi;
use Time::HiRes qw (gettimeofday);
use DBI;

sub new {
    my (%params) = @_;
    $params{config}->{DB}= {}; #clear last connection (if exists)
    my $self = $params{config}->{DB};
	$self->{ config } =$params{config};
    bless( $self, __PACKAGE__ );
    $self->{dbh} = init($params{config}->{database}); #push database - there are the configs
    return $self;
}

sub init {
    my $dbh = DBI->connect( 'DBI:Pg:'.$_[0]->{connection}, "", "" )
       or die "Couldn't connect to Database";
    $dbh->{AutoCommit}=0;
    $dbh->{ReadOnly}=1;
    $dbh->{destination}=$_[0]->{connection};
    unless ($dbh) { exit(1); }
    return $dbh;
}

sub returnAndStore {
    my ( $config, $query, $cachename ) = @_;
    my ( $starts, $startms ) = gettimeofday;
    my $attempts = 0;
    RETRY:
    if($attempts >=3){die "could not reestablish";};
    if($attempts){#sleep(1);
		$config->{dbh}= init($config->{config}->{database});
    }


    $attempts++;
    my $stm = $config->{dbh}->prepare($query) or goto RETRY;
    $stm->execute() or goto RETRY;

    my $out = $stm->fetchall_arrayref() or die "could not fetch array";
    my ( $ends, $endms ) = gettimeofday;
    unless ( exists $config->{config}->{DB}->{worsed} ) {
        $config->{config}->{DB}->{worsed} = 0;
    }
    if ( $config->{config}->{DB}->{worsed} < $endms - $startms ) {   # SECONDS!
        $config->{config}->{DB}->{worsed} = $endms - $startms;
    }

    $config->{config}->{cache}->{$cachename} = $out;
    return $out;
}

1;

