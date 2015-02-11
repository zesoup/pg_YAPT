#! /usr/bin/env perl

use strict;
use warnings;
use File::Slurp;

use 5.20.1;

use FindBin;
use lib $FindBin::Bin;

use File::stat;

use Time::HiRes qw(usleep nanosleep);
use Term::ReadKey;
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

sub main {

### vv dirty, make sexy vv ###
    my $str = 'pg_dbi.pm';
    require $str;
    $str = 'boards/default.pm';
    require $str;

    my $configFile = "config.pm";

    my $config;

 # $config->{boards}->{default}->{instance} = default::new( config => $config );
### ^^-----------------^^  ###

    my $configAge = 0;
    my $i         = 0;
    while (1) {
        my ( $wchar, $hchar, $wpixels, $hpixels ) = GetTerminalSize();

        my $line = "\n";
        open my $FH, "<", $configFile or next;
        my $configTime = stat($FH)->mtime ;
        if ( $configTime != $configAge ) {
            $configAge = $configTime;
            $config    = reloadConf($configFile);
            $line .= widen($wchar, "New Config!", 1,0)."\n";

            #say "Config Changed! WTB reloadhook!";
        }
        close $FH;
        $config->{dbh}->{worsttime} = 0;
        unless ( ++$i % ($hchar-2) ) {
            for (
                my $i = 0 ;
                exists $config->{boards}->{default}->{checks}->{$i} ;
                $i++
              )
            {
                $line .= widen(
                    $wchar,
                    $config->{boards}->{default}->{checks}->{$i},
                    $config->{boards}->{default}->{hashsize}, 0
                );
            }
            $line .= "\n";
            $line .= fillwith( "+", $wchar ) . "\n";
        }
        for (
            my $i = 0 ;
            exists $config->{boards}->{default}->{checks}->{$i} ;
            $i++
          )
        {
            $line .= widen(
                $wchar,
                $config->{checks}
                  ->{ $config->{boards}->{default}->{checks}->{$i} }
                  ->{instance}->show(),
                $config->{boards}->{default}->{hashsize},
                0
            );
        }
        print $line;
	$|=1; 
   #. " | "
          #    . ( sprintf "%.2f", ( $config->{dbh}->{worsttime} / 1000000.0 ) )
          #     . "s";
       usleep $config->{updatetime};
    }

    return 1;
}

main;
