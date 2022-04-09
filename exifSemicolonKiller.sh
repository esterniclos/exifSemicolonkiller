#!/bin/bash


# load common functions
. ./lib.sh

fListToTest="$tdir/listTotest.txt"
ftested="$tdir/tested.txt"

function notTestedYet(){
	local filename=$1
	local existsInFile
	existsInFile=`grep "$filename" $tested | wc -l`

	if [ $existsInFile -eq 1 ]
	then
		log "Tested $file"
		return false
	fi

	log "Not Tested yet $file"
	return true

}

function markAsTested(){
	local filename=$1

	log "markAsTested $filename"
	echo "$filename" >> $ftested
}


function rewriteNormalizedExifTags(){
	local filename=$1	
	

	
	normalizeExifTags $filename #return value $ret_normalizeExifTagsFile file
	# remove original metadata:
	log "Delete old metadata in $filename"
	exiftool -a -keywords= $filename

	# Escribir etiquetas:
	cat $ret_normalizeExifTagsFile | while read LINE
	do
		exiftool -a -keywords+="$LINE" "$filename"
		log "Wrote new metadata: $LINE"
		
	done

	}



ret_filesToTest="$tdir/filesToTest.txt"
function filesToTest (){
	local dirname=$1
	local allFiles="$tdir/allphotos.txt"

	touch $allFiles # Initialize

	find $dirname -type f | grep -i "\.jpg$" >> $allFiles
	find $dirname -type f | grep -i "\.jpeg$" >> $allFiles

	if [ -f $ftested ]; then
		# diferencia entre los que ya están revisados:
		comm -3 $allFiles $ftested >> $ret_filesToTest
	else # primera ejecución: se leen todas.
		cp $allFiles $ret_filesToTest
	fi

}

function testPhoto (){
	local filename=$1

	log ">>>> photo begin $filename" 

   		getKeywords "$filename"		# Tags may have spaces. needs " around argument.
		if containsSemicolons "$ret_getKeywords"; then
			rewriteNormalizedExifTags "$filename"
			# Saves list name:
			echo "$filename" >> $fileSemiColonsList
		fi
    	markAsTested "$filename"
		log "<<<< photo end $filename" 
}


fileSemiColonsList="$today.semicolons.txt"
touch $fileSemiColonsList
function allphotos (){
	local dirname=$1
	
	log "Start scan $dirname"
	filesToTest "$dirname" #Diferencia entre los que existen y los que no.

	while read -r filename; do
		testPhoto $filename
		
	done <$ret_filesToTest

	
	log "end $dirname"
}


allphotos $1