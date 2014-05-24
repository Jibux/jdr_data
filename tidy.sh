#!/bin/bash

FILE=$1
FILE2=monsters_tidy/${FILE##*/}

sed -r "s#<ul>#\n<ul>#g ; s#</ul>#</ul>\n#g ; s#</li>#</li>\n#g" $FILE > $FILE2
sed -ri "s#<(/|)(i|a|li|ul|br)[^>]*>##g ; s#[{}]##g ; s#<sup>([^<]+)</sup>#{\1}#g ; s#([^>]+)<b>([^<]+)#\1\n<b>\2#g" $FILE2
sed -i "/^$/d" $FILE2

