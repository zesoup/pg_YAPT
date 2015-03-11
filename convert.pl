use Config::IniFiles;
use File::Slurp;
use Data::Dumper;
use 5.20.1;
my $checks;
eval( read_file("standardchecks.pm") );

say Dumper($checks);

my $cfg = Config::IniFiles->new( -file => "converted.ini" ) or die $_;

foreach my $sect ( keys $checks ) {
    $Data::Dumper::Deparse = 1;
    say $sect;
    $cfg->AddSection($sect);
    foreach my $attr ( keys $checks->{$sect} ) {

        my $line = Dumper( $checks->{$sect}->{$attr} );
        chomp $line;
        chomp $line;
        $line = substr( $line, 8, -1 );
        $line =~ s/\R//g;
        $cfg->newval( $sect, $attr, $line ) or say $_;

    }
}

$cfg->RewriteConfig();
