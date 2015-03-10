use warnings;
use strict;
use 5.20.1;

### BASIC CHECKS FOR DIFFERENT CONFIGS ###
my $testdir = "tests";
my $result  = "RESULT";
my $expect  = "EXPECTED";

#$result = $expect;
my $passed = 0;
my $failed = 0;
opendir( my $dh, $testdir ) || die;
while ( readdir $dh ) {
    if ( $_ =~ /^\.+/ )       { next; }
    if ( $_ =~ /\.EXPECTED/ ) { next; }
    if ( $_ =~ /\.RESULT/ )   { next; }
    print "TESTING $_";
`perl pg_YAPT.pl -o "loops=3 width=50" --config=$testdir/$_ 2>&1 > $testdir/$_.$result`;
    my $diff = `diff $testdir/$_.$result $testdir/$_.$expect`;
    if   ($diff) { say "[ ]Failed";$failed++; }
    else         { say "[X]Passed";$passed++; }
}
closedir $dh;

say "Testing all Checks:";

my @allChecks = split( "\n", `perl pg_YAPT.pl --config=$testdir/empty -l` );
my $skipline= 1;
my $type = "CHECK";

foreach (@allChecks) {
    if ( $skipline-- == 1  ) { next; }
    if ( $_ eq "" )     { say "Testing all UIs:";$type="UI";$skipline =1;next; }
    print $_.":";
    $_ =~ tr/"\///d;
if ($type eq "CHECK"){
`perl pg_YAPT.pl -o "loops=3 width=50" -a $_ --config=$testdir/empty 2>&1 > $testdir/$type.$_.$result`;}
if ($type eq "UI"){
`perl pg_YAPT.pl -o "loops=3 width=50" --config=$testdir/empty 2>&1 > $testdir/$type.$_.$result`;}

    my $diff = `diff $testdir/$type.$_.$result $testdir/$type.$_.$expect`;
    if   ($diff) { say "[ ]Failed"; $failed++;}
    else         { say "[X]Passed"; $passed++; }
}



say "---------------";
say "$failed failed";
say "$passed passed";
