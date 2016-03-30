
use SortedArray;
use Data::Dumper;
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

my $input  ||= 'input_median.txt';
my $output ||= 'output_median_test.txt';

my ($fh,$oh);

open $fh,'<',$input or die "can't open file $input! $!";
open $oh, '>', $output or die "can't open file $output! $!";


my $array = SortedArray->new;
$array->defaultSetup();
# $array->SayAboutArray();
my $count;
while (<$fh>){
	chomp;
	# say "$_";
	$array->InsertElement($_);
	# $array->SayAboutElementsInRow();
	my $arr = $array->array;
	# for my $el(@$arr){
	# 	print "$el,";
	# }
	my @what = @{$array->{array}};
	# $Data::Dumper::Indent = 3;
	# $" = ",";
	# $, = ",";
	# print {$oh} Dumper ($array->array),"\n";
	# say(" @{$arr} ");
	# say "count of elements: ".$array->countOfElements();
	$count ++;
}
$array->SayAboutElements();
say "Total Time is: ".(time() - $^T);
do{say "YEAH!";} if $array->isArraySorted;
do{say "Everything fine!"} if $array->countOfElements() == $count;
say "I extract Min: ", $array->ExtractMin();
say "I extract Max: ", $array->ExtractMax();