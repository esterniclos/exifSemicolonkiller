#!/bin/bash


# load common functions
. ./lib.sh

#fListToTest="$tdir/completeFileList.txt"
ftested="$tdir/tested.txt"
[[ -d $ftested ]] || touch $ftested

function notTestedYet(){
	local filename=$1
	local existsInFile
	existsInFile=`grep "$filename" $tested | wc -l`

	if [ $existsInFile -gt 1 ]
	then
		log "notTestedYet already Tested $file"
		return false
	fi

	log "notTestedYet  $file"
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
		log "rewriteNormalizedExifTags Wrote new metadata: $LINE"
		
	done

	}

function sortLinesInFile {
	# Ordena todos los campos.
	local f1=$1 
	f2="$tdir/$today.sort.txt"
	cp $f1 $f2
	cat $f2 | uniq | sort  > $f1
	rm -f $f2
}


ret_filesToTest="$tdir/$today.filesToTest.txt"
function filesToTest (){
	local dirname=$1
	local allFiles="$tdir/$today.allphotos.txt"

	rm -f $allFiles $ret_filesToTest # Initialize 

	find $dirname -type f | grep -i "\.jpg$" >> $allFiles
	find $dirname -type f | grep -i "\.jpeg$" >> $allFiles

	sortLinesInFile $allFiles
	sortLinesInFile $ftested 

	if [ -f $ftested ]; then
		# diferencia entre los que ya están revisados:
		comm -23 $allFiles $ftested >> $ret_filesToTest
	else # primera ejecución: se leen todas.
		cp $allFiles $ret_filesToTest
	fi

}

function testPhoto (){
	local filename=$1

	log "testPhoto >>>> Photo begin $filename" 


	if ! test  -f "$filename"; then
		log "$0 file doesn't exist $filename"
		return
	fi

   		getKeywords "$filename"		# Tags may have spaces. needs " around argument.
		if containsSemicolons "$ret_getKeywords"; then
			rewriteNormalizedExifTags "$filename"
			# Saves list name:
			echo "$filename" >> $fileSemiColonsList
		fi
    	markAsTested "$filename"
		log "testPhoto <<<< photo end $filename" 
}


fileSemiColonsList="$tdir/$today.semicolons.txt"
touch $fileSemiColonsList
function allphotos (){
	local dirname=$1
	
	log "[fileSemiColonsList] << Start scan $dirname"
	filesToTest "$dirname" #Diferencia entre los que están ya tested y los que no.

	while read -r filename; do
		testPhoto "$filename"
	done <$ret_filesToTest

	
	log "[fileSemiColonsList] >> end $dirname"
}


allphotos $1