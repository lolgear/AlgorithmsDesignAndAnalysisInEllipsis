# ----- Modules ----- #
#use v5.16.0;
use Data::Dumper;
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
$, = ",";


# -------- Main Part ---------- #
my ($input,$output) = ('input.txt','output.txt');
my ($fh,$oh);
open $fh,  "<", $input;
open $oh,  ">>",$output;
my @data = <$fh>;
# my @data = <DATA>;
my @data = map{chomp;$_}@data;
my $inc = 0;
my $arrayRef = \@data; 
#print "this is array:", @data,"\n";
# my $ref = \@data;
# my $p = ChoosePivot($ref,0,$#data);
#say "i choose: $data[0] | at position: $p";
#print "array after swap pivot: ",@data,"\n";
# my $q = PartitionMake($ref,0,$#data);
# say "middle element at position: $q"; 
# print "i do partition: ",@data,"\n";
# PutPivotBack($ref,$q);
# print "finnaly, I have: ",@data,"\n";
#print "this is new array:",@data,"\n";
#my @result = DummyQuickSort($inc,@data);
#say Dumper(@result);
#say "I have comparisons in count: ".$result[0];
#say "I have sorted array: ",@result;#[1..$#result];
#print {$oh} "count of comparisons in QuickSort: <$result[0]>\n";

 my $first = DummyQuickSort($arrayRef,0,$#data);
# my $second = DummyQuickSort($arrayRef,0,$#data);
#my $third = DummyQuickSort($arrayRef,0,$#data);
 say "I sort array and have count as MIDDLE-OF-THREE-PIVOT-ELEMENT: ".$first;
 # say "and array is: @$arrayRef";
#print{$oh} "I sort array and have count as FISRT-PIVOT-ELEMENT: ".$first."\n";
#print{$oh} "I sort array and have count as FINAL-PIVOT-ELEMENT: ";
#print{$oh} "I sort array and have count as MIDDLE-OF-THREE-PIVOT-ELEMENT";

# SortAll(@data);

sub Output{
	my ($array,$count,$string) = @_;
	my $line = "I sort array and have count as ".$string. " $count";
	say "sorted array is @$array";
	say $line;
	print{$oh} $line."\n";
}
sub SortAll{
	my @first_pivot_data = @_;
	my @final_pivot_data = @_;
	my @middle_of_three_pivot_data = @_;

	my $first  = \@first_pivot_data;
	my $final  = \@final_pivot_data;
	my $middle = \@middle_of_three_pivot_data;

	# say "before: @$first";
	# say "before: @$final";
	# say "before: @$middle";
	
	my $first_count = DummyQuickSortForFirst($first,0,$#{$first});
	# say "beforeF: @$first";
	# say "beforeFF: @$final";
	# say "beforeFFF: @$middle";
	my $final_count = DummyQuickSortForFinal($final,0,$#{$final});
	# say "beforeF: @$first";
	# say "beforeFF: @$final";
	# say "beforeFFF: @$middle";
	my $middle_count = DummyQuickSortForMiddle($middle,0,$#{$middle});
	Output($first,$first_count,"FIRST-PIVOT-ELEMENT: ");
	say "here!";
	Output($final,$final_count,"FINAL-PIVOT-ELEMENT: ");
	say "yes";
	Output($middle,$middle_count,"MIDDLE-OF-THREE-PIVOT-ELEMENT: ");
}

sub DummyQuickSortForMiddle{
	my ($array,$low,$high) = @_;
	return 0 if ($high - $low == 0);
	if ($low < $high){		
		# say "middle element at position: $q"; 
		# print "i do partition: ",@data,"\n";
		#really, this is like "pivot element"
		ChoosePivotAsMiddle($array,$low,$high);
		my $middleElement = PartitionMake($array,$low,$high);
		# lower 
		my $x = DummyQuickSort($array,$low,$middleElement - 1);
		my $y = DummyQuickSort($array,$middleElement + 1, $high);		
		# count of array
		return $high - $low + $x + $y;
	}	
}

sub DummyQuickSortForFinal{
	my ($array,$low,$high) = @_;
	return 0 if ($high - $low == 0);
	if ($low < $high){
		
		# say "middle element at position: $q"; 
		# print "i do partition: ",@data,"\n";
		#really, this is like "pivot element"
		ChoosePivotAsFinal($array,$low,$high);
		my $middleElement = PartitionMake($array,$low,$high);
		# lower 
		my $x = DummyQuickSort($array,$low,$middleElement - 1);
		my $y = DummyQuickSort($array,$middleElement + 1, $high);		
		# count of array
		return $high - $low + $x + $y;
	}	
}


sub DummyQuickSortForFirst{
	my ($array,$low,$high) = @_;
	return 0 if ($high - $low == 0);
	if ($low < $high){
		
		# say "middle element at position: $q"; 
		# print "i do partition: ",@data,"\n";
		#really, this is like "pivot element"
		ChoosePivotAsFirst($array,$low,$high);
		my $middleElement = PartitionMake($array,$low,$high);
		# lower 
		my $x = DummyQuickSort($array,$low,$middleElement - 1);
		my $y = DummyQuickSort($array,$middleElement + 1, $high);		
		# count of array
		return $high - $low + $x + $y;
	}	
}

sub DummyQuickSort{
	my ($array,$low,$high) = @_;
	return 0 if ($high - $low == 0);
	if ($low < $high){
		
		# say "middle element at position: $q"; 
		# print "i do partition: ",@data,"\n";
		#really, this is like "pivot element"
		ChoosePivot($array,$low,$high);
		my ($middleElement,$sum) = PartitionMake($array,$low,$high);
		# lower 
		my $x = DummyQuickSort($array,$low,$middleElement - 1);
		my $y = DummyQuickSort($array,$middleElement + 1, $high);		
		# count of array
		return $sum + $x + $y;
	}

}
# -------- Functions ---------- #
# sub DummyQuickSort{	
# 	#first, get array
# 	my $inc = shift;
# 	my @array = @_;
# 	#say "count of element: ".scalar(@array);
# 	return unless(scalar(@array));
# 	return @array if (scalar(@array)==1);
# 	my $pivot = ChoosePivot(\@array);
# 	my @left = grep{$_<$pivot}@array;
# 	my @right = grep{$_>$pivot}@array;
# 	$inc += scalar(@left) + scalar(@right);
# 	#say "I have pivot: ".$pivot;
# 	return 
# 		(DummyQuickSort($inc,@left),$pivot,DummyQuickSort($inc,@right));
# }


sub PutPivotBack{
	my ($array,$q) = @_;
	$array->[0] = "!".$array->[0]."!";
	@$array[0,$q] = @$array[$q,0];
}

sub ChoosePivotAsFinal{
	my ($array,$low,$high) = @_;
	my $pivotIndex = $low;
	@$array[$pivotIndex,$low] = @$array[$low,$pivotIndex];
	return $pivotIndex;	
}
sub ChoosePivotAsFirst{
	my ($array,$low,$high) = @_;
	my $pivotIndex = $high;
	@$array[$pivotIndex,$low] = @$array[$low,$pivotIndex];
	return $pivotIndex;
}

sub ChoosePivotAsMiddle{
	my ($array,$low,$high) = @_;
	my $pivotIndex = ($high - $low)/2;
	@$array[$pivotIndex,$low] = @$array[$low,$pivotIndex];
	return $pivotIndex;

}

sub choose_middle{
	my ($array,$l,$m,$h) = @_;
	my @ar = ($array->[$l],$array->[$m],$array->[$h]);
	@ar = sort{$a<=>$b}@ar;
	my $middle_elem = $ar[1];
	for my $i ($l,$m,$h){
		return $i if $middle_elem == $array->[$i];
	}
}
sub ChoosePivot{
	my ($array,$low,$high) = @_;

	#choose somehow index and rearrange array	
	#my $pivotIndex = $low;#int(rand($high)) + $low;
	my $pivotIndex;
	# first element: 
	# $pivotIndex = $low;
	# last element: 
	# $pivotIndex = $high;
	# median-of-three:
	$middle_index = int(($high - $low)/2) + $low;
	$pivotIndex = choose_middle($array,$low,$middle_index,$high);	

	#say "I take $low <$pivotIndex < $high in length ";
	#replace index with first element
	# say "this is before swap: @$array";
	@$array[$pivotIndex,$low] = @$array[$low,$pivotIndex];
	#return pivot index
	#say "this is after swap: @$array";
	return $pivotIndex;
	#nothing to return
}

sub PartitionMake{
	my ($array,$leftBound,$rightBound) = @_;
	my ($i, $j);	
	my $pivot = $array->[$leftBound];
	#partition here
	$i = $leftBound+1;
	my $counts = 0;
	for $j($leftBound+1..$rightBound){
		if ($array->[$j] < $pivot){
#			say "array before: @$array";
#			print "pivot is $pivot  ";
#			say "I find $array->[$j] at index <$j>";			
			# say "i = $i and j = $j";
			@$array[$i,$j] = @$array[$j,$i];
			$i++;
			# say "array now: @$array"
		
		}
			$counts++;
	}
	#$i++;	
	@$array[$leftBound,$i - 1] = @$array[$i - 1,$leftBound];
	#this is where $pivot should stay

	return ($i-1,$counts);
}
__DATA__
50
80
90
10
40
20
30
60