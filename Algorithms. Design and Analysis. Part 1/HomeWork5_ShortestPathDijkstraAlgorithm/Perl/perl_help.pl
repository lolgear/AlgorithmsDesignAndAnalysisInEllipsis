
my %hash;
while (<DATA>) {
	
	next if $.==1;
	chomp;
	my ($first,@others) = (split /\s+/);
	for (@others){
		$hash{$_}.=' '.$first;
	}
}
use Data::Dumper;
print Dumper \%hash;
__DATA__
    G1  G2  G3  G4
Pf1 NO  B1  NO  D1
Pf2 NO  NO  C1  D1
Pf3 A1  B1  NO  D1
Pf4 A1  NO  C1  D2
Pf5 A3  B2  C2  D3
Pf6 NO  B3  NO  D3