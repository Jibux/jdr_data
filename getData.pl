#!/usr/bin/perl

use strict;


# Supprimer <a > et récuppérer le contenu
# Supprimer <abbr> et //
# Supprimer <i>
# Mettre à la ligne les .+<b>


my $file = $ARGV[0];

open(FILE, "<$file") or die "Cannot open $file\n";

while(<FILE>) {
	my $line = $_;

	chomp $line;

	if($line =~ m/^<div class="BD(sous|)titre">([^<]+)</) {
		my $categorie = $2;
		print "$categorie\n";
	}

	if($line =~ m/^<b>([^<>]+)<\/b>([^<>]+)/) {
		my $caracName = tidyData($1);
		my $caracVal = tidyData($2);

		print "Name:\t$caracName --- Val: $caracVal\n";
	}

	if($line =~ m/^[^<]+/) {
		print "Line:\t$line\n";
	}
}

close(FILE);


sub tidyData {
	my $data = shift;

	$data =~ s/^\s+//g;
	$data =~ s/\s*[,;.]\s*$//g;

	return $data;
}

