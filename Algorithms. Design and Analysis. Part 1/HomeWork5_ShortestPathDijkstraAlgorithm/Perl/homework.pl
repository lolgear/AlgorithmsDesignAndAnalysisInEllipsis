
#-------- Begin ----------#
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
use Data::Dumper;
$,=",";
$"=":";
sub chmp{
	for (@_){
		s/^\s+//;
		s/\s+$//;
	}
	return @_;
}

#-------- Functions ------#

sub say {
	for(@_){
		print;
		print{$oh}$_;	
	}
	print"\n";
	print{$oh}"\n";
}

sub sayAbout{
	my $graph = shift;
	my (@vertexs) = @_;
	for my $vertex (@vertexs){	
		# say $vertex, "--->","@{$graph->{$vertex}}" if exists $graph->{$vertex};
	}
}


# ---------- Main ---------- #

my $graph = {};
readData($graph,$fh);

# say Dumper $graph;
# i will search shortest path as source first (1) node
my $sourceNode = 1;

my $destinations = [
	7,37,59,82,99,115,133,165,188,197
];
undef $destinations unless $input eq 'input.txt';
prepareForAlgorithm($graph,$sourceNode, $destinations);

# -------- Functions -------- #
# ---- Data Manipulation ---- # 
# --------------------------- #
sub readData{
	my ($graph,$fh) = @_;
	while (<$fh>){
		#chomp;
		( $_ )= chmp($_);
		my ($node, @nodes) = (split /\s+/);
		for my $connect(@nodes){		
			addNode($graph,$node,[(split(',',$connect))]);
		}
	}
}

sub createNode{
	my $defaultMaxPath = 1000000;
	my ($graph,$index) = @_;
	unless (exists $graph->{$index}){
		$graph->{$index} = {
			connections => {},
			visited => 0,
			path => $defaultMaxPath,
			paths => [],
		};
	}
}
sub addNode{
	my ($graph,$node,$connect) = @_;
	my ($connectNode,$weight) = @$connect;
	createNode($graph,$node);
	createNode($graph,$connectNode);
	unless(exists $graph->{$node}->{connections}->{$connectNode}){
		$graph->{$node}->{connections}->{$connectNode} = $weight;
	}	
	# unless(exists $graph->{$connectNode}->{connections}->{$node}){
	# 	$graph->{$connectNode}->{connections}->{$node} = $weight;
	# }
}

# ------------------------------- #
# ---- Algorithm Realization ---- #
# ------------------------------- # 
sub prepareForAlgorithm{
	my ($graph,$source,$destinations) = @_;
	# here we can compute dijkstra algorithm
	# I will search from this node, so, it's path (or weight) will be small enough ;)
	$graph->{$source}->{path} = 0;
	DijkstraAlgorithm($graph,$source);
	say "I have results for destinations";
	# my $sum = 0;
	# for (split /,/,'1:49,49:4,4:31,31:10,10:7'){
	# 	my ($l,$r) = split /:/;
	# 	$sum += $graph->{$l}->{connections}->{$r};
	# }
	# print "sum $sum";
	
	unless ($destinations){
		$destinations = [sort {$a<=>$b} keys %$graph];
	}
	for my $destination(@$destinations){
		say "$destination value :  $graph->{$destination}->{path}";		
		say "$destination path : @{$graph->{$destination}->{paths}}";
	}
	say "Result is " . join (',', map{$graph->{$_}->{path}}@$destinations);

	for my $destination(grep{$_~~@$destinations}keys %$graph){
		# say "$destination   :  $graph->{$destination}->{path}";
	}
}

sub changeNodeWeight{
	my ($graph,$index,$connect) = @_;
	my $old_weight = $graph->{$connect}->{path};
	my $source_weight = $graph->{$index}->{path};
	my $new_weight = $source_weight + $graph->{$index}->{connections}->{$connect};
	if ($new_weight < $old_weight){
		@{$graph->{$connect}->{paths}} = (@{$graph->{$index}->{paths}},$index);
		$graph->{$connect}->{path} = $new_weight;
		# do{print "this is $connect    ";
		#    #print "this is new weight $new_weight   ";
		#    #print "from index $index\n";
		#    print "and I have path is @{$graph->{$connect}->{paths}}\n";
		#    } if $connect ~~ [7,37,59,82,99,115,133,165,188,197];		
	}
}

sub DijkstraAlgorithm{
	my ($graph,$index) = @_;
	# try to change weight
	DijkstraAlgorithmStepOne($graph,$index);
	# next, choose index with minimal weight
	$index = DijkstraAlgorithmStepTwo();
	print "next: $index\n";
	if (defined $index){
		DijkstraAlgorithm($graph,$index);	
	}	
}

sub DijkstraAlgorithmStepOne{
	my ($graph,$index) = @_;
	$graph->{$index}->{visited} = 1;
	# sorting array of connections by weight
	my @keys = sort {$graph->{$a}->{path} <=> $graph->{$b}->{path} }keys %{$graph->{$index}->{connections}};
	for my $connect (@keys){
		unless ($graph->{$connect}->{visited}){
			changeNodeWeight($graph,$index,$connect);
		}
	}
}

# choosing vertex with minimal weight
sub DijkstraAlgorithmStepTwo{
	return 
		   (grep{!$graph->{$_}->{visited}}
		   sort {$graph->{$a}->{path}<=>$graph->{$b}->{path}} 
		   keys %$graph)[0];
}