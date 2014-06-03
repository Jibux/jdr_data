#!/usr/bin/perl

use strict;
use warnings;

use Text::Unaccent;
use Data::Dumper;

# XP PX ?

# !!! monsters_tidy/Élémentaire-De-Leau.html il y en a plusieurs

if( @ARGV > 0 ) {
	my $items = getData($ARGV[0]);
	#print Dumper $items;
} else {
	my @monsters;

	foreach my $file (glob("monsters_tidy/*")) {
		#print "$file\n";
		my $items = getData($file);
		push(@monsters, $items);
	}

	my $itemsKeys = {};
	my $index = 0;

	foreach (@monsters) {
		my $items = $_;
		for my $key ( keys %$items ) {
			if(!exists($itemsKeys->{"$key"})) {
				$itemsKeys->{"$key"} = $index++;
			}
		}
	}

	for my $itemsKey ( sort keys %$itemsKeys ) {
		print "$itemsKey : $itemsKeys->{$itemsKey}\n";
	}

}

sub getData {
	my $file = shift;
	my $items = {};
	
	$items->{'text'} = '';
	$items->{'sorts'} = '';
	
	open(FILE, "<$file") or die "Cannot open $file\n";
	#open(OUT, ">>monsters.csv");
	
	my $type = 'text';
	my $title = '';
	
	while(<FILE>) {
		my $line = $_;
	
		chomp $line;
	
		if($line =~ m/^<div class="BDtitre">([^<]+)</) {
			$title = $1;
			#print OUT "\n\"$title";
			$items->{'title'} = $title;
		} elsif($line =~ m/^<div class="(BDsoustitre|box)">([^<]+)</) {
			my $category = $2;
			#print "$category\n";
		} elsif($line =~ m/<div class="BDtexte">/) {
			$type = 'text';
		} elsif($line =~ m/^<div class="BDsort/) {
			$type = 'sorts';
		} elsif($line =~ m/<div class="([^"]+)"/) {
			print "$title: Where is $1\n";
		} elsif($line =~ m/^<b>([^<]+)<\/b>(.+)/) {
			my $caracName = tidyData($1);
			my $caracVal = tidyData($2);
	
			$items->{"$caracName"} = $caracVal;
	
			#print "Name:\t$caracName --- Val: $caracVal\n";
			#print OUT "\",\"$caracVal";
		} elsif($line =~ m/^[^<]+/) {
			#print "Line:\t$line\n";
			#print OUT "\n$line";
	
			if($type eq 'text' or $type eq 'sorts') {
				$items->{"$type"} .= "*$line";
			} else {
				print "$title: Where are we?\n";
				# Do nothing
			}
		}
	}
	
	#close(OUT);
	close(FILE);

	#print Dumper $items;
	
	return $items;
}

sub tidyData {
	my $data = shift;

	$data =~ s#\s*<[^>]+>$##g;
	$data =~ s/^\s+//g;
	$data =~ s/\s*[,;.]*\s*$//g;

	$data = unac_string('UTF-8', $data);

	$data = lc($data);

	return $data;
}

