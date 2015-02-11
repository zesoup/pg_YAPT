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

use utils qw(widen fillwith reloadConf);

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
        my $configTime = stat($FH)->mtime;
        if ( $configTime != $configAge ) {
            $configAge = $configTime;
            $config    = utils::reloadConf($configFile);
            $line .= utils::widen( $wchar, "New Config!", 1, 0 ) . "\n";

            #say "Config Changed! WTB reloadhook!";
        }
        close $FH;
        $config->{dbh}->{worsttime} = 0;
        unless ( ++$i % ( $hchar - 2 ) ) {
            for (
                my $i = 0 ;
                exists $config->{boards}->{default}->{checks}->{$i} ;
                $i++
              )
            {
                $line .= utils::widen(
                    $wchar,
                    $config->{boards}->{default}->{checks}->{$i},
                    $config->{boards}->{default}->{hashsize}, 0
                );
            }
            $line .= "\n";
            $line .= utils::fillwith( "+", $wchar ) . "\n";
        }
        for (
            my $i = 0 ;
            exists $config->{boards}->{default}->{checks}->{$i} ;
            $i++
          )
        {
            $line .= utils::widen(
                $wchar,
                $config->{checks}
                  ->{ $config->{boards}->{default}->{checks}->{$i} }
                  ->{instance}->show(),
                $config->{boards}->{default}->{hashsize},
                0
            );
        }
        print $line;
        $| = 1;

        #. " | "
        #    . ( sprintf "%.2f", ( $config->{dbh}->{worsttime} / 1000000.0 ) )
        #     . "s";
        usleep $config->{updatetime};
    }

    return 1;
}

main;
