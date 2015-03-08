package utils;
use warnings;
use strict;
use 5.20.1;
use File::stat;
use File::Slurp;
use POSIX;

use Digest::MD5 qw(md5_hex);

use pg_dbi;
use Time::HiRes qw(usleep gettimeofday);

our $configFile;
our $config;
our $configAge;
our $testmode;

sub cacheConfig {
    open my $FH, ">", ".cache.pm";
    use Data::Dumper;
    $Data::Dumper::Deparse  = 1;
    $Data::Dumper::Purity   = 1;
    $Data::Dumper::Freezer  = sub { bless $_, ".."; };
    $Data::Dumper::Varname  = "config";
    $Data::Dumper::Sortkeys = sub {
        my $out = [];
        foreach ( keys %{ $_[0] } ) {
            unless ( $_ eq 'DB' ) { push( @{$out}, $_ ) }
        }
        return $out;
    };
    say $FH Dumper($config);
    close $FH;
    return 0;
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

    my $out =
        fillwith( $char, floor( ( $widthper / 2 - $textwidth / 2 ) ) )
      . $text
      . fillwith( $char, ceil( ( $widthper / 2 - $textwidth / 2 ) ) );

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

    # cachefiles will name the config differently. (namely $config1)
    my $config1 = undef;

    # a new configuration will be deployed, so if any db-connections exist,
    # remove them.
    if ( exists $config->{DB} ) { $config->{DB}->{dbh}->disconnect; }

    # read the configurationfile.(or cache for that matter)
    $configAge = localtime;
    eval( read_file($configfile) or die "could not read config" )
      or die "could not parse config";

    # did we just load a config or a cachefile?
    # cachefiles provide $config1
    if ($config1) {
        $config = $config1;
    }
    else {
        # If it's not a cachefile, check-configurations need to be provided.
        # They reside within configs in the checks/ folder.
        # Load all of 'em.
        opendir my $checkdir,
          "checks" || die "Can't open check-directory: $!\n";
        while ( my $f = readdir $checkdir ) {
            my $checks;
            if ( $f =~ /^\.+/ ) { next; }
            eval(
                read_file("checks/$f")
                  or die "could not read checks"
            ) or die "could not parse checks";
            $config->{checks} =
              $checks;    # Jep, it will break for multiple files. FIX
        }
        closedir $checkdir;
    }

    $config->{DB} = pg_dbi::new( config => $config );

   # for each check, load the required plugin.
   # abit messy but require shouldnt reload multiple times - we're fine for now.
    foreach my $key ( keys %{ $config->{checks} } ) {
        require "plugins/" . $config->{checks}->{$key}->{plugin} . ".pm"
          or print "could not load $key";

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
    say STDERR "[" . localtime . "]" . $type . " " . $sender . ":" . $msg;
}

1;
