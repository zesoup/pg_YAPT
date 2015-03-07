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

    #  Setup the argument parser.
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

    # delete the cachefile if asked to
    # doesnt rely on the config, so we can do it very early on
    if ( $opt->{deletecache} ) {
        unlink $opt->{cache};
    }

    # now handle the Config.
    # reset the utils::config, set the targetfiles properly and force a reload.
    $utils::config     = undef;
    $utils::configFile = $opt->{config};
    utils::checkAndReloadConfig();

    # if we're asked to be reattachable reset the targetfile to cache and load again.
    # because the contents may be blessed, we need to load the defaultconfig first to make
    # sure all includes allready exist.
    #
    # once done, reset the targetfile again to provide proper reload-functionality on sighup.
    if ( $opt->{reattachable} ) {
        $utils::configFile = $opt->{cache};
        utils::checkAndReloadConfig();

        $utils::configFile = $opt->{config};
        $utils::config->{Reattachable} = 1;
    }
    # config is now loaded. check if there's an override for the UI.
    # If not, reset the $opt->{ui} value with the default.
    unless ( exists $opt->{ui} ) { $opt->{ui} = $utils::config->{defaultui}; }

    # Now check if the requested UI actually exists.
    if ( !exists $utils::config->{UI}->{ $opt->{ui} } ) {
        say STDERR "Unknown UI:" . $opt->{ui};
    }
    # If the UI dosnt exist, OR if we're asked to list all possible UIs
    # print all UIs.
    if (   ( !exists $utils::config->{UI}->{ $opt->{ui} } )
        or ( $opt->{listui} ) )
    {
        print "Configured UIs: ";
        foreach ( keys %{ $utils::config->{UI} } ) {
            print '' . $_ . ' ';
        }
        print "\nDefault: $utils::config->{defaultui}";
        exit(1);
    }

    ##### LOOP #####
    # Everyting is set.
    # While the requested UI asks to continue, loop over it.
    # when done - exit.
    while ( $utils::config->{UI}->{ $opt->{ui} }
        ->loop( $utils::config, $opt->{ui}, $opt->{uiopts} ) eq "continue" )
    {say STDERR "ui terminated but asks for a restart";
    }

    return 0;
}

# sometimes it's usefull to use this script as an include.
# if so, dont' run main straightaway but provide an import-function.
# this function can be tossed some args and will be mapped back to @ARGV.

unless (caller) {
    main;
}

sub asImport {
    @ARGV = @_;
    main;
}
