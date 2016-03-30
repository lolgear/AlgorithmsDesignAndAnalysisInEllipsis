use Data::Dumper;
sub say {
	for(@_){
		print;
		print{$oh}$_;
	}
	print"\n";
	print{$oh}"\n";
}

#-------- Begin ----------#
$,=",";
$"=",";

sub FilePreparation {
	my ($args) = shift;
	my ($input) = @$args;
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

sub Main {
	my ($fh, $oh) = @_;
	my %graph = ();

	while (defined(my $line = <$fh>)) {
		my @each = (split /\s/, $line);
	    my ($vertex,$connects) = (shift(@each),[sort{$b<=>$a}@each]);
	    $graph{$vertex} = $connects;
	}

	my $graph = \%graph;
	removeLoops($graph, keys %$graph);

	my $count = RandomizedGraphCutAlgorithm(\%graph);
	say "I have crossing edges count: $count";
	say "$count";
	$count;
}

sub RandomizedGraphCutAlgorithm{
	my $graph = shift;
	#my $count = scalar @{+cutEdge($graph)};
	cutEdge($graph);
	my @vertexes = sort {scalar @{$graph->{$b}}<=>scalar @{$graph->{$a}}} keys %$graph;
	my $count = scalar(@{$graph->{$vertexes[0]}});
	return $count;
}

sub cutEdge{
	my $graph = shift;
	do{
		my $randomVertex = chooseRandomVertex($graph);
		my $randomConnect = chooseRandomConnect($graph,$randomVertex);
		#glue together $randomVertex and $randomConnect connects
	   	# say "split $randomVertex and $randomConnect";
		sayAbout($graph,$randomVertex,$randomConnect);
		$graph->{$randomVertex} = unionArraysWithoutVertexes($graph,$randomVertex,$randomConnect);
		renameDestinationVertex ($graph,$randomConnect,$randomVertex);
		sayAbout($graph,$randomVertex);
		removeLoops($graph,$randomVertex);
		sayAbout($graph,$randomVertex);
	}
	until scalar keys %$graph == 2;
	removeLoops($graph,keys %$graph);
}

sub chooseRandomVertex{
	my $graph = shift;
	my @keys = keys %$graph;
	my $randomVertex = $keys[rand @keys];
	return $randomVertex;
}
sub chooseRandomConnect{
	my $graph = shift;
	my $vertex = shift;
	my @keys = @{$graph->{$vertex}};
	my $randomConnect = $keys[rand @keys];
	return $randomConnect;
}
sub removeLoops{
	my ($graph, @ones) = @_;
	for my $one(@ones){
		$graph->{$one} = [grep{!/\b$one\b/}@{$graph->{$one}}];
	}
}
sub renameDestinationVertex{
	my ($graph, $two, $one) = @_;
	my $s = $graph->{$two};
	# take access to all two's connections
	for my $connection(@$s){
		next if $connection == $one;
		for (@{$graph->{$connection}}){
			$_ = $one if $_ == $two;
		}
	}
	delete $graph->{$two};
}

sub unionArraysWithoutVertexes{
	my ($graph,$one,$two) = @_;
	my $union = {};
	my ($f,$s) = @$graph{$one,$two};
    for (@$f,@$s){
		next if ($_==$one || $_==$two);
		$union->{$_} += 1;
	}
	return [sort{$b<=>$a}map{($_)x($union->{$_})}(keys %$union)];
}

sub sayAbout{
	my $graph = shift;
	my (@vertexs) = @_;
	for my $vertex (@vertexs){
		# say $vertex, "--->","@{$graph->{$vertex}}" if exists $graph->{$vertex};
	}
}

Main(FilePreparation(\@ARGV));
