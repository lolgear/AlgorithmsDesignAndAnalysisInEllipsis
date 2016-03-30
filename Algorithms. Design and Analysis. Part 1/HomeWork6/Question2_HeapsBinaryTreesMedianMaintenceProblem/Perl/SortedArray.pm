package SortedArray;
use Moose;
use Data::Dumper;

our $defaultFirstIndex = 0;

has 'array' => (is => 'rw', isa => 'ArrayRef');
has 'first_index' => (is => 'rw', isa => 'Int');
# ------- Setup/Init ------- #
sub defaultSetup {
	my $self = shift;
	# empty array as default
	unless (defined $self->array){
		$self->array([]);
	}
	if (!defined($self->first_index) || $self->first_index < 0) {
		$self->first_index($defaultFirstIndex);
	}
}
sub setupArray {
	my $self = shift;
	my $params = shift;
	if (exists $params->{array}){
		$self->array($params->{array});
	}
	if (exists $params->{first_index}){
		$self->first_index($params->{first_index});
	}
	$self->defaultSetup();
}

sub initWithFirstElement{
	my $self = shift;
	my $element = shift;
	$self->array([$element]);
	$self->first_index($self->first_index||$defaultFirstIndex);
}
# ---- Data Manipulation --- # 
# ------- Accessors -------- # 
sub countOfElements{
	my $self = shift;
	return scalar @{$self->array};
}
sub indexOfFirstElement{
	my $self = shift;
	if ($self->isArrayEmpty()){
		return undef;
	}
	return $self->first_index || $defaultFirstIndex;
}
sub indexOfLastElement{
	my $self = shift;
	if ($self->isArrayEmpty()){
		return undef;
	}
	return $self->indexOfFirstElement() + $self->countOfElements() - 1;
}
sub elementAtPosition{
	my $self = shift;
	my $position = shift;
	return undef unless ($self->isPositionAvailable($position));
	return $self->{array}->[$position];
}
# ----- Check Methods ------ # 
sub isArraySorted{
	my $self = shift;
	if($self->isArrayEmpty){
		# if empty == -1 
		return -1;
	}
	my $index = 0;
	while ($index < $self->countOfElements() - 1){
		return 0 if ($self->elementAtPosition($index) > $self->elementAtPosition($index+1));
		$index++;
	}
	return 1;
}

sub isArrayEmpty{
	my $self = shift;
	return $self->countOfElements == 0;
}

sub isPositionAvailable{
	my $self = shift;
	my $position = shift;
	# initial position is 1
	return  ($position >= $self->indexOfFirstElement() )&& 
		   	($position <= $self->countOfElements()  );
}

sub isElementAtPositionExists {
	my $self = shift;
	my $position = shift;
	return undef unless ($self->isPositionAvailable($position));
	return defined ($self->elementAtPosition($position));
}


# ----- Insert Methods ----- #
sub insertElementAtPosition{
	my $self = shift;
	my $element = shift;
	my $position = shift;
	return undef unless $self->isPositionAvailable($position);
	# shift array and put element here
	my $array = $self->array;
	
	
	# if ($position == ($self->indexOfFirstElement() - 1)){
	# 	$self->array([$element, @$array]);
	# }
	# elsif ($position == ($self->indexOfLastElement() + 1)){
	# 	$self->array([@$array, $element]);
	# }
	# else{
		# print "pos: $position for el: $element\n";
		if ($position == ($self->indexOfLastElement() + 1)){
			$self->array([@$array, $element]);
			# @{$array}[-1] = $element;
		}
		else {
			# @{$self->array}[$position - 1] = $element;
			# splice ();
			# $a[$i] = $y;
			# splice(@a,$i,1,$y);
			splice (@$array,$position,0,$element);
			# @$array[$position - 1] = $element;
		# $self->array(
		# 	[
		# 		@$array[$self->indexOfFirstElement() .. $position - 1], 
		# 		$element ,
		# 		@$array[$position .. $self->indexOfLastElement()] 
		# 	]);
		# print "range is  $position and ".$self->indexOfLastElement();
		}
	# }
	return 1;
}

# ----- Lookup Methods ----- #
sub middle{
	my $self = shift;
	my ($left,$right) = @_;
	my $all = $right - $left;
	if ($all%2==0){
		return $all/2;
	}
	else{
		return ($all+1)/2;
	}
}
sub middleOfRange{
	my $self = shift;
	my $range = shift;
	my $count = $range->[-1] - $range->[0] + 1;
	if ($count == 1){
		return $range->[0];
	}
	else{
		my $median =    $count   %2
					  ?($count+1)/2
					  : $count   /2;
		return $median - 1;
	}
}

sub bisectionSearch{
	my $self = shift;
	my $array = shift;
	my $element = shift;
	my ($lower,$upper) = @_;
	my $middle; 
	# my @borders = ($lower,$upper);
	# @borders = reverse @borders if ($self->order == -1);
	# my $sign = $borders[0] - $borders[1]; # or $self->order;
	# if ($borders[0]==$borders[1]){
	# 	# return position for element, zero or one

	# }
	# while ($sign * ($borders[0] - $borders[1]) <= 0){
	# 	$middle = int($borders[0] + $borders[1]) / 2;
	# 	if ($element > $array->[$middle]){
	# 		# throw away left element
	# 		# if order == 1, then, put $middle+1 (update $lower bound)
	# 		# if order ==-1, then, put $middle-1 (update $upper bound)
	# 		shift @borders;
	# 		unshift @borders, $middle + $sign*1;
	# 	}
	# 	elsif ($element < $array->[$middle]){
	# 		pop @borders;
	# 		push @borders, $middle + $sign*(-1);
	# 	}
	# 	else{
	# 		return $middle;
	# 	}
	# }
	# return undef;
	
	my $b = 0;
	print "$lower and $upper for $element\n" if $b;
	
	while ($lower <= $upper) {
		print "$lower and $upper\n" if $b;
		$middle = int(($upper - $lower)/2) + $lower;
		print "middle now: $middle \n" if ($b);
		# here we must choose,
		print "$element >=< $array->[$middle]\n" if ($b);
		if ($element > $array->[$middle] && $middle == $upper){
			print "right I  return $middle\n" if $b;
			return $middle + 1;
		}
		if ($element < $array->[$middle] && $middle == $lower){
			print "left I return $middle\n" if $b;
			return $middle;
		}
		if ($element > $array->[$middle] && $element < $array->[$middle + 1]){
			print "middle right I return $middle\n" if $b;
			return $middle + 1;
		}
		if ($element > $array->[$middle - 1] && $element < $array->[$middle]){
			print "middle left I return $middle\n" if $b;
			return $middle;
		}
		if ($element > $array->[$middle]){
			 $lower = $middle + 1;
		}
		elsif ($element < $array->[$middle]){
			 $upper = $middle - 1;
		}
		else {return $middle;}
	}
	print "I return $middle\n" if $b;
	return $middle;
}

sub searchPositionForElement{
	my $self = shift;
	my $element = shift;
	my $position;
	# magic here, bisection
	$position = $self->bisectionSearch($self->array,$element,$self->indexOfFirstElement(),$self->indexOfLastElement());
	return $position;
}

# ----  Public Methods ----- #
# ---- Extract Methods ----- #
sub ExtractMin{
	my $self = shift;
	my $position;
	#ascending order
	$position = $self->indexOfFirstElement();
	unless (defined $position){
		return undef;
	}
	return shift @{$self->array};
}

sub ExtractMax{
	my $self = shift;
	my $position;
	#ascending order
	$position = $self->indexOfLastElement();
	unless (defined $position){
		return undef;
	}

	return pop @{$self->array};
}

sub MinElement{
	my $self = shift;
	my $position;
	#ascending order
	$position = $self->indexOfFirstElement();
	unless (defined $position){
		return undef;
	}
	return $self->elementAtPosition($position);
}

sub MaxElement{
	my $self = shift;
	my $position;
	#ascending order
	$position = $self->indexOfLastElement();
	unless (defined $position){
		return undef;
	}
	return $self->elementAtPosition($position);
}

# ---- Insert Methods ----- #
sub InsertElement{
	my $self = shift;
	my $element = shift;
	my $position = undef;
	if ($self->isArrayEmpty()){
		$self->initWithFirstElement($element);
	}
	else{
		$position = $self->searchPositionForElement($element);
		# print qq' this is position $position for element $element\n';
		# die "can't find position for element: $element in array: $self" ;
		# unless defined $position;
		$self->insertElementAtPosition($element,$position);
		# $self->SayAboutElements if ($element == 9290);
		}
}
# ----- Say Methods ------- #
sub SayAboutArray{
	my $self = shift;
	print qq'Array have:\n';
	print qq' first_index: $self->{first_index}\n';
}
sub SayAboutElements{
	my $self = shift;
	print Dumper($self->array);
}
sub SayAboutElementsInRow{
	my $self = shift;
	my @array = @{$self->array};
	print "count of @array: ", scalar@array;
	$, = ":";
	print qq(\[ @array \])."\n";
}

# end of class
1;