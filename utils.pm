package utils;

use warnings;
use strict;
use 5.20.1;
use File::Slurp;
use POSIX;

sub widen {
    my ( $totalWidth, $text, $cnt, $extra ) = @_;
    my $textwidth = length($text) + 1;             #for |seperator
    my $widthper  = floor( $totalWidth / $cnt );

    #if ($textwidth % 2){$textwidth++};
    #say floor($totalWidth/$cnt)-$textwidth ." ";
    #say(( ($totalWidth/$cnt)-$textwidth )/2.0 ). " ";
    my $out =
        fillwith( " ", floor( ( $widthper / 2 - $textwidth / 2 ) ) )
      . $text
      . fillwith( " ", ceil( ( $widthper / 2 - $textwidth / 2 ) ) ) . "|";

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

sub reloadConf {
    my $configfile = shift;
    my $config;
    eval( read_file($configfile) or die "could not read config" )
      or die "could not parse config";
    
    $config->{dbi} = pg_dbi::new( config => $config );
    foreach my $key ( keys %{ $config->{checks} } ) {
        require "plugins/" . $config->{checks}->{$key}->{plugin} . ".pm"
          or print "could not load $key";
    }

    foreach my $key ( keys %{ $config->{checks} } ) {
        $config->{checks}->{$key}->{instance} =
          bless( my $workaround = {}, $config->{checks}->{$key}->{plugin} )
          ->new( name => $key, config => $config );
    }

    $config->{boards}->{default}->{hashsize} =
      keys %{ $config->{boards}->{default}->{checks} };

    return $config;
}

1;
