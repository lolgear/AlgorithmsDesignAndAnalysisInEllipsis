# ----- Modules ----- #
#use v5.16.0;
# ----- Common functions ----- #
sub say {
	for (@_){print; print "\n";}
}
sub qxx{
	my $what = shift;
	say qq(I will do $what);
	my $str = qx($what);
	if ($?){
		die "I fall down on < $what >\n! because of < $? >";
	}
	return $str;
}
sub chmp{
	for (@_){
		$_ =~ s/\s+&//;
		$_ =~ s/^\s+//;
	}
	return @_;
}


$" = ",";

# my ($input,$output) = ('input.txt','output.txt');
# my ($fh,$oh);
# open $fh,  "<", $input;
# open $oh,  ">>",$output;
my ($input) = @ARGV;
print "$input\n";
my $out = '>';
do {$output = "out.txt";
	$out.=$out;
} if defined $input;
$input ||= 'input.txt';
$output ||= 'output.txt';
open $fh, '<', $input or die 'cant open $input! $!';
open $oh, $out, $output or die 'cant open $output! $!';

my @data = <$fh>;
#my @data = <DATA>;
my @data = map{chomp;$_}@data;
my $outdata = DummySortAndCount(@data);
say "my total inversion count is: ", $outdata;
print {$oh} $outdata,"\n";

#recursive

sub DummySortAndCount{
	#take array
	my @array = @_;
	#and number of his elements
	my $n = scalar @array;
	# half of count of elements
	my $half = $n/2;
	#say "!! n = $n !!";
	do{return 0;}if($n==1);
	my $leftCount = DummySortAndCount(@array[0..$half-1]);
	my $rightCount = DummySortAndCount(@array[$half..$n-1]);
	my $splitCount = DummySplitCount(@array);
	#say "I will return: <".($rightCount+$leftCount+$splitCount).">";
	#say "for array: ", "@array";
	return $leftCount + $rightCount + $splitCount;

}
sub DummySplitCount{
		# here we suppose, that we have two sorted arrays
	my @array = @_;
	#we have first part of array sorted and second part of array sorted
	my $n = scalar @array;
	my $half = $n / 2;
	my @leftArray = @array[0..$half-1];
	my @leftArray = sort{$a<=>$b}@leftArray;
	my @rightArray = @array[$half..$n-1];
	my @rightArray = sort{$a<=>$b}@rightArray;
	my $leftIndex = 0;
	my $rightIndex = 0;
	my @outputArray = ();
	my $inversionCount = 0;
	for (1..$n){

		#say "I compare this: <$leftArray[$leftIndex]> and this <$rightArray[$rightIndex]>";
		if ($rightArray[$rightIndex] > $leftArray[$leftIndex] ){
			# so, we have inversion, count this
			if (defined($leftArray[$leftIndex]) and defined($rightArray[$rightIndex])){
				$outputArray[$_] = $leftArray[$leftIndex];
				#shift $leftArray;
				$leftIndex ++;
			}
		}
		else{
			if (defined($leftArray[$leftIndex]) and defined($rightArray[$rightIndex])){
				#say "catch for them  $leftArray[$leftIndex] > $rightArray[$rightIndex]";
					$inversionCount = $inversionCount + (scalar @leftArray - $leftIndex);
					$outputArray[$_] = $rightArray[$rightIndex];
					#shift $rightArray;
					$rightIndex ++;
				}
			}

	}
	return $inversionCount;
}


sub SortAndCount{
	#take array
	my ($array,$firstIndex,$lastIndex,$n) = @_;
	# half of count of elements
	my $half = $n/2;
	say "!! n = $n !!";
	return 0 unless($n-1);
	my $leftCount = SortAndCount($array,0,$half-1,$half);
	my $rightCount = SortAndCount($array,$half,$n-1,($n - $half));
	my $splitCount = SplitCount($array);
	return $leftCount + $rightCount + $splitCount;
}

sub SplitCount{
	# here we suppose, that we have two sorted arrays
	my $array = shift;
	#we have first part of array sorted and second part of array sorted
	my $n = scalar{@$array};
	my $half = $n / 2;
	my @leftArray = $array->[0..$half-1];
	my @rightArray = $array->[$half..$n-1];
	my $leftIndex = 0;
	my $rightIndex = 0;
	my $inversionCount = 0;
	for (1..$n){

		#say "I compare this: <$leftArray[$leftIndex]> and this <$rightArray[$rightIndex]>";
		if ($rightArray->[$rightIndex] > $leftArray->[$leftIndex] ){
			# so, we have inversion, count this
			if (defined($leftArray[$leftIndex]) and defined($rightArray[$rightIndex])){
				$outputArray[$_] = $leftArray[$leftIndex];
				#shift $leftArray;
				$leftIndex ++;
			}
		}
		else{
			if (defined($leftArray[$leftIndex]) and defined($rightArray[$rightIndex])){
				#say "catch for them  $leftArray[$leftIndex] > $rightArray[$rightIndex]";
					$inversionCount = $inversionCount + (scalar @leftArray - $leftIndex);
					$outputArray[$_] = $rightArray[$rightIndex];
					#shift $rightArray;
					$rightIndex ++;
				}
			}

	}
	return $inversionCount;

}

__DATA__
1
3
5
7
2
4
6