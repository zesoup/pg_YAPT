use strict;
use warnings;
use 5.20.1;

package thetime;
use POSIX;
sub new{
my ($name, %params) = @_;
my $self = {config => $params{config} };

bless ($self, __PACKAGE__);
return $self;


}
sub show{
#my $conf = shift;
my $pack = __PACKAGE__;
# @_[0]->{config}->{checks}->{$pack}->{timeout} );
#@_[0]->{age} = localtime;
my $now_string = strftime "%H:%M:%S", localtime;
return "".$now_string; 
}



1;
