#! /usr/bin/env perl

use strict;
use warnings;
use 5.20.1;

use FindBin;
use lib $FindBin::Bin;

use File::stat;
use File::Slurp;
use Time::HiRes qw(usleep nanosleep);
use Term::ReadKey;
use POSIX;

use utils qw(widen fillwith reloadConf);

require 'pg_dbi.pm';


sub main {
    # Main Function


    my $configFile = "config.pm";
    my $config = undef;
    while (1) {
        my ( $wchar, $hchar, $wpixels, $hpixels ) = GetTerminalSize();

        my $line = "\n";
        open my $FH, "<", $configFile or next; #It is possible that opening the config fails.
						# Busy waiting!

        if ( stat($FH)->mtime != $config->{age} ) {
            $config    = utils::reloadConf($configFile);
            $config->{age} = stat($FH)->mtime;
            $line .= utils::widen( $wchar, "New Config!", 1, 0 ) . "\n";
        }
        close $FH;

        $config->{dbh}->{worsttime} = 0;
	unless ( exists $config->{main}->{i} ){$config->{main}->{i}=0;}
        unless ( ++ $config->{main}->{i} % ( $hchar - 2 ) ) {
            for (
                my $i = 0 ;
                exists $config->{boards}->{default}->{checks}->{$i} ;
                $config->{main}->{i}++
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
