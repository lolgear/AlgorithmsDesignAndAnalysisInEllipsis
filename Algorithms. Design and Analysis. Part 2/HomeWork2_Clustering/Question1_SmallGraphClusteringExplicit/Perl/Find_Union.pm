package FindUnion;
use Moose;
use Data::Dumper;

has 'array' => (is => 'rw', isa => 'ArrayRef');
has 'leader' => (is => 'rw', isa => 'String');
has 'leaderName' => (is => 'rw', isa => 'String');

# -- this is union_find structure -- #
# -- this structure used for simple  #
# FIND function and simple UNION function #

# --------- Setup/Init Methods -------- #
sub defaultSetup{
	my ($self) = @_;
	unless (defined $self->leader){
		$self->leader = '';
	}

	unless (defined $self->leaderName){
		$self->leaderName = '';
	}
	unless (defined $self->array){
		$self->array = [];
	}
}

# --- STRUCTURE FAST PUBLIC METHODS --- #

sub FindElementLeader{
	my ($self,$element) = @_;
}

sub UnionTwoInstances{
	my ($self, $second) = @_;
}

sub AddElementToUnion{
	my ($self, $element) = @_;
	unless (defined $element->{'leader'}){
		$element->{'leader'} = $self->leader;
	}
	else{
		if ($element->{'leader'} ne $self->leader){
			# Union two unions

			# and update leader of union
		}
	}
}