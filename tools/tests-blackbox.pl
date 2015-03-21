use warnings;
use strict;
use 5.20.1;

### BASIC CHECKS FOR DIFFERENT CONFIGS ###
my $testdir = "tests";
my $result  = "RESULT";
my $expect  = "EXPECTED";
my $yapt = "perl ../pg_YAPT.pl";

$result = $expect;


my $passed = 0;
my $failed = 0;
opendir( my $dh, $testdir ) || die;
say "Testing all Configs:";
while ( readdir $dh ) {
    if ( $_ =~ /^\.+/ )       { next; }
    if ( $_ =~ /\.EXPECTED/ ) { next; }
    if ( $_ =~ /\.RESULT/ )   { next; }

    #    print "TESTING $_";
`$yapt -o "loops=3 width=50" --config=$testdir/$_ 2>&1 > $testdir/$_.$result`;
    if ($?) { die "error with conf $_"; }
    my $diff = `diff $testdir/$_.$result $testdir/$_.$expect`;
    if   ($?) { say "[ ] $_ Failed"; $failed++; }
    else      { say "[X] $_ Passed"; $passed++; }
}
closedir $dh;

say "Testing all Checks:";

my @allChecks =
  split( "\n", `$yapt --config=$testdir/config.pm -l 2>>/dev/null` );
my $skipline = 1;
my $type     = "CHECK";

foreach (@allChecks) {
    if ( $skipline-- == 1 ) { next; }
    if ( $_ eq "" ) {
        say "Testing all UIs:";
        $type     = "UI";
        $skipline = 1;
        next;
    }

    #   print $_.":";
    
    my $raw = $_;
    $_ =~ tr/"\///d;
     
    if ( $type eq "CHECK" ) {
`$yapt -o "loops=3 width=50" -a "{check=>'$raw'}" --config=$testdir/config.pm 2>&1 > $testdir/$type.$_.$result`;
#if ($?) { die "error $raw"; }
   }

    if ( $type eq "UI" ) {
`$yapt -o "loops=3 width=50" -u "$raw"  --config=$testdir/config.pm 2>&1 > $testdir/$type.$_.$result`;
#if ($?) { die "error $raw"; }
    }

    #if ($?) { die "error $raw"; }
    my $diff = `diff $testdir/$type.$_.$result $testdir/$type.$_.$expect`;
    if   ($?) { say "[ ] $raw Failed "; $failed++; }
    else      { say "[X] $raw Passed";  $passed++; }
}

say "---------------";
say "$failed failed";
say "$passed passed";
