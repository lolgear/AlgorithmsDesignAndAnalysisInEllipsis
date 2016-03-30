
# http://en.wikipedia.org/wiki/List_of_prime_numbers
# Circular primes
# my primes for hashing
# 2, 3, 5, 7, 11, 13, 17, 
# 31, 37, 71, 73, 79, 97, 
# 113, 131, 197, 199, 311, 
# 337, 373, 719, 733, 919, 
# 971, 991, 1193, 1931, 3119, 
# 3779, 7793, 7937, 9311, 9377, 
# 11939, 19391, 19937, 37199, 39119, 
# 71993, 91193, 93719, 93911, 99371, 
# 193939, 199933, 319993, 331999, 391939, 
# 393919, 919393, 933199, 939193, 939391, 
# 993319, 999331

# this hash table use separate chaining
package HashTable;
use Moose;
use Data::Dumper;
has 'baskets_count' => (is => 'rw', isa => 'Int');
# has 'functions_count' => (is => 'rw', isa => 'Int');

has 'no_repetitions' => (is => 'rw', isa => 'Int');

has 'baskets' => (is => 'rw', isa => 'HashRef');
has 'functions' => (is => 'rw', isa => 'ArrayRef');
# ------------- Setup/Init --------------- #
sub defaultSetup{
	my $self = shift;
	
	unless ($self->baskets_count){
		$self->baskets_count(100);
	}

	# If I don't have hash functions, I will create only one functions
	unless ($self->functions){
		$self->functions([
			sub{
				my $element = shift;
				my $prime = 10000; # values changed from 0..9999
				return abs($element) / $prime;
			},
			]);
	}

	unless ($self->baskets){
		$self->baskets({});
	}

	unless (defined $self->no_repetitions){
		$self->{no_repetitions} = 0;
	}
	# unless ($self->functions_count){
	# 	$self->functions_count(5);
	# }
}
sub setupHashTable{
	my $self = shift;
	my $params = shift;
	if (exists $params->{baskets_count}){
		$self->baskets_count($params->{baskets_count});
	} 
	# if (exists $params->{functions_count}){
	# 	$self->functions_count($params->{functions_count});
	# } 
	if (exists $params->{functions}){
		$self->functions($params->{functions});
	}
	if (exists $params->{no_repetitions}){
		$self->no_repetitions($params->{no_repetitions});
	}
	$self->defaultSetup();
}

# ------------- Print Methods --------------- #
sub sayAboutHashTable{
	my $self = shift;
	print qq(this is hashTable.\n baskets_count:).
	$self->baskets_count."\n";
}

sub sayAboutBaskets{
	my $self = shift;
	print qq(this hashTableHaveBaskets\n);
	my $count = scalar keys %{$self->baskets};
	for (my $i = 0; $i < $count; ++$i){
		print "$i: \[ @{$self->{baskets}->{$i}} \] \n"if exists($self->baskets->{$i});
	}
}
# ------------ Hash Manipulation Methods ----- #
sub computePositionOfElement{
	my $self = shift;
	my $element = shift;
	my $position = undef;
	my $hashValues = [];
	for my $function(@{$self->functions}){
		push @$hashValues, $function->($element);
	}
	# get position after hash computed
	# I have only one function 
	$position = $hashValues->[0];	
	return $position;
}

sub putElementAtPosition{
	my $self = shift;
	my $element = shift;
	my $position = shift;
	# put position here instead of 0
	unless (exists $self->baskets->{$position}){
		$self->baskets->{$position} = [$element];
	}
	# array exists, we put it in front of list
	else{
		# if no_repetitions and element not in array, then add
		# if no_repetitions = 0, then add without check 
		my $needToInsert = $self->no_repetitions && ($element ~~ $self->baskets->{$position});

		unshift(@{$self->baskets->{$position}}, $element) unless ($needToInsert);
	}
}
sub lookupElementAtPosition {
	my $self = shift;
	my $element = shift;
	my $position = shift;
	my $result = undef;
	if ( $element ~~ $self->baskets->{$position} ){
		$result = $element;
	}
	return $result;
}

sub deleteElementFromArray{
	my $self = shift;
	my ($element,$array) = @_;
	my @indexes = grep {$array->[$_] ~~ $element}0..$#{$array};
	for my $index (@indexes){
		splice(@{$array}, $index,1);
	}
}

sub deleteElementAtPosition {
	my $self = shift;
	my $element = shift;
	my $position = shift;
	if ( $element ~~ $self->baskets->{$position} ){
		$self->deleteElementFromArray($element,$self->baskets->{$position});
	}
}

sub transformElement {
	my $self = shift;
	my $element = shift;
}

# ------------ Data Manipulation Methods ----- #
sub addElement{
	my $self = shift;
	my $element = shift;
	my $position = $self->computePositionOfElement($element);
	$self->putElementAtPosition($element,$position);
}

sub deleteElement{
	my $self = shift;
	my $element = shift;	
	my $position = $self->computePositionOfElement($element);
 	$self->deleteElementAtPosition($element,$position);
}

sub lookupElement{
	my $self = shift;
	my $element = shift;
	my $position = $self->computePositionOfElement($element);
	return defined $self->lookupElementAtPosition($element,$position);
}

sub elementForKey{
	my $self = shift;
	my $key = shift;
	# my $element = $self->lookupElementAtPosition($element,$key);
	return $element;
}

sub indexesOfDefinedBaskets{
	my $self = shift;
	my $allIndexes = [keys %{$self->baskets}];
	return $allIndexes;
}

sub basketForIndex{
	my $self = shift;
	my $index = shift;
	my $basket = undef;
	$basket = $self->baskets->{$index} if exists $self->baskets->{$index};
	return $basket;
}

sub indexesOfBasketsForIndexWithRange{
	my $self = shift;
	my $index = shift;
	my $range = shift;
	my $indexes = [];
	# ok, we need to take keys only in range of remaining sums
	for my $i(@$range){
		push @$indexes, $index + $i if exists $self->baskets->{$index + $i};
	}
	return $indexes;
}
# end of class
1;