
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
package HeapSortedArray;
use Moose;
use Data::Dumper;

has 'heap' => (is => 'rw', isa => 'ArrayRef');
# has 'extract_function' => (is => 'rw', isa => 'CodeRef');

# descend = -1, ascend = 1
has 'order' =>(is => 'rw', isa => 'Int');


# ------------- Setup/Init --------------- #
sub defaultSetup{
	my $self = shift;	
	unless (defined $self->heap) {
		$self->heap([]);
	}

	unless (defined $self->order) {
		# default order - ascend
		$self->order(1); 
	}
}
sub setupHashTable{
	my $self = shift;
	my $params = shift;
	if (exists	$params->{order}){
		$self->order($params->{order});
	}
	$self->defaultSetup();
}

# ------------- Print Methods --------------- #

sub sayAboutHeap{
	# Heap Size and Min
}

sub sayAboutElements{

}

# ------- Data Manipulation Methods --------- #

# checker
sub isHeapIsEmpty{
	my $self = shift;
	return $self->countOfElementsInHeap() == 0;
}

# count of elements
sub countOfElementsInHeap{
	my $self = shift;
	return scalar @{$self->heap};
}

# element at position 
# return undef if position < 0 or position >= count of elements
sub elementAtPosition{
	my $self = shift;
	my $position = shift;
	return undef if ($position < 0 || $position >= $self->countOfElementsInHeap());
	return $self->heap->[$position];
}


# middle element in heap
sub middleElementInArray{
	my $self = shift;
	my $range = shift; # first and last values
	# no elements
	my $countOfElementsInArray = $range->[-1] - $range->[0] + 1;
	if ($countOfElementsInArray == 1){
		return $range->[0];
	}
	my $median =  $countOfElementsInArray   %2
				?($countOfElementsInArray+1)/2
				: $countOfElementsInArray   /2;
	$median += $range->[0];
	return $median - 1;
}

sub bisectionSearch{
	# recursive function
	my $self = shift;
	my $element = shift;
	my $array = shift;
	my $supposedPosition = shift;
	# take order
	
	# ascending order
	if ($self->order==1){
		if ($element > $self->elementAtPosition($supposedPosition)){
			# ascending order, so, right part of array
		}
		else{
			# ascenging order, so, left part of array
		}
	}

	# descending order
	if ($self->order==-1){
		if ($element > $self->elementAtPosition($supposedPosition)){
			# descending order, so, left part of array
		}
		else{
			# ascending order, so, right part of array
		}
	}
}

sub positionForElement{
	my $self = shift;
	my $element = shift;
	if ($self->isHeapIsEmpty()){
		return undef;
	}
	my $position = 
		$self->bisectionSearch(
			$element,
			$self->heap,
			$self->middleElementInArray(0,$self->countOfElementsInHeap())
			);
	# if first element to be insert
	return $position;
}

sub insertElementIntoHeap{
	my $self = shift;
	my $element = shift;
	my $position = shift;
	if ($self->isHeapIsEmpty()){
		$self->initWithFirstElement($element);
	}
	else{
	}
}

sub initWithFirstElement{
	my $self = shift;
	my $element = shift;
	$self->heap = [$element];
}

sub Insert{
	my $self = shift;
	my $element = shift;
	# if heap is empty, then, init heap with element
	if ($self->isHeapIsEmpty()){
		$self->initWithFirstElement($element);
	}
	else{
		# find position of element
		my $position = $self->positionForElement($element);	
		$self->insertElementIntoHeap($element,$position);
	}
}

sub Extract{
	my $self = shift;
	# ascending order
	if ($self->order == 1){
	}
	# descending order
	if ($self->order == -1){
	}
}

# end of class
1;