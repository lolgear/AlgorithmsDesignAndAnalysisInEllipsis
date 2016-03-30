use Data::Dumper;
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

#-------- Begin ----------#
$,=",";
$"=",";

sub FilePreparation {
	my ($args) = shift;
	my ($input) = @$args;
	print "$input\n";
	my $out = '>';
	do {$output = "out.txt";
		$out.=$out;
	} if defined $input;
	$input ||= 'input.txt';
	$output ||= 'output.txt';
	open $fh, '<', $input or die qq'cant open $input! $!';
	open $oh, $out, $output or die qq'cant open $output! $!';
	($fh, $oh);
}

sub MainWork {
	my ($fh, $oh) = @_;
	my @data = 
	# <DATA>;
	<$fh>;
	my @data = map{chomp;$_}@data;
	my $outdata = PrepareSortAndCount(@data);
	say "my total inversion count is: ($outdata)";
	print {$oh} $outdata,"\n";
}

MainWork(FilePreparation(\@ARGV));

# my ($input,$output) = ('input.txt','output.txt');
# my ($fh,$oh);
# open $fh,  "<", $input;
# open $oh,  ">>",$output;
# my ($input) = @ARGV;
# print "$input\n";
# my $out = '>';
# do {$output = "out.txt";
# 	$out.=$out;
# } if defined $input;
# $input ||= 'input.txt';
# $output ||= 'output.txt';
# open $fh, '<', $input or die 'cant open $input! $!';
# open $oh, $out, $output or die 'cant open $output! $!';

# my @data = <$fh>;
# my @data = <DATA>;
# my @data = map{chomp;$_}@data;
# my $outdata = DummySortAndCount(@data);
# say "my total inversion count is: ", $outdata;
# print {$oh} $outdata,"\n";

#recursive

sub PrepareSortAndCount{
	my @array = @_;
	my $ref = \@array;

	DummySortAndCount(@array);
	# SortAndCount($ref, 0, $#array);
	# (MergeSortAndCountInversions($ref, scalar @array))[0];
}

sub MergeSortAndCountInversions {
	#take array
	my ($array, $n) = @_;
	# half of count of elements	
	my $half = round($n / 2);
	# say "!! half: $half !!";
	# say "!! n: $n !!";
	do{return (0, $array, $n);}if( ($n == 1) );
	my @leftArray = @{$array}[0..$half-1];
	my @rightArray = @{$array}[$half..$n-1];
	# say "in Main: 0..${\($n-1)} whole array: @$array";
	# say "in Main: 0..${\($half-1)} leftArray: @leftArray";
	# say "in Main: $half..${\($n-1)} rightArray: @rightArray"; 
	my ($leftCount, $leftArray, $leftSize) = MergeSortAndCountInversions(\@leftArray, $half);
	# say "still there!";
	my ($rightCount, $rightArray, $rightSize) = MergeSortAndCountInversions(\@rightArray, $n - $half);
	# say "start count! $leftCount and $rightCount";
	my ($splitCount, $mergedArray, $mergedSize) = MergeAndSplitAndCountInversions($leftArray, $leftSize, $rightArray, $rightSize);
	#return $leftCount + $rightCount + $splitCount;
	return ($leftCount + $rightCount + $splitCount, $mergedArray, $mergedSize)
}

sub MergeAndSplitAndCountInversions {
	my ($leftArray, $leftSize, $rightArray, $rightSize) = @_;
	
	#we have first part of array sorted and second part of array sorted
	my $n = ($leftSize + $rightSize);
	my @outputArray = ();
	my $leftIndex = 0;
	my $rightIndex = 0;
	my $inversionCount = 0;
	my @leftArray = @$leftArray;
	my @rightArray = @$rightArray;
	
	# say "in Split: leftCount:$leftSize leftArray: @leftArray";
	# say "in Split: rightCount:$rightSize rightArray: @rightArray"; 

	for (0..$n-1){

		# say "I compare this: <$leftArray[$leftIndex]> and this <$rightArray[$rightIndex]>";
		if ( ($rightArray[$rightIndex] > $leftArray[$leftIndex]) && defined($rightArray[$rightIndex]) ){
			# so, we have inversion, count this
			# say "and I am here with left $leftArray[$leftIndex]";
			if ( defined($leftArray[$leftIndex]) ){
				$outputArray[$_] = $leftArray[$leftIndex];				
				$leftIndex ++;
			}			
			else {
				$inversionCount = $inversionCount + ($leftSize - $leftIndex);
				$outputArray[$_] = $rightArray[$rightIndex];
				$rightIndex ++;
			}
		}
		else{
			# say "and I am here with right $rightArray[$rightIndex]";
			if ( defined($rightArray[$rightIndex]) ) {				
				$inversionCount = $inversionCount + ($leftSize - $leftIndex);
				$outputArray[$_] = $rightArray[$rightIndex];				
				$rightIndex ++;
			}
			else {
				$outputArray[$_] = $leftArray[$leftIndex];
				$leftIndex ++;
			}
		}

	}

	# say "count: $inversionCount with outputArray: @outputArray";
	return ($inversionCount, \@outputArray, $n);
}

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
	# say "leftArray: @leftArray";
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

sub round{
	sprintf('%u', shift);
}

sub SortAndCount{
	#take array
	my ($array,$firstIndex,$lastIndex) = @_;
	# half of count of elements
	my $n = round($lastIndex - $firstIndex + 1);
	my $half = round($n / 2);
	# say "!! half: $half !!";
	# say "!! n: $n !!";
	do{return 0;}if( ($n == 1) );
	my $leftCount = SortAndCount($array, 0, $half-1);
	# say "still there!";
	my $rightCount = SortAndCount($array, $half, $n-1);
	# say "start count! $leftCount and $rightCount";
	my $splitCount = SplitCount($array, $firstIndex, $lastIndex);
	return $leftCount + $rightCount + $splitCount;
}

sub SplitCount{
	# here we suppose, that we have two sorted arrays
	my ($array, $firstIndex, $lastIndex) = shift;
	#we have first part of array sorted and second part of array sorted
	my $n = round($lastIndex - $firstIndex + 1); #scalar{@$array};
	my $half = round($n / 2);
	my @leftArray = $array->[0..$half-1];
	my @rightArray = $array->[$half..$n-1];
	# my @outputArray = ();
	my $leftArrayCount = scalar @leftArray;
	my $leftIndex = 0;
	my $rightIndex = 0;
	my $inversionCount = 0;
	
	for my $index (1..$n){
		unless (defined($leftArray[$leftIndex]) or defined($rightArray[$rightIndex])) {
			next;
		}
		#say "I compare this: <$leftArray[$leftIndex]> and this <$rightArray[$rightIndex]>";
		if ($rightArray[$rightIndex] > $leftArray[$leftIndex] ){
			# so, we have inversion, count this
			
				# $outputArray[$index] = $leftArray[$leftIndex];
				#shift $leftArray;
				$leftIndex ++;
		}
		else{
				#say "catch for them  $leftArray[$leftIndex] > $rightArray[$rightIndex]";
					$inversionCount = $inversionCount + ($leftArrayCount - $leftIndex);
					# $outputArray[$index] = $rightArray[$rightIndex];
					#shift $rightArray;
					$rightIndex ++;
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