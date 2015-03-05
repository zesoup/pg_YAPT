#! /usr/bin/env perl

use strict;
use warnings;
use 5.20.1;

use FindBin;
use lib $FindBin::Bin;

use utils;

use Getopt::Long;

sub main {

    # setup my defaults
    my $UI           = "wall";
    my $UIopts	     = '';
    my $help         = 0;
    my $reattachable = 0;
    my $deletecache  = 0;

    my $configFile = "config.pm";
    my $cacheFile  = ".cache.pm";
    GetOptions(
	'uiopts=s'	=>\$UIopts,
        'ui=s'         => \$UI,
        'help!'        => \$help,
        'deletecache'  => \$deletecache,
        'reattachable' => \$reattachable
    ) or die "Incorrect usage!\n";
    if ($help) {
        print "This is help! It's part of the todo!\n";
        exit(0);
    }
    if ($deletecache) { unlink $cacheFile }

    $utils::config     = undef;
    $utils::configFile = $configFile;
    utils::checkAndReloadConfig();
    if ($reattachable) {
	my $configMagic = $utils::config->{magicnumber};
        $utils::configFile = $cacheFile;
        utils::checkAndReloadConfig();
        if ( $configMagic ne $utils::config->{magicnumber} )
        {die "Config and Cache Magics dont match!";}

        $utils::configFile = $configFile;
        $utils::config->{Reattachable} = 1;
    }

    my $config = $utils::config;

    unless ( exists $config->{UI}->{$UI} ) {
        say "Unknown UI!";
        print "Try: ";
        foreach ( keys %{ $config->{UI} } ) {
            print '"' . $_ . '" ';

        }
        exit(1);
    }
    while ($utils::config->{UI}->{$UI}->loop($utils::config) eq "continue"){};

    return 1;
}
unless (caller) {
    main;
}

sub asImport {
    @ARGV = @_;
    main;
}
