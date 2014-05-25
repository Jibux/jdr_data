#!/bin/bash

FILE=$1
FILE2=monsters_tidy/${FILE##*/}


# Capacité spéciales
# capacités spéciales
# Capacités spéciales
# Capacités Spéciales
# Caractéristiques
# Caractéristiques de base
# Ecologie
# Écologie
# Pouvoirs spéciaux
# Pouvoirs Spéciaux
# Staistiques
# Statistiques
# Statistiques de base


sed -r "s#<ul>#\n<ul>#g ; s#</ul>#</ul>\n#g ; s#</li>#</li>\n#g" $FILE > $FILE2
#sed -ri "s#<(/|)(i|a|li|ul|br)[^>]*>##g ; s#[{}]##g ; s#<sup>([^<]+)</sup>#{\1}#g ; s#([^>]+)<b>([^<]+)</b>#\1\n<b>\2</b>#g" $FILE2
sed -ri "s#<(/|)(i|a|li|ul|br)[^>]*>##g ; s#[{}]##g ; s#<sup>([^<]+)</sup>#{\1}#g ; s#<b>#\n<b>#g" $FILE2
sed -i "/^$/d" $FILE2
sed -ri "s/(c|C)apacité(s|)\s*(s|S)péciales/Capacités spéciales/g ; s/Caractéristiques\s*de\s*base/Caractéristiques/g ; s/Ecologie/Écologie/g ; s/Pouvoirs\s*(s|S)péciaux/Pouvoirs spéciaux/g ; s/Sta(t|)istiques(\s*de\s*base|)/Statistiques/g" $FILE2

