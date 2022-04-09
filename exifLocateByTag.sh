#!/bin/bash


# load common functions
. ./lib.sh


function tagMatch (){
	filename="$1"
	grepPatterns="$2"

	getKeywords "$filename"
	grep -e grepPatterns | wc -l

}


function allphotos (){
	local dirname=$1
	
	log "Start scan $dirname"

	flist=`find $dirname -type f -name "*.jpg"`
	for filename in $flist;
	do
		if test -f "$filename"; then
			log ">>>>>>>>>>>>>>  photo begin $filename"	
			getKeywords "$filename"
			# Tags may have spaces. needs " around argument.
			
			log "<<<<<<<<<<<<<< photo end $filename" 
			log ""
		fi
	done
	
	log "end $dirname"
}


$folder=$1
$grepPatternsFile=$2

echo "USAGE: $0 Folder tag"


fileTag=$today.$tag.txt

allphotos "$folder" "$grepPatternsFile"