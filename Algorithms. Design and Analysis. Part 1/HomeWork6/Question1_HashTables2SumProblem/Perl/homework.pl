
use Data::Dumper;
use HashTable;
#-------- Begin ----------#
my ($input) = @ARGV;
print "$input\n";
my $out = '>';
do {$output = "out.txt";
	$out.=$out;
} if defined $input;
$input ||= 'input_sum.txt';
$output ||= 'output_sum.txt';
open $fh, '<', $input or die 'cant open $input! $!';
open $oh, $out, $output or die 'cant open $output! $!';
use Data::Dumper;
$,=",";
$"=":";
#-------- Functions ------#
sub chmp{
	for (@_){
		s/^\s+//;
		s/\s+$//;
	}
	return @_;
}
sub say{
	for(@_){
		print;
	}
	print "\n";
}
sub sayToFile {
	for(@_){
		print;
		print{$oh}$_;	
	}
	print"\n";
	print{$oh}"\n";
}

sub sayGhost{
	print Dumper @_;
	return @_;
}

# ---------- Main ---------- #

sub Main{
	my $border = 10000;
	my $rangeOfData = [-$border..$border];
	my $hashTableParameters = {
		buckets_count => 100,
		functions_count => 5,
		no_repetitions => 1,
		functions => [sub{
			my $element = shift;
			return int(abs($element)/$border);
		}]
	};
	my $hashTable = HashTable->new;
	$hashTable->setupHashTable($hashTableParameters);
	say "start reading";
	readData($fh, $hashTable);
	say "finish reading";
	# perform algorithm
	say "start computing";
	my $sums = TwoSumAlgorithm($hashTable,$rangeOfData);
	say "finish computing";
	sayToFile "sums that meeted: @$sums";
	sayToFile "count of sums: ".scalar(@$sums);
	sayToFile "Total Time is: ".(time - $^T)."s";
}
Main();
# ------- Data Input -------- #
sub readData {
	my $filehandler = shift;
	my $hashTable = shift;
	# my @alls = ();
	# my %unqs = ();
	while (<$fh>){
		chomp;
		# say $_;
		# last if $.==1000;
		# $alls[@alls] = $_;
		$hashTable->addElement($_);
		# $unqs{$_}++;
	}
	# say "count of alls: ",scalar(@alls);
	# say "count of unqs: ",scalar(keys %unqs);
	# @alls = ();
	# %unqs = ();
}

# first, hash numbers as div 10000 
# so, next step is to compute all available sums for every basket?
# ------- Algorithm --------- #

sub uniqueElements{
	my $array = shift;
	my $hash = {};
	for (@$array){
		$hash->{$_}++;
	}
	return [keys %$hash];
}
sub decartFunc{
	my $array = shift;
	my $func = shift;
	my $result = [];
	for my $first (@$array){
		push @$result, map{$func->($first,$_)}grep{$first!=$_}@$array;
	}
	return uniqueElements($result);
}

sub checkTwoBaskets{
	my $hashTable = shift;
	my $rangeOfData = shift;
	my ($current, $previous) = @_;
	my $result = [];
	# for every element in current basket
	# we must check: if element in previous basket will be here
	for my $currentElement(@{$hashTable->basketForIndex($current)}){
		for my $previousElement(@{$hashTable->basketForIndex($previous)}){
			my $sum = $currentElement + $previousElement;
			if ($sum ~~ $rangeOfData){
				push @$result, $sum;
				$hashTable->deleteElementFromArray($sum,$rangeOfData);
			}
		}
	}
	return $result;
}
sub TwoSumAlgorithm{
	my $hashTable = shift;
	my $rangeOfData = shift;
	my $index = 0;
	my $sums = [];
	$hashTable->sayAboutHashTable();
	$hashTable->sayAboutBaskets();
	# brilliant! good hashing!
	my $allSortedIndexesOfBaskets = [sort{$a<=>$b}@{$hashTable->indexesOfDefinedBaskets()}];
	my $all = scalar @$allSortedIndexesOfBaskets;
	say qq"alls is $all";
	# outer loop through all baskets
	# HERE
	my $previousAvailableIndexOfBasket;
	for my $availableIndexOfBasket(@$allSortedIndexesOfBaskets){
		# next loop through current basket and her elements
		# put basket elements
		my $countsOfElements = scalar @{$hashTable->basketForIndex($availableIndexOfBasket)};
		unless ($countsOfElements==1){
			# compute decart and destroy appearance in range
			my $decart = decartFunc($hashTable->basketForIndex($availableIndexOfBasket), sub{$_[0]+$_[1]});
			for my $elementInDecart(@$decart){
				if ($elementInDecart~~$rangeOfData){
					# say "I found sum: $elementInDecart";
					push @$sums, $elementInDecart;
					$hashTable->deleteElementFromArray($elementInDecart,$rangeOfData);
				}
			}
		}
		if (defined($previousAvailableIndexOfBasket) && (scalar (@$rangeOfData) > 0)) {
			if ($availableIndexOfBasket - $previousAvailableIndexOfBasket == 1){
				# say "I still have borders: $bordersOfData->[0], $bordersOfData->[-1]";
				# if they are closer to one, then, let's check them.
				my $result = checkTwoBaskets(
					$hashTable, 
					$rangeOfData,
					$availableIndexOfBasket, 
					$previousAvailableIndexOfBasket);
				if (scalar @$result > 0){
					push @$sums,@$result;
				}
			}
		}

		$index++;
		$previousAvailableIndexOfBasket = $availableIndexOfBasket;
		# say "remained time: ".int($index/$all * 100). '%';
	}
	# part two: find +-borders numbers
	# try to find borders (+- $border)
	# for my $availableIndexOfBasket (@$allSortedIndexesOfBaskets){

	# }
	return [sort{$a<=>$b}@$sums];
}