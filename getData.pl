#!/usr/bin/perl

use strict;
use warnings;

use Text::Unaccent;
use String::Similarity;
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

	my $itemsKeys = {
		for => 0,
		dex => 1,
		con => 2,
		int => 3,
		sag => 4,
		cha => 5,
		ref => 6,
		vig => 7,
		vol => 8,
		init => 9,
		pv => 10,
		ca => 11,
		xp => 12
	};

	my $index = 13;

	foreach (@monsters) {
		my $items = $_;
		for my $key ( keys %$items ) {
			if(!exists($itemsKeys->{"$key"})) {
				$itemsKeys->{"$key"} = $index++;
			}
		}
	}

	for my $itemsKey ( sort keys %$itemsKeys ) {
		#for my $itemsKey2 ( sort keys %$itemsKeys ) {
		#	my $similarity = similarity $itemsKey, $itemsKey2;
		#	if($similarity != 1 and $similarity > 0.9) {
		#		#print "$itemsKey <=> $itemsKey2\n";
		#	}
		#}
		#print "$itemsKey\n";
		print "$itemsKeys->{$itemsKey} : $itemsKey\n";
	}

}

sub getData {
	my $file = shift;
	my $items = {};
	
	$items->{'text'} = '';
	$items->{'sorts'} = '';
	
	open(FILE, "<$file") or die "Cannot open $file\n";
	
	my $type = 'text';
	my $title = '';
	
	while(<FILE>) {
		my $line = $_;
	
		chomp $line;
	
		if($line =~ m/^<div class="BDtitre">([^<]+)</) {
			$title = $1;
			$items->{'title'} = $title;
		} elsif($line =~ m/^<div class="(BDsoustitre|box)">([^<]+)</) {
			my $category = $2;
		} elsif($line =~ m/<div class="BDtexte">/) {
			$type = 'text';
		} elsif($line =~ m/^<div class="BDsort/) {
			$type = 'sorts';
		} elsif($line =~ m/<div class="([^"]+)"/) {
			print "$title: Where is $1\n";
		} elsif($line =~ m/^<b>([^<]+)<\/b>(.+)/) {
			my $caracName = tidyData($1);
			my $caracVal = tidyData($2);

			$caracName =~ s/\s*\(\w+\)$//g;

			$caracName = tidyDataSpell($caracName);
			
			if($caracName eq 'cac') {
				print "It is $file\n";
			}
	
			$items->{"$caracName"} = $caracVal;
		} elsif($line =~ m/^[^<]+/) {
			if($type eq 'text' or $type eq 'sorts') {
				$items->{"$type"} .= "*$line";
			} else {
				print "$title: Where are we?\n";
				# Do nothing
			}
		}
	}
	
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

sub tidyDataSpell {
	my $data = shift;
	
	$data =~ s/^cac$/corps a corps/g;
	$data =~ s/changement de la forme$/changement de forme/g;
	$data =~ s/engloutissement d'ame$/engloutissement d'ames/g;
	$data =~ s/faiblesse$/faiblesses/g;
	$data =~ s/filament$/filaments/g;
	$data =~ s/immunite$/immunites/g;
	$data =~ s/langue$/langues/g;
	$data =~ s/porteur de maladie$/porteur de maladies/g;
	$data =~ s/px$/xp/g;
	$data =~ s/rayon oculaire$/rayons oculaires/g;
	$data =~ s/renvoi des sorts$/renvoi de sorts/g;
	$data =~ s/representation bardique$/representations bardiques/g;
	$data =~ s/resistance$/resistances/g;
	$data =~ s/sorts d'ensorceleurs connus$/sorts d'ensorceleur connus/g;
	$data =~ s/sorts de pretres prepares$/sorts de pretre prepares/g;
	$data =~ s/souffles$/souffle/g;
	$data =~ s/utilisation du poison$/utilisation des poisons/g;

	return $data;
}

