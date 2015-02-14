package utils;
use warnings;
use strict;
use 5.20.1;
use File::stat;
use File::Slurp;
use POSIX;
use pg_dbi;
use Time::HiRes qw(usleep);

our $config;
our $configFile;

sub widen {
    my ( $totalWidth, $text, $cnt, $extra, $char ) = @_;
    unless ($text) { $text = "n/a"; }
    my $textwidth = length($text) + $extra;        #for |seperator
    my $widthper  = floor( $totalWidth / $cnt );

    #if ($textwidth % 2){$textwidth++};
    #say floor($totalWidth/$cnt)-$textwidth ." ";
    #say(( ($totalWidth/$cnt)-$textwidth )/2.0 ). " ";
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

    $config->{UI}->{wall}->{hashsize} =
      keys %{ $config->{UI}->{wall}->{checks} };

    return $config;
}

sub checkAndReloadConfig {
    while (1) {
        usleep 10000;
        open my $FH, "<", $configFile
          or next;    #It is possible that opening the config fails.
                      # Busy waiting!
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
    }
}

1;
