package SortedArray;
use Moose;
use Data::Dumper;

our $defaultFirstIndex = 0;
our $defaultOrder = 1;
has 'array' => (is => 'rw', isa => 'ArrayRef');

# order: ascending -> 1, descending -> -1
has 'order' => (is => 'rw', isa => 'Int');
has 'first_index' => (is => 'rw', isa => 'Int');
# ------- Setup/Init ------- #
sub defaultSetup {
	my $self = shift;
	# ascending order as default
	unless (defined $self->order) {
		$self->order($defaultOrder);
	}
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
	if (exists $params->{order}){
		$self->order($params->{order});
	}
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
sub arrayAsArray{
	my $self = shift;
	return @{$self->arrayAsArrayRef()};
}
sub arrayAsArrayRef{
	my $self = shift;
	return $self->array;
}
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

sub isArrayEmpty{
	my $self = shift;
	return $self->countOfElements == 0;
}

sub isPositionAvailable{
	my $self = shift;
	my $position = shift;
	# initial position is 1
	return  ($position >= $self->indexOfFirstElement() )&& 
		   	($position <= $self->indexOfLastElement()  );
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
	if ($position == $self->indexOfFirstElement()){
		$self->array([$element, @$array]);
	}
	if ($position == $self->indexOfLastElement()){
		$self->array([@$array, $element]);
	}
	else {
		$self->array(
			[
				@$array[$self->indexOfFirstElement() .. $position], 
				$element ,
				@$array[$position+1 .. $self->indexOfLastElement()] 
			]);
	}
	return 1;
}

# ----- Lookup Methods ----- #
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
	print "$lower and $upper\n";
	while ($lower <= $upper) {
		$middle = int(($lower + $upper)/2);
		print "middle now: $middle\n";
		# here we must choose, 
		if ($element > $array->[$middle]){
			print "bigger!";
			$self->order == 1  and $lower = $middle + 1;
			$self->order == -1 and $upper = $middle - 1;
		}
		elsif ($element < $array->[$middle]){
			$self->order == 1  and $upper = $middle - 1;
			$self->order == -1 and $lower = $middle + 1;
		}
		else {return $middle;}
		print "middle now: $middle\n";
	}
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
	# you must use order here
	if ($self->order == 1){
		#ascending order
		$position = $self->indexOfFirstElement();
	}
	elsif ($self->order == -1){
		#descending order
		$position = $self->indexOfLastElement();
	}
	else{
		return undef;
	}
	return $self->elementAtPosition($position);
}
sub ExtractMax{
	my $self = shift;
	my $position;
	if ($self->order == 1){
		#ascending order
		$position = $self->indexOfLastElement();
	}
	elsif ($self->order == -1){
		#descending order
		$position = $self->indexOfFirstElement();
	}
	else{
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
		print qq'this is position $position for element $element\n';
		# die "can't find position for element: $element in array: $self" ;
		# unless defined $position;
		$self->insertElementAtPosition($element,$position);
		}
}
# ---- Insert Methods ----- #
# ----- Say Methods ------- #
sub SayAboutArray{
	my $self = shift;
	print qq'Array have:\n';
	print qq' order: $self->{order}\n';
	print qq' first_index: $self->{first_index}\n';
}
sub SayAboutElements{
	my $self = shift;
	print Dumper($self->arrayAsArrayRef);
}
# end of class
1;