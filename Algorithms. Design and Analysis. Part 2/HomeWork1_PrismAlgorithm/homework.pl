use Data::Dumper;
use lib qq($ENV{HOME}/Documents/Projects/Perls/);
use LolgearTools qw(chmp say sayEvery sayToFile);

use SortedArray;
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
