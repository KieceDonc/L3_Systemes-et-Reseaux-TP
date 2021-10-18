#!/bin/bash

for l in {A..G}; do
	GROUPPATH=$1'groupe'$l
	if [ -d $GROUPPATH ]; then
		for x in {1..2}; do
			SUJETPATH=$GROUPPATH'/Sujet'$x
			if [ -d $SUJETPATH ]; then
				for DIRECTORY in $SUJETPATH'/'*; do
					for y in {1..2}; do
						NEWNAME=$DIRECTORY'/groupe'$l'_nom_Sujet'$y'.odt'
						ODT=$DIRECTORY'/Sujet'$y'.odt'
						if [ -f $ODT ]; then
							if [ $x -eq $y ];then
								echo 'good ' $ODT
								$(mv $ODT $NEWNAME)
							fi
						fi
					done
				done
			fi
		done
	fi
done