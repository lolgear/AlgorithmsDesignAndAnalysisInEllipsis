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