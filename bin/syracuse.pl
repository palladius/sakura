#!/usr/bin/perl

my $SEPARATOR=" ";
my $niterations = 0;

sub siracusa {
	my $t = shift;
	$niterations ++ ;
	if ($t == 1 ) {
		return 1;
	}
	print "$t$SEPARATOR";
	if ($t %2) {
		return siracusa(3  * $t +1);
	}
	return siracusa($t/2);
}

#use argv;
#print "arg: " .( $ARGV[0] ). "\n";
print "# Serie semplice ma bella: se pari dimezzo, se dispari triplico+1\n";
my $arg = 0+int($ARGV[0]);
if ($arg == 0) {
	$arg = 42;
}
print siracusa($arg);
#print siracusa(0 + int($ARGV[0]));
print "\n";
print "# Durata volo:    $niterations\n";
print "# Impennata volo: " .($niterations/$arg) ."\n";

