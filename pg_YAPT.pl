#! /usr/bin/env perl

use strict;
use warnings;
use 5.20.1;

use FindBin;
use lib $FindBin::Bin;

use utils;

sub main {
    $utils::config     = undef;
    $utils::configFile = "config.pm";

    utils::checkAndReloadConfig();
    my $config = $utils::config;

    #use Data::Dumper;
    #say Dumper($config);
    require "boards/wall.pm";

    bless( $config->{boards}->{wall}, "wall" );
    $config->{boards}->{wall}->loop($config);

    return 1;
}

main;
