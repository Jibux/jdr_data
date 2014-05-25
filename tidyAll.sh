#!/bin/bash

for monster in $(ls monsters); do
	./tidy.sh monsters/$monster
done

