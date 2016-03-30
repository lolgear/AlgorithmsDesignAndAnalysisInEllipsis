package LolgearTools;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(chmp say sayEvery sayToFile seeHelp sayTimer);

sub chmp{
	my @alls = map{s/^\s+//; s/\s+$//; $_}@_;
	return @alls;
}

sub seeHelp{
	print qx(perldoc $0);
	exit(0);
}


sub say{
	for(@_){
		print;
	}
	print "\n";
}

sub sayEvery{
	print for map{chomp; $_."\n"}(my @any = @_); 
}

sub sayToFile {
	my $filename = shift;
	my $oh;
	open $oh,'>',$filename or $oh = STDOUT;
	for(@_){
		print;
		print"\n";
		print{$oh}$_;
		print{$oh}"\n";
	}
	print"\n";
	print{$oh}"\n";
}

sub sayTimer{
	my ($from, $total) = @_;
	say "current: $from  /  total: $total";
}

# end of module
1;