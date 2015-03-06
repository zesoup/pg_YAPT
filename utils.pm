package utils;
use warnings;
use strict;
use 5.20.1;
use File::stat;
use File::Slurp;
use POSIX;

use Digest::MD5 qw(md5_hex);

use pg_dbi;
use Time::HiRes qw(usleep gettimeofday);

our $configFile;
our $config;

sub cacheConfig {
    open my $FH, ">", ".cache.pm";
    use Data::Dumper;
    $Data::Dumper::Deparse  = 1;
    $Data::Dumper::Purity   = 1;
    $Data::Dumper::Freezer  = sub { bless $_, ".."; };
    $Data::Dumper::Varname  = "config";
    $Data::Dumper::Sortkeys = sub {
        my $out = [];
        foreach ( keys %{ $_[0] } ) {
            unless ( $_ eq 'DB' ) { push( @{$out}, $_ ) }
        }
        return $out;
    };
    say $FH Dumper($config);
    close $FH;
    return 0;
}

sub widen {
    my ( $totalWidth, $text, $cnt, $extra, $char ) = @_;
    my $textwidth = length($text) + $extra;        #for |seperator
    my $widthper  = floor( $totalWidth / $cnt );

    my $out =
        fillwith( $char, floor( ( $widthper / 2 - $textwidth / 2 ) ) )
      . $text
      . fillwith( $char, ceil( ( $widthper / 2 - $textwidth / 2 ) ) );

    return $out;
}

sub fillwith {
    my ( $char, $len ) = @_;

    my $out = "";
    for ( my $i = 0 ; $i < $len ; $i++ ) {
        $out .= $char;
    }
    return $out;
}

sub getMD5ofFile{
my $file = shift;
open( my $FILE, $file );
    binmode($FILE);
    my $output =  Digest::MD5->new->addfile($FILE)->hexdigest ;
    close($FILE);
return $output;
}


sub reloadConf {
    my $configfile = shift;
    my $config1 = undef;

    if ( exists $config->{DB} ){$config->{DB}->{dbh}->disconnect;}
    eval( read_file($configfile) or die "could not read config" )
      or die "could not parse config";    

    if ($config1) {
        $config = $config1;
    }

    
    unless ( exists $config->{magicnumber}){
    $config->{magicnumber} = getMD5ofFile( $configfile );}
    
    $config->{DB} = pg_dbi::new( config => $config );

    foreach my $key ( keys %{ $config->{checks} } ) {
        require "plugins/" . $config->{checks}->{$key}->{plugin} . ".pm"
          or print "could not load $key";
    }

    foreach my $key ( keys %{ $config->{UI} } ) {
        require "UI/" . $key . ".pm"
          or print "could not load $key";
        bless( $config->{UI}->{$key}, $key );
    }

    foreach my $key ( keys %{ $config->{checks} } ) {

        bless( $config->{checks}->{$key}, $config->{checks}->{$key}->{plugin} );
        $config->{checks}->{$key}->{name}   = $key;
        $config->{checks}->{$key}->{config} = $config;
    }

#    $config->{UI}->{wall}->{hashsize} =
#      @{$config->{UI}->{wall}->{checks}};
    return $config;
}

sub checkAndReloadConfig {

    #while (1) {
    #    usleep 10000;
    open my $FH, "<", $configFile
      or return 1;    #It is possible that opening the config fails.
    if (   ( not exists $config->{age} )
        or ( stat($FH)->mtime != $config->{age} ) )
    {
        $config = reloadConf($configFile);
        $config->{age} = stat($FH)->mtime;
        close $FH;
        return 1;
    }
    close $FH;
    return 0;

    #  }
}

sub stampbegin{
my ($obj) = @_;
$obj->{initstamp}= gettimeofday();
return;
}

sub stampend{
my ($obj) = @_;
$obj->{endstamp} =  gettimeofday();
}

1;
