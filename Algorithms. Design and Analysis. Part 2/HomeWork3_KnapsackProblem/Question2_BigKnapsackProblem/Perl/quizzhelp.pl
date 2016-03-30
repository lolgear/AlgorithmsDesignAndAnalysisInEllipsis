use Data::Dumper;
# use HashTable;
use lib qq($ENV{HOME}/Documents/Projects/Perls/);
use LolgearTools qw(chmp say sayEvery sayToFile);
#-------- Begin ----------#

$,=",";
$"=":";

my $fh;
open $fh, '<', 'quizz_input.txt';
my (@array) = <$fh>;
my $count = scalar @array;

my $twod = [];
for (1..$count){
	$twod->[$_] = [];
}

say Dumper $twod;
my $n = $count;
for my $s (0 .. $n-1){
	for my $i (1 .. $n - $s){
		my $left = 0;
		my $right = 0;
		my @slices = ($i .. $i+$s);
		$twod->[$i]->[$i+$s] = sum(\@array,$i,$i+$s) + min(
				func(\@slices,$twod,$i,$s)
			);
	}
}
say Dumper $twod;
# for s = 0 to n-1
#    for i = 1 to n
#       A[i,i+s] = ∑i+sk=ipk+minr=i,...,i+s{A[i,r−1]+A[r+1,i+s]}
# return A[1,n]

say "yes: ", $twod[1]->[$n-1];

sub func{
	my ($slices, $twod, $i, $s) = @_;
	my @result;
	my $x;
	for my $r(@$slices){
		$x = 0;
		$x += $twod->[$i]->[$r - 1] unless ($i > ($r - 1));
		$x += $twod->[$r+1]->[$i + $s] unless ($r+1) > ($i + $s);
		push @result,$x;
	}
	return @result;
}
sub min {
	my (@array) = @_;
	return (sort {$a <=> $b} @array)[0];
}
sub sum {
	my ($array, $first,$last) = @_;
	my $sum = 0;
	map {$sum+=$array->[$_]}($first..$last);
	return $sum;
}