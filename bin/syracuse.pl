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

print "# Simple yet neat algorithm: if n is even, I halve it. If it's odd I triple it and add 1. Look:\n";
my $arg = 0+int($ARGV[0]);
if ($arg == 0) {
	$arg = 42;
}
print siracusa($arg);
#print siracusa(0 + int($ARGV[0]));
print "\n";
print "# Flight time:     $niterations\n";
print "# Flight pendency: " .($niterations/$arg) ."\n";

