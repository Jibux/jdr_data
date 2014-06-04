#!/usr/bin/perl

use strict;
use warnings;

use Text::Unaccent;
use String::Similarity;
use Data::Dumper;


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
		title => 0,
		for => 1,
		dex => 2,
		con => 3,
		int => 4,
		sag => 5,
		cha => 6,
		ref => 7,
		vig => 8,
		vol => 9,
		init => 10,
		pv => 11,
		ca => 12,
		xp => 13,
		sorts => 14,
		text => 15,
	};

	my $index = 16;
	my $sep = ';';

	foreach (@monsters) {
		my $items = $_;
		for my $key ( keys %$items ) {
			if(!exists($itemsKeys->{"$key"})) {
				$itemsKeys->{"$key"} = $index++;
			}
			#print "$items->{$key}\n";
		}
	}

	my $indexMax = $index;

	my %itemsKeysReverse = reverse %$itemsKeys;

	open(OUT, ">monsters.csv");
	for(my $i = 0; $i < $indexMax; $i++) {
		print OUT "$itemsKeysReverse{$i}$sep";
	}
	print OUT "\n";
	
	foreach (@monsters) {
		my $items = $_;
		for(my $i = 0; $i < $indexMax; $i++) {
			if(exists($items->{$itemsKeysReverse{$i}})) {
				print OUT "\"$items->{$itemsKeysReverse{$i}}\"";
			}
			print OUT $sep;
		}
		print OUT "\n";
	}

	close(OUT);
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
			
			#if($caracName eq 'cac') {
			#	print "It is $file\n";
			#}

			if(exists($items->{"$caracName"})) {
				if($caracName eq 'sorts') {
					$items->{"$caracName"} .= "*$caracVal";
				} elsif($items->{"$caracName"} ne "$caracVal") {
					#print "===$title : $caracName===\n$items->{$caracName} - $caracVal\n";
					$items->{"$caracName"} .= " // $caracVal";
				}
			} else {
				$items->{"$caracName"} = "$caracVal";
			}
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

	$data =~ s/"/\\"/g;

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

