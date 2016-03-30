use Data::Dumper;
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
	my $jobs = readData($inputFile);
	$jobs = sortJobs($jobs);
	$jobs = computeTimeOfJobs($jobs);
	sayToFile $outputFile, "any",Dumper($jobs);
	# now, I have a first element as 
	my $sum = computeScheduleRunningTime($jobs);
	sayToFile $outputFile, "running time is $sum";
	sayToFile $outputFile, "Total time: ".(time() - $^T);
}
Main($input,$output);
# ------- Data Input -------- #
sub readData {
	my $jobs = [];
	my $inputFile = shift;
	open $fh, '<', $inputFile or die "can't open file on read! $inputFile! $!";
	while (<$fh>){
		next if $.==1;
		chomp;
		insertJobAsPieces($jobs,$_);
	}
	return $jobs;
}

sub insertJobAsPieces{
	my ($jobs, $lineToBreak) = @_;
	my @pieces = split /\s+/, $lineToBreak;
	# [job_1_weight] [job_1_length]
	my $job = {
		weight => $pieces[0],
		length => $pieces[1],
		score  => computeScore($pieces[0],$pieces[1]),
		time   => undef
	};
	push @{$jobs}, $job;
}

# ------- Algorithm --------- #

sub computeScore{
	my ($weight,$length) = @_;
	# we could use substraction or division 
	# ($weight - $length or $weight / $length)
	return $weight - $length;
}

sub sortJobs{
	# we must do this:
	# first, sort jobs. if job have the same score, we must sort them 
	# in order with weight
	my $jobs = shift;
	return 
	[sort{$b->{score}<=>$a->{score}}
		sort{$b->{weight}<=>$a->{weight}}
			@$jobs];
}

sub computeTimeOfJobs{
	my $jobs = shift;
	my $previousTime = 0;
	for (@$jobs){
		$_->{time} = $_->{length} + $previousTime;
		$previousTime = $_->{time};
	}
	return $jobs;
}

sub computeScheduleRunningTime{
	my $jobs = shift;
	my $sum = 0;
	for (@$jobs){
		$sum += $_->{time} * $_->{weight};
	}
	return $sum;
}

# sub uniqueElements{
# 	my $array = shift;
# 	my $hash = {};
# 	for (@$array){
# 		$hash->{$_}++;
# 	}
# 	return [keys %$hash];
# }
# sub decartFunc{
# 	my $array = shift;
# 	my $func = shift;
# 	my $result = [];
# 	for my $first (@$array){
# 		push @$result, map{$func->($first,$_)}grep{$first!=$_}@$array;
# 	}
# 	return uniqueElements($result);
# }
