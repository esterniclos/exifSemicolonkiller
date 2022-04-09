#!/bin/bash

. ./lib.sh

log "USAGE: $0 dir"
log " creates a list with all tags found"


tagListFile="$today.existingTags.txt"
tagListFileTmp="$today.existingTags.tmp"

function allphotos (){
	local dirname=$1
	
	log "Start scan $dirname"
	rm -f $tagListFileTmp $tagListFile # Init files

	flist=`find $dirname -type f -name "*.jpg"`
	for filename in $flist;
	do
		if test -f "$filename"; then
			log ">>>>>>>>>>>>>>  photo begin $filename"	
				normalizeExifTags "$filename"
				cat "$ret_normalizeExifTagsFile" >>  $tagListFileTmp
			log "<<<<<<<<<<<<<<  photo end $filename"
			
		fi
	done
	
	sort -u $tagListFileTmp > $tagListFile 

	log "end $dirname"
}


allphotos $1

rm -f $tagListFileTmp # Remove temp