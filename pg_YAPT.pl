#! /usr/bin/env perl

use strict;
use warnings;
use 5.20.1;

use FindBin;
use lib $FindBin::Bin;

use utils;

use Getopt::Long;

# setup my defaults
my $UI   = "wall";
my $help = 0;

sub main {
    $utils::config     = undef;
    $utils::configFile = "config.pm";

    utils::checkAndReloadConfig();
    my $config = $utils::config;

    unless ( exists $config->{UI}->{$UI} ) {
        say "Unknown UI!";
        print "Try: ";
        foreach ( keys %{ $config->{UI} } ) {
            print '"' . $_ . '" ';

        }
        exit(1);
    }
    $config->{UI}->{$UI}->loop($config);

    return 1;
}

GetOptions(
    'ui=s'  => \$UI,
    'help!' => \$help,
) or die "Incorrect usage!\n";
if ($help) {
    print "This is help! It's part of the todo!\n";
    exit(0);
}

main;
