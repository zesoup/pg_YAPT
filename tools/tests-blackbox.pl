use warnings;
use strict;
use 5.20.1;

### BASIC CHECKS FOR DIFFERENT CONFIGS ###
my $testdir = "tests";
my $result  = "RESULT";
my $expect  = "EXPECTED";
my $yapt = "perl ../pg_YAPT.pl";

#$result = $expect;


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

my $checklist = [];
my $uilist= [];
foreach (@allChecks) {
    if ( $skipline-- == 1 ) { next; }
    if ( $_ eq "" ) {
        say "Testing all UIs:";
        $type     = "UI";
        $skipline = 1;
        next;
    }    
    my $raw = $_;
    $_ =~ tr/"\///d;
     
    if ( $type eq "CHECK" ) {
push($checklist, $raw);
   }

    if ( $type eq "UI" ) {
push($uilist, $raw);
}
}
foreach my $UI(@{$uilist}){
foreach my $CHECK(@{$checklist}){
#say $UI." ".$CHECK;
my $checkstr = $CHECK;
$checkstr =~ tr/"\///d;
`$yapt -o "header loops=3 width=50" -u "$UI" -a "{check=>'$CHECK'}"  --config=$testdir/config.pm 2>&1 > $testdir/MIX.$UI.$checkstr.$result`;
#if ($?) { die "error $UI.$CHECK:".$?; }
    my $diff = `diff $testdir/MIX.$UI.$checkstr.$result $testdir/MIX.$UI.$checkstr.$expect`;
    if   ($?) { say "[ ] $UI.$checkstr Failed "; $failed++; }
    else      { say "[X] $UI.$checkstr Passed";  $passed++; }

};
};
say "---------------";
say "$failed failed";
say "$passed passed";
