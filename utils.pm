package utils;
use warnings;
use strict;
use 5.20.1;
use File::stat;
use File::Slurp;
use POSIX;
use Term::ANSIColor;

use Config::IniFiles;
use Digest::MD5 qw(md5_hex);
use Scalar::Util qw(looks_like_number);

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
    my ($UI) = @_;

    open my $FH, ">", $cacheFile;
    use Data::Dumper;

    #say STDERR Dumper($config->{checks});
    $Data::Dumper::Deepcopy = 1;
    my $cache = {};
    foreach my $check ( @{ $UI->{checks} } ) {
        $cache->{ $check->{identifier} }              = {};
        $cache->{ $check->{identifier} }->{metric}    = $check->{metric};
        $cache->{ $check->{identifier} }->{oldmetric} = $check->{oldmetric};
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
    $config->{cache} = $VAR1;
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

sub redirectSTDERR {
    my ($log) = @_;
    #say STDERR "Redirecting Log to $log";
    open my $log_fh, '>>', $log;
    *STDERR = $log_fh;
    binmode( STDERR, ":utf8" );
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

    eval( join( '', <$FH> ) )
      || ( ErrLog( "could not parse config", "UTILS", "FATAL" ) and exit 1 );
    close $FH;

    # did we just load a config or a cachefile?
    # cachefiles provide $config1
    # If it's not a cachefile, check-configurations need to be provided.
    # They reside within configs in the checks/ folder.
    # Load all of 'em.
    opendir my $checkdir,
      $checkDirectory || die "Can't open check-directory: $!\n";
    while ( my $f = readdir $checkdir ) {
        my $checks;
        if ( $f =~ /^\.+/ ) { next; }
        $checks = Config::IniFiles->new( -file => "$checkDirectory/$f" )
          or ( ErrLog( "cantLoad $f", "UTILS", "WARN" ) and next );
        foreach my $chk ( $checks->Sections() ) {
            $config->{checks}->{$chk} = {};
            foreach my $param ( $checks->Parameters($chk) ) {
                $config->{checks}->{$chk}->{$param} =
                  eval( $checks->val( $chk, $param ) )
                  or (
                    ErrLog(
                        "parsing $param for $chk failed: $@ ", "UTILS",
                        "WARN"
                    )
                    and next
                  );
            }
        }
    }
    closedir $checkdir;
    $config->{DB} = pg_dbi::new( config => $config );

   # for each check, load the required plugin.
   # abit messy but require shouldnt reload multiple times - we're fine for now.
    foreach my $key ( keys %{ $config->{checks} } ) {
        require "plugins/" . $config->{checks}->{$key}->{plugin} . ".pm"
          or ErrLog( "could not load $key", "UTILS", "WARN" );
    }

    # same for UIs.
    foreach my $key ( keys %{ $config->{UI} } ) {
        require "UI/" . $config->{UI}->{$key}->{template} . ".pm"
          or print "could not load $key";
        bless( $config->{UI}->{$key}, $config->{UI}->{$key}->{template} );
    }
    if ( exists $config->{log} ) {
        redirectSTDERR( $config->{log} );
    }

    return $config;
}

sub ensureCheck {
    my ($check) = @_;
    if ( ref $check eq "HASH" ) {
        $check = utils::checkfactory($check);
    }
}

sub checkfactory {
    my ($target)    = @_;
    my $targetcheck = $target->{check};
    my $targetclass = $config->{checks}->{$targetcheck}->{plugin};

    my $output = $targetclass->new($target);
    return $output;
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

sub formatter {
    my ( $val, $unit, $obj ) = @_;

    if (($config->{humanreadable}eq 0 ) or ($obj->{base}->{isHumanreadable}) ) { 
if ($unit eq "N"){$unit = '';}
return $val.$unit; }


    if ( $unit eq "N" ) {
        $unit = "";
        if ( (abs($val) >= 99)){
              $unit = 'K';
              $val /= 1000}
        if ( (abs($val) >= 99)){
              $unit = 'M';
              $val /= 1000}
    }

    unless ( defined $unit ) { $unit = "" }
    if ( $unit eq "B" ) {
        if ( abs($val) >= 99 ) {
            $val /= 1024;
            $unit = "KB";
        }
    }
    if ( $unit eq "KB" ) {
        if ( abs($val) >= 99 ) {
            $val /= 1024;
            $unit = "MB";
        }
    }
    if ( $unit eq "MB" ) {
        if ( abs($val) >= 1000 ) {
            $val /= 1024;
            $unit = "GB";
        }
    }

    return sprintf( "%.1f", $val ) . $unit;
}

sub checkTiming {
    my ($check) = @_;

    if (
        ( exists $config->{timing} )
        and ( ( $check->{endstamp} - $check->{initstamp} ) * 1000 >=
            $config->{timing} )
      )
    {
        utils::ErrLog(
            ceil( 1000 * ( $check->{endstamp} - $check->{initstamp} ) ) . "ms",
            $check->{identifier} . ' via UTILS',
            "INFO"
        );
    }
}

sub colorswitch {
    my ($clr) = @_;

    if ( $config->{color} eq 1 ) {
        return color($clr);
    }
    return "";
}

sub ErrLog {
    my ( $msg, $sender, $type ) = @_;
    my $logtypes = [ "FATAL", "WARN", "INFO", "debug" ];
    foreach ( @{$logtypes} ) {
        if ( $type eq $_ ) { last; }
        if ( ( exists $config->{loglevel} ) and ( $config->{loglevel} eq $_ ) )
        {
            return;
        }
    }
    say STDERR "[" . localtime . "] " . $type . " " . $sender . ":" . $msg;
    STDERR->flush();
}

1;
