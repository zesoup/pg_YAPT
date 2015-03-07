#! /usr/bin/env perl

use strict;
use warnings;
use 5.20.1;

# Set includepath to the local position. This Program will rely heavily on
# local files.
use FindBin;
use lib $FindBin::Bin;

# Utils provide basic tools and utils. e.G Config-Handle.
use utils;

# Option Parser
use Getopt::Long;
use Getopt::Long::Descriptive;

# On Sighub, reload config and continue with thatever you did.
$SIG{HUP} = sub { utils::checkAndReloadConfig(); return; };

sub main {

    # setup default values for opts.

    my ( $opt, $usage ) = describe_options(
        "Usage: pg_YAPT [opts]",
        [],
        [ 'ui|u=s',     "override the UI-choice from config.  ", {} ],
        [ 'listui|l',   "list all configured UIs",               {} ],
        [ 'uiopts|o=s', "UI-specific options to push down",      {} ],
        [],
        [
            'deletecache|d',
            "delete cache. necessary if configs changed.",
            { default => 0 }
        ],
        [
            'reattachable|r',
            "reattach to existing cache. Speeds up diff-based checks",
            { default => 0 }
        ],
        [],
        [ 'config|c=s', "config to use",    { default => "config.pm" } ],
        [ 'cache|C=s',  "cacheFile to use", { default => ".cache.pm" } ],
        [],
        [ 'verbose|v', "print extra stuff" ],
        [ 'help|h',    "print usage message and exit" ],
    );
    print( $usage->text ), exit if $opt->help;

    if ($opt->{deletecache}) {
               unlink $opt->{cache}; 
		}

    $utils::config     = undef;
    $utils::configFile = $opt->{config};
    utils::checkAndReloadConfig();
    if ($opt->{reattachable}) {
        $utils::configFile = $opt->{cache};
        utils::checkAndReloadConfig();

        $utils::configFile = $opt->{config};
        $utils::config->{Reattachable} = 1;
    }

    my $config = $utils::config;
    unless ( exists $opt->{ui} ) { $opt->{ui} = $utils::config->{defaultui}; }
    if ( !exists $config->{UI}->{ $opt->{ui} } ) {
        say STDERR "Unknown UI:" . $opt->{ui};
    }
    if ( ( !exists $config->{UI}->{ $opt->{ui} } ) or ( $opt->{listui} ) ) {
        print "Configured UIs: ";
        foreach ( keys %{ $config->{UI} } ) {
            print '' . $_ . ' ';
        }
        print "\nDefault: $config->{defaultui}";
        exit(1);
    }
    while ( $utils::config->{UI}->{ $opt->{ui} }
        ->loop( $utils::config, $opt->{ui}, $opt->{uiopts} ) eq "continue" )
    {
    }

    return 1;
}
unless (caller) {
    main;
}

sub asImport {
    @ARGV = @_;
    main;
}
