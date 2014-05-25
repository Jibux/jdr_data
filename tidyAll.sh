#!/bin/bash

for monster in $(ls monsters_tidy); do
	./tidy.sh monsters_tidy/$monster
done

