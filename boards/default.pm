use 5.20.1;

package default;

sub new{
my (%params) = @_;
my $self =  {config =>$params{config} };

bless ($self, __PACKAGE__);
return $self;

}

sub format{
use Data::Dumper;
say "k";
say Dumper(@_);
}

1;
