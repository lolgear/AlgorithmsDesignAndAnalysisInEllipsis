
use Data::Dumper;
use SortedArray;
#-------- Begin ----------#
my ($input) = @ARGV;
print "$input\n";
my $out = '>';
do {$output = "out.txt";
	$out.=$out;
} if defined $input;
$input ||= 'test_median_3.txt';
$output ||= 'output_median_test.txt';
open $fh, '<', $input or die qq'cant open $input! $!';
open $oh, $out, $output or die qq'cant open $output! $!';
# die "here!";
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

sub sayGood{
	print for map{chomp; $_."\n"}@_; 
}
sub sayToFile {
	for(@_){
		print;
		print{$oh}$_;	
	}
	print"\n";
	print{$oh}"\n";
}

# ---------- Main ---------- #

sub Main{
	my $heapLow = SortedArray->new;
	$heapLow->defaultSetup();
	my $heapHigh = SortedArray->new;
	$heapHigh->defaultSetup();

	my $median = readData($fh,$heapLow,$heapHigh);
	sayToFile "median is $median";
	sayToFile "Total time: ".(time() - $^T);
}
Main();
# ------- Data Input -------- #
sub readData {
	my $filehandler = shift;
	my ($heapLow, $heapHigh) = @_;
	my $differenceOfElements = 0;
	my $sum = 0;
	my $divisor = 10000;
	my $count = 0;
	while (<$fh>){		
		my $medianElement;
		chomp;
		# 	analyze element and put it in right heap
		if(defined($heapLow->MaxElement())&& ($heapLow->MaxElement() > $_)){
			# put in heapLow
			$heapLow->InsertElement($_);
			$differenceOfElements++;
		}
		elsif(defined($heapHigh->MinElement()) && ($heapHigh->MinElement() < $_)){
			# put in heapHigh
			$heapHigh->InsertElement($_);
			$differenceOfElements--;
		}
		else{
			# put anywhere, suppose, put into heapLow
			$heapLow->InsertElement($_);
			$differenceOfElements++;
		}

		# relaxation
		if (abs($differenceOfElements) > 1){
			# reorder now:
			if ($differenceOfElements > 0){
				# heapLow have more elements then heapHigh. Put it into heapHigh
				# extract element from heapLow (heapLow Max Element) and put it into heapHigh
				# nullify value of difference
				$heapHigh->InsertElement($heapLow->ExtractMax());
				$differenceOfElements = 0;
			}
			elsif ($differenceOfElements < 0){
				# heapHigh have more elements then heapLow. Put it into heapLow
				# extract element from heapHigh (heapHigh Min Element) and put it into heapLow
				# nullify value of difference
				$heapLow->InsertElement($heapHigh->ExtractMin());
				$differenceOfElements = 0;
			}
		}
		# more elements in heapLow, heapLow - heapHigh == 1
		# n = 2k+1, take from low.
		$medianElement = $heapLow->MaxElement() if $differenceOfElements == 1;
		# more elements in heapHigh, heapHigh - heapLow == 1
		# n = 2k+1, take from high.
		$medianElement = $heapHigh->MinElement() if $differenceOfElements == -1;
		# n = 2k, so, we must take k/2 statistics.
		# take from low
		$medianElement = $heapLow->MaxElement() if $differenceOfElements == 0;
		$sum = ComputeFinalValue($sum,$medianElement,$divisor);
		$count++;
		say "count: $count sum: $sum median: $medianElement";
	}
	return $sum;
}

# first, hash numbers as div 10000 
# so, next step is to compute all available sums for every basket?
# ------- Algorithm --------- #

sub ComputeFinalValue{
	my $sum = shift;
	my $new_median_k = shift;
	my $cut_value = shift;
	$sum+=$new_median_k;
	$sum %= $cut_value;
	return $sum;
}




# sub middleOfTheArray{
# 	my $array = shift;
# 	my $count = scalar@$array;
# 	return undef unless $count;
# 	my $median = $count%2?($count+1)/2 : $count/2;
# 	my $real = $median - 1;
# 	return $real;
# 	# for (1..200){
# 	# 	my $count = $_;
# 	# 	my $median = $_%2?($_+1)/2:$_/2; #int(($_+1)/2);
# 	# 	my $real = $median - 1;
# 	# 	sayGood "count of elements: $count", "Median is: $median", "I will take: $median - 1*${\($count%2)} = $real";
# 	# }
# }

# sub bisectionSearch{
# 	my $array = shift;
# 	my $element = shift;
# 	my $position = shift;

# }
# sub positionForElement{
# 	my $array = shift;
# 	my $element = shift;
# 	my $firstPosition = middleOfTheArray($array);
# 	return undef unless defined $firstPosition;
# 	return bisectionSearch($array,$element,$firstPosition);
# }
# sub insertElementAtPosition{
# 	my $array = [1..3, 5..6];
# 	my $first = -1;
# 	my $last  = 7;
# 	my $middle = 4;
# 	my $position = positionForElement($array, $first);
# }

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
