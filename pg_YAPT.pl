#! /usr/bin/env perl

use strict;
use warnings;
use 5.20.1;

# Set includepath to the local position. This Program will rely heavily on
# local files.
use File::Basename;
# Utils provide basic tools and utils. e.G Config-Handle.
use lib ( dirname $0); #wherever pg_YAPT is, thats where the includes are!
use utils;
$utils::checkDirectory = (dirname $0)."/checks"; #dirty for now


# Option Parser
use Getopt::Long;
use Getopt::Long::Descriptive;

# On Sighub, reload config and continue with thatever you did.


sub main {
    my $version = "0.0.4";

    #  Setup the argument parser.
    my ( $opt, $usage ) = describe_options(
        "Usage: pg_YAPT [opts]",
        [],
        [ 'ui|u=s',     "override the UI-choice from config.  ", {} ],
        [ 'list|l',     "list all checks and configured UIs",    {} ],
        [ 'uiopts|o=s', "UI-specific options to push down",      {} ],
        [ 'addcheck|a=s',"add these checks",{}                      ],
        [ 'dbopts|d=s',   "use this connectionstring",             {} ],
        [],
        [
            'deletecache|D',
            "delete cache. necessary if configs changed.",
            { default => 0 }
        ],
        [
            'reattachable|r',
            "reattach to existing cache. Speeds up diff-based checks",
            { default => 0 }
        ],
        [],
        [ 'config|c=s', "config to use",    { default => (dirname $0)."/config.pm" } ],
        [ 'cache|C=s',  "cacheFile to use", { default => (dirname $0)."/.cache.pm" } ],
        [],
        [
            'timing|t=i',
            "print checktimes longer X to stderr",
            { }
        ],
        [ 'test|T', "do not connect to the database", {} ],
        [ 'sync|S', "try to start on full seconds", {default=>0}    ],
        [ 'verbose|v', "print additional info. works good with list", {} ],
        [ 'veryverbose|V', "like verbose.. but worse (todo)",{}],
        [ 'help|h',    "print usage message and exit" ],
    );
    print( $usage->text ), exit if $opt->help;
    say "pg_YAPT V$version" if $opt->{verbose};
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
        $utils::cacheFile = $opt->{cache};
        utils::loadCache();
        $utils::config->{Reattachable} = 1;
    }
    if ($opt->{test}){$utils::config->{tests} = 1;};
    if (exists $opt->{dbopts}){$utils::config->{database}->{connection}=$opt->{dbopts}}
    # config is now loaded. check if there's an override for the UI.
    # If not, reset the $opt->{ui} value with the default.
    if ( $opt->{list} ) {
        say "Existing checks:";
        foreach ( sort keys %{ $utils::config->{checks} } ) {
            my $doc = "-/-";
            my $out = $_;
            if ( exists $utils::config->{checks}->{$_}->{doc} ) {
                $doc = $utils::config->{checks}->{$_}->{doc};
            }
            if ( $opt->{verbose} ) {
                $out = "["
                  . $utils::config->{checks}->{$_}->{plugin} . "]"
                  . utils::fillwith( " ",
                    11 - length( $utils::config->{checks}->{$_}->{plugin} ) )
                  . $out
                  . utils::fillwith( " ", 9 - length($out) ) . ": "
                  . $doc;
            }

            say "" . $out;
        }
        say "";
    }
    unless ( exists $opt->{ui} ) { $opt->{ui} = $utils::config->{defaultui}; }
    if ( exists $opt->{timing} ) { $utils::config->{timing} = $opt->{timing};}
    if ( exists $opt->{sync} ) { $utils::config->{sync}   = $opt->{sync};  }
    # Now check if the requested UI actually exists.
    if ( !exists $utils::config->{UI}->{ $opt->{ui} } ) {
        utils::ErrLog( "Unknown UI:" . $opt->{ui}, "main", "FATAL" );
    }

    # If the UI dosnt exist, OR if we're asked to list all possible UIs
    # print all UIs.
    if (   ( !exists $utils::config->{UI}->{ $opt->{ui} } )
        or ( $opt->{list} ) )
    {
        say "Existing UIs:";
        foreach ( sort keys %{ $utils::config->{UI} } ) {
            my $line = $_;
            if ( $opt->{verbose} and ($utils::config->{defaultui} eq $_ )) {
                $line = "*" . $line;
            }
            elsif ($opt->{verbose}) { $line = ' ' . $line }
            if ( $opt->{verbose} ) {
                $line = "["
                  . $utils::config->{UI}->{$_}->{template} . "]"
                  . utils::fillwith( " ",
                    5 - length( $utils::config->{UI}->{$_}->{template} ) )
                  . $line;
            }
            say $line ;
        }
        exit(0);
    }
    if(exists $opt->{addcheck}){
    my $newchecks = eval('['.$opt->{addcheck}.']');
    push (@{$utils::config->{UI}->{$opt->{ui}}->{checks}}, eval($opt->{addcheck}) );}
    #use Data::Dumper; say Dumper($utils::config->{UI}->{$opt->{ui}}->{checks} );
    ##### LOOP #####
    # Everyting is set.
    # While the requested UI asks to continue, loop over it.
    # when done - exit.
    while ( $utils::config->{UI}->{ $opt->{ui} }
        ->loop( $utils::config, $opt->{ui}, $opt->{uiopts} ) eq "continue" )
    {
        utils::ErrLog "ui terminated but asks for a restart", "main", "INFO";
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
