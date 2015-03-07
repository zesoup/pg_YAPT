use strict;
use warnings;
use 5.20.1;

package pg_dbi;
use Time::HiRes qw (gettimeofday usleep);
use DBI;
use utils;

sub new {
    my (%params) = @_;
    $params{config}->{DB} = {};    #clear last connection (if exists)
    my $self = $params{config}->{DB};
    $self->{config} = $params{config};
    bless( $self, __PACKAGE__ );
    if ( $self->{config}->{tests} ) {
     utils::ErrLog ("Tests Enabled! Will not connect to DB!", "DB", "WARN"); 
     $self->{tests} = 1; }
    else {
        $self->{dbh} = init( $params{config}->{database} )
          ;                        #push database - there are the configs
    }
    return $self;
}

sub init {
    my $dbh = DBI->connect( 'DBI:Pg:' . $_[0]->{connection}, "", "" )
     or utils::ErrLog ("Couldnt connect to DB", "DB", "FATAL");# or die "Couldn't connect to Database";
    $dbh->{AutoCommit}  = 0;
    $dbh->{ReadOnly}    = 1;
    $dbh->{destination} = $_[0]->{connection};
    unless ($dbh) { exit(1); }
    return $dbh;
}

sub commit {
    unless ( $_[0]->{tests} ) { $_[0]->{dbh}->commit; }
}

sub returnAndStore {
    my ( $config, $query, $cachename ) = @_;
    my ( $starts, $startms ) = gettimeofday;
    if ( exists $config->{tests} ) {
        my $output = [ [0] ];
        $output = $config->{config}->{checks}->{$cachename}->{querytest};
        return $output;
    }
    my $attempts = 0;
  RETRY:
    if ( $attempts >= $config->{config}->{database}->{maxAttempts} ) { die "could not reestablish connection"; }
    if ($attempts) {
        utils::ErrLog("DB-Connection broken!", "DB", "WARN");
        usleep( $config->{config}->{database}->{reconnectdelay}*1000000 );
        utils::ErrLog("Trying to reconnect", "DB", "INFO");
        $config->{dbh} = init( $config->{config}->{database} );
    }

    $attempts++; 
    goto RETRY unless (UNIVERSAL::isa($config->{dbh}, "DBI::db")  );
    my $stm = $config->{dbh}->prepare($query) or goto RETRY;
    $stm->execute() or goto RETRY;

    my $out = $stm->fetchall_arrayref() or goto RETRY;
    my ( $ends, $endms ) = gettimeofday;
    unless ( exists $config->{config}->{DB}->{worsed} ) {
        $config->{config}->{DB}->{worsed} = 0;
    }
    if ( $config->{config}->{DB}->{worsed} < $endms - $startms ) {    # SECONDS!
        $config->{config}->{DB}->{worsed} = $endms - $startms;
    }

    $config->{config}->{cache}->{$cachename} = $out;
    return $out;
}

1;

