package utils;
use warnings;
use strict;
use 5.20.1;
use File::stat;
use File::Slurp;
use POSIX;

use Config::IniFiles;
use Digest::MD5 qw(md5_hex);

use pg_dbi;
use Time::HiRes qw(usleep gettimeofday);

our $configFile;
our $config;
our $configAge;

our $checkDirectory;

our $cacheFile;



our $testmode;
our $widenoverflow;


sub cacheChecks {
    open my $FH, ">", $cacheFile;
    use Data::Dumper;
    $Data::Dumper::Deepcopy = 1;
    my $cache = {};
    foreach my $check ( keys %{ $config->{checks} } ) {
        $cache->{$check} = {};
        $cache->{$check}->{metric} = $config->{checks}->{$check}->{metric};
        $cache->{$check}->{oldmetric} =
          $config->{checks}->{$check}->{oldmetric};
    }

    say $FH Dumper($cache);
    close $FH;
    return 0;
}

sub loadCache {
    my $VAR1;
    open( my $FH, "<", $cacheFile )
      || ( ErrLog( "could not read cache", "UTILS", "WARN" ) and return );
    eval( join( '', <$FH> ) )
      || ( ErrLog( "could not parse cache", "UTILS", "WARN" ) and return );
    close $FH;
    foreach my $check ( keys %{$VAR1} ) {
        $config->{checks}->{$check}->{metric}    = $VAR1->{$check}->{metric};
        $config->{checks}->{$check}->{oldmetric} = $VAR1->{$check}->{oldmetric};
    }
}

sub widen {

   # Textual function #
   # Given a lines width, a text and a number if equally distributed elements,
   # the function will figure out the space required for each element.
   # <------totalWidth*1Character------------->
   # |   text   |   n2   |   nx   |  .. |   nx   |
   # text will get widened via a filling character to match the requested width.

    my ( $totalWidth, $text, $cnt, $extra, $char ) = @_;
    my $textwidth = length($text) + $extra;        #for |seperator
    my $widthper  = floor( $totalWidth / $cnt );

    if ( defined $widenoverflow ) { $textwidth -= $widenoverflow; }

    my $widthLeft  = floor( $widthper / 2 - $textwidth / 2 );
    my $widthRight = ceil( $widthper / 2 - $textwidth / 2 );
    my $out =
      fillwith( $char, $widthLeft ) . $text . fillwith( $char, $widthRight );

    if ( defined $widenoverflow ) {
        $widenoverflow = $widthLeft + $widthRight;
        if ( $widenoverflow > 0 ) { $widenoverflow = 0 }
    }
    return $out;
}

sub fillwith {

    # Simply provide a string of $char*$len
    my ( $char, $len ) = @_;

    my $out = "";
    for ( my $i = 0 ; $i < $len ; $i++ ) {
        $out .= $char;
    }
    return $out;
}

sub storePID {
    open my $pidFH, ">", "pid";
    print $pidFH $$;
    close $pidFH;
}

sub removePID {
    unlink "pid";
}

sub getValueOfOptOrDefault {
    my ( $opts, $val, $default ) = @_;
    if ( ($opts) and ($val) and ( $opts =~ $val ) ) {
        my $start = index( $opts, $val ) + length($val);
        my $end = index( $opts, " ", $start );

        if ( $end < 0 ) { $end = 999 }
        return int( substr( $opts, $start, $end - $start ) );
    }
    return $default;
}

sub getMD5ofFile {

    # hash the content of a file.
    # magicnumbers are disabled - not used for now.
    my $file = shift;
    open( my $FILE, $file );
    binmode($FILE);
    my $output = Digest::MD5->new->addfile($FILE)->hexdigest;
    close($FILE);
    return $output;
}

sub reloadConf {
    my $configfile = shift;

    # a new configuration will be deployed, so if any db-connections exist,
    # remove them.
    if ( exists $config->{DB} ) { $config->{DB}->{dbh}->disconnect; }

    # read the configurationfile.
    $configAge = localtime;
    open( my $FH, "<", $configFile )
      || ( ErrLog( "could not read config", "UTILS", "FATAL" ) and exit 1 );

    eval( join( '', <$FH> ) ) || ( ErrLog( "could not parse config", "UTILS", "FATAL") and exit 1);
    close $FH;

    # did we just load a config or a cachefile?
    # cachefiles provide $config1
    # If it's not a cachefile, check-configurations need to be provided.
    # They reside within configs in the checks/ folder.
    # Load all of 'em.
    opendir my $checkdir, $checkDirectory || die "Can't open check-directory: $!\n";
    while ( my $f = readdir $checkdir ) {
        my $checks;
        if ( $f =~ /^\.+/ ) { next; }
        $checks = Config::IniFiles->new( -file => "$checkDirectory/$f" )
          or (ErrLog ("cantLoad $f","UTILS", "WARN")and next);
        foreach my $chk ( $checks->Sections() ) {
            $config->{checks}->{$chk} = {};
            foreach my $param ( $checks->Parameters($chk) ) {
                $config->{checks}->{$chk}->{$param} =
                  eval( $checks->val( $chk, $param ) )
                  or ( ErrLog( "parsing $param for $chk failed: $@ ","UTILS", "WARN") and next );
    }
        }
    }
    closedir $checkdir;
    $config->{DB} = pg_dbi::new( config => $config );

   # for each check, load the required plugin.
   # abit messy but require shouldnt reload multiple times - we're fine for now.
    foreach my $key ( keys %{ $config->{checks} } ) {
        require "plugins/" . $config->{checks}->{$key}->{plugin} . ".pm"
          or ErrLog ( "could not load $key", "UTILS", "WARN");

        bless( $config->{checks}->{$key}, $config->{checks}->{$key}->{plugin} );
        $config->{checks}->{$key}->{name}   = $key;
        $config->{checks}->{$key}->{config} = $config;
    }

    # same for UIs.
    foreach my $key ( keys %{ $config->{UI} } ) {
        require "UI/" . $config->{UI}->{$key}->{template} . ".pm"
          or print "could not load $key";
        bless( $config->{UI}->{$key}, $config->{UI}->{$key}->{template} );
    }

    return $config;
}

sub checkAndReloadConfig {
    open my $FH, "<", $configFile
      or return 1;    #It is possible that opening the config fails.
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

    #  }
}

sub stampbegin {
    my ($obj) = @_;
    $obj->{initstamp} = gettimeofday();
    return;
}

sub stampend {
    my ($obj) = @_;
    $obj->{endstamp} = gettimeofday();
}

sub ErrLog {
    my ( $msg, $sender, $type ) = @_;
    my $logtypes = ["FATAL","WARN","INFO","debug"];
    foreach ( @{$logtypes} ){
    if ($type eq $_){last;}
    if ((exists$config->{loglevel})and($config->{loglevel} eq $_)){return}
    };
    say STDERR "[" . localtime . "] " . $type . " " . $sender . ":" . $msg;
}

1;
