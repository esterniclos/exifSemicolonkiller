#!/bin/bash

# Globals
originalK=""


today=$(date +%Y%m%d)
tdir="tempdir"

# Create a tempdirectory to save files
[[ -d $tdir ]] || mkdir $tdir


ret_containsSemicolons=0
function containsSemicolons (){
	local s1=$1
	
	ret_containsSemicolons=0
	if [[ $s1 == *\;* ]]; then	
		ret_containsSemicolons=1 #True value
	else
		log "[containsSemicolons] No semicolon in tags: $s1"
	fi
	return $ret_containsSemicolons

} 


ret_semicolonsToComma="" #Initialize
function semicolonsToComma (){
	local originalK=$1
	
	ret_semicolonsToComma=`echo "$originalK" | sed 's/;/,/g'`
	
	log "[semicolonsToComma] Exif tags without semicolon :"
	log "$ret_semicolonsToComma"
}

ret_normalizeExifTagsFile="$tdir/normalize2.tmp.txt"
function normalizeExifTags (){
	local filename=$1
	
	local tmp="$tdir/normalize.tmp.txt"
	
	if ! test  -f "$filename"; then
		log "[normalizeExifTags] file doesn't exist $filename"
		return
	fi

	getKeywords "$filename" # $ret_getKeywords return value

	# remove any semicolon in keywords:
	semicolonsToComma "$ret_getKeywords" # 

	rm -f $tmp $ret_normalizeExifTagsFile #Init
	echo "$ret_semicolonsToComma" | cut -d"," --output-delimiter=$'\r\n' -f1- >> $tmp
	sort -u $tmp > $ret_normalizeExifTagsFile
	# Return value in a file
}

function tagMatch (){
	local filename=$1
	local tag=$2

	if ! test  -f "$filename"; then
		log "[tagMatch] file doesn't exist $filename"
		return
	fi

	normalizeExifTags $filename #returns $ret_normalizeExifTagsFile
	awk '$1 == $tag' $ret_normalizeExifTagsFile | wx
}

ret_getKeywords="" # Initialize
ret_getKeywordsFile="$tdir/kwf.tmp.txt"
function getKeywords (){
	local filename=$1

	if ! test  -f "$filename"; then
		log "[getKeywords] file not exists $filename"
		return
	fi

	s1=`exiftool -keywords "$filename"`
	log "[getKeywords] exiftool $filename"
	ret_getKeywords=`echo $s1 | cut -d ":" -f2`
	echo "$ret_getKeywords" > $ret_getKeywordsFile

	
	log "[getKeywords] Original Metadata: "
	log "$ret_getKeywords"	
}






log () {
    #local file="$1"; shift
    #printf '%b ' "$@" '\n' | tee -a "$file"
    printf '%b ' "$@" '\n' >&1
}

