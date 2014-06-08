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

	my $i = 0;

	my $itemsKeys = {
		title => $i++,
		for => $i++,
		dex => $i++,
		con => $i++,
		int => $i++,
		sag => $i++,
		cha => $i++,
		ref => $i++,
		vig => $i++,
		vol => $i++,
		init => $i++,
		pv => $i++,
		ca => $i++,
		xp => $i++,
		vd => $i++,
		sorts => $i++,
		resistances => $i++,
		'corps a corps' => $i++,
		distance => $i++,
		'attaques speciales' => $i++,
		dons => $i++,
		competences => $i++,
		'modificateurs raciaux' => $i++,
		sens => $i++,
		langues => $i++,
		environnement => $i++,
		tresor => $i++,
		'organisation sociale' => $i++,
		bba => $i++,
		bmo => $i++,
		dmd => $i++,
		text => $i++,
		misc => $i++,
	};

	my $index = $i;
	my $sep = ';';

	foreach my $file (glob("monsters_tidy/*")) {
		#print "$file\n";
		my $items = getData($file);
		push(@monsters, $items);
	}

	foreach (@monsters) {
		my $items = $_;
		for my $key ( keys %$items ) {
			if(!exists($itemsKeys->{"$key"})) {
				#$itemsKeys->{"$key"} = $index++;
				$items->{misc} .= "* $key".' : '.$items->{"$key"}."\n";
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
				chomp($items->{$itemsKeysReverse{$i}});
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
	$items->{'misc'} = '';
	
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
					$items->{"$caracName"} .= "* $caracVal\n";
				} elsif($items->{"$caracName"} ne "$caracVal") {
					#print "===$title : $caracName===\n$items->{$caracName} - $caracVal\n";
					$items->{"$caracName"} .= "\n$caracVal";
				}
			} else {
				$items->{"$caracName"} = "$caracVal";
			}
		} elsif($line =~ m/^[^<]+/) {
			if($type eq 'text' or $type eq 'sorts') {
				$items->{"$type"} .= "* $line\n";
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

	$data =~ s/"/'/g;

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

