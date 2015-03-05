use strict;
use warnings;
use 5.20.1;

package pg_dbi;
use Time::HiRes qw (gettimeofday);
use DBI;

sub new {
    my (%params) = @_;
    my $self = { config => $params{config} };
    bless( $self, __PACKAGE__ );
    $self->{dbh} = init();
    return $self;
}

sub init {
    my $dbh = DBI->connect( 'DBI:Pg:host=127.0.0.1;dbname=postgres', "", "" )
       or die "Couldn't connect to Database";
    $dbh->{AutoCommit}=0;
    $dbh->{ReadOnly}=1;
    unless ($dbh) { exit(1); }
    return $dbh;
}

sub returnAndStore {

    my ( $config, $query, $cachename ) = @_;
    my ( $starts, $startms ) = gettimeofday;
    my $stm = $config->{dbh}->prepare($query) or die "could not prepare query";
    $stm->execute() or die "could not execute ";

    my $out = $stm->fetchall_arrayref() or die "could not fetcgh array";
    my ( $ends, $endms ) = gettimeofday;
    unless ( exists $config->{config}->{dbh}->{worsed} ) {
        $config->{config}->{dbh}->{worsed} = 0;
    }
    if ( $config->{config}->{dbh}->{worsed} < $endms - $startms ) {   # SECONDS!
        $config->{config}->{dbh}->{worsed} = $endms - $startms;
    }

    $config->{config}->{cache}->{$cachename} = $out;
    return $out;
}

1;

