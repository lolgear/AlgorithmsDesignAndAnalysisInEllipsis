use Data::Dumper;
use HashTable;
use lib qq($ENV{HOME}/Documents/Projects/Perls/);
use LolgearTools qw(chmp say sayEvery sayToFile);
#-------- Begin ----------#
my ($input) = @ARGV;
print "$input\n";
my $out = '>';
do {$output = "out.txt";
	$out.=$out;
} if defined $input;
$input ||= 'input.txt';
$output ||= 'output.txt';
open $fh, '<', $input or die qq'cant open $input! $!';
open $oh, $out, $output or die qq'cant open $output! $!';

$,=",";
$"=":";

# ---------- Main ---------- #
sub Main{
	my ($inputFile,$outputFile) = @_;

	my ($array,$knapSackSize,$countOfItems) = readData($inputFile);
	# main algorithm
	# ok, now I must set knapsack algorithm with data
	$array = sortArrayInOrder($array);
	# say "I have array: ", Dumper $array;
	my $optimalSolution = KnapSackProblemAlgorithm($array,$knapSackSize,$countOfItems);
	# sayAboutTwoDHash($optimalSolution);
	say "knak: $knapSackSize; count: $countOfItems";
	sayToFile $outputFile, "I have optimal solution value", $optimalSolution->{"$countOfItems;$knapSackSize"};
}
Main($input,$output);

# ------- Correct Data ------ #
sub sortArrayInOrder{
	my ($array) = @_;
	return [sort{$a->{weight}<=>$b->{weight}}@$array];
}

# ------- Output Data ------- #
sub filterOnlyLeaders{
	my($graph) = @_;
	my $leaders = $graph->{leaders};
	return $leaders;
}

sub filterOnlyClusters{
	my ($graph) = @_;
	return $clusters;
}

# ------- Data Input -------- #
sub readData {
	my $array = []; # needed in algorithm for min computing
	my ($knapSackSize,$countOfItems) = ();
	my $inputFile = shift;
	open $fh, '<', $inputFile or die "can't open file on read! $inputFile! $!";
	while (<$fh>){
		last if ($_ eq qq'\n');
		next if ($_ =~ m/^[#]/);
		chomp;
		do{($knapSackSize,$countOfItems) = (split/\s+/); next} if $.==1;

		insertToArray($array,$_);
		say "I read $. !";
	}
	return ($array,$knapSackSize,$countOfItems);
}

sub createItem{
	my ($array,$itemValue,$itemWeight) = @_;
	push @$array, {value=>$itemValue, weight=>$itemWeight};
}

sub insertToArray{
	my ($array,$lineToBreak) = @_;
	$lineToBreak =~ s/\s+$//;
	my ($itemValue,$itemWeight) = (split/\s+/,$lineToBreak);
	createItem($array,$itemValue,$itemWeight);
}

# ------- Algorithm --------- #
=pod 
Let A = 2-D array
W - KnapSack Problem Size
w_i - weight of i item
v_i - value of i item
Initialize A[0; x] = 0 for x = 0 .. W
For i = 1 .. n
	For x = 0 .. W
A[i ; x] := max { A[i - 1; x] , A[i - 1; x - w_i ] + v_i }
Return A[n;W]

=cut 

sub sayAboutTwoDHash{
	my ($hash) = @_;
	my @keys = keys %$hash;
	my @sorted = 
	sort{$a->[0]<=>$b->[0]}
	sort{$a->[1]<=>$b->[1]}
	map{$_ = [(split/;/)]}
	@keys;

	for (@sorted){
		say "$_->[0];$_->[1]  =  ", $hash->{"$_->[0];$_->[1]"};
	}
}
sub sayAboutTwoDArray {
	my ($array) = @_;
	my @oneDArrays = @$array;
	for my $eachArray(@oneDArrays){
		for my $iterator(0..$#$eachArray){
			my $element = $eachArray->[$iterator];
			print "| $element |";
		}
		print "\n";
	}
}
sub max{
	my ($first,$last) = @_;
	return $first>$last?$first:$last;
}

sub sayTimer{
	my ($from, $total) = @_;
	say "current: $from  /  total: $total";
}

sub KnapSackSlicerHashTable{
	my ($array,$knapSackSize,$countOfItems) = @_;
	my $table = new HashTable();
	$table->setupHashTable({functions=>sub{
		my ($element) = @_;
		# I want full space hashtable
		my $prime = $knapSackSize;
		return abs($element)/$prime;
		} });
	$table->defaultSetup();

	my $startWeight = 0;
	my $arrayIndex = 0;
	my $currentItem = $array->[$arrayIndex];

	while ($startWeight<=$knapSackSize){
		# here we assume, that weights are different!
		if ($currentItem->{weight}<$startWeight){
			$arrayIndex++;
			$currentItem = $array->[$arrayIndex];
		}
		$table->addElement($currentItem->{value});
		$startWeight++;
	}
	return $table;
}

sub KnapSackProblemAlgorithm{
	my($array,$knapSackSize,$countOfItems) = @_;
	my %solution = ();

	my $helpTable = KnapSackSlicerHashTable($array,$knapSackSize,$countOfItems);

	# $solution{"0;$_"} = 0 for (0 .. $knapSackSize);
	my $firstRow = [(0)x(0..$knapSackSize)];
	my $secondRow = [(0)x(0..$knapSackSize)];
	# ok, now we want to do things like this:
	# array will be sorted by weight in ascending order.
	# so, if problem i doesnt' fit, that means, that w_i < w_{i+1} does not fit too
	# and also, weight will be go downward.
	# so, if weight does not fit, that means, it does not fit all others.

	#step one: secondRow fill with first element.
	for my $itemID(1 .. 1){
		my $currentItem = $array->[0];

		my $startWeightIndex = $array->{weight};
		for my $currentWeight ($startWeightIndex .. $knapSackSize){
			my $weightIfItemChosen = $currentWeight - $currentItem->{weight};
			if ($currentWeight < )
			my $valueIfItemChosen = $firstRow->[] + $currentItem->{value};
			my $valueIfItem
		}
	}

	for my $itemID(1 .. $countOfItems){
		# first, choose my index:
		my $arrayIndex = $itemID - 1;
		my $previousIndex = $itemID - 1;
		# choose currentItem
		my $currentItem = $array->[$arrayIndex];
		# choose start weight for currentItem
		my $startWeightIndex = $currentItem->{weight};
		# timer, hah
		sayTimer($itemID,$countOfItems);
		for my $currentWeight ($startWeightIndex .. $knapSackSize) {
			my $weightIfItemChosen = $currentWeight - $currentItem->{weight};
			my $weightIfItemNotChosen = $currentWeight;
			my $valueIfItemChosen = $firstRow->[];
			# my $valueIfItemChosen = $solution{"$previousIndex;$weightIfItemChosen"} + $currentItem->{value};
			my $valueIfItemNotChosen = $solution{"$previousIndex;$weightIfItemNotChosen"};

			if ( ($itemID == $countOfItems) && ($currentWeight == $knapSackSize) ){
				sayEvery "weight chosen: $weightIfItemChosen ","weight not chosen: $weightIfItemNotChosen ",
				"value chosen: $valueIfItemChosen", "value not chosen: $valueIfItemNotChosen";
			}
			$solution{"$itemID;$currentWeight"} = max($valueIfItemChosen,$valueIfItemNotChosen);
		}

	}
	return \%solution;
}
