#!/bin/bash

# Variables globales
originalK=""
newK=""

function semicolonsToComma (){
	local originalK=$1
	
	newK=`echo "$originalK" | sed 's/;/,/g '`
	
	echo "Metadatos preparados nuevos:"
	echo "$newK"
}

function getKeywords (){
	local filename=$1
	s1=`exiftool -keywords $filename`
	originalK=`echo $s1 | cut -d ":" -f2`

	
	echo "Metadatos originales "
	echo "$originalK"	
	
}

function rewriteKeywords(){
	local filename=$1	
	local originalK=$2
	local newK=$3
	local tmp="tmp.txt"
	local tmp2="tmp2.txt"
	
	
	ret=`exiftool -a -keywords= $filename`
	echo "Delete old metadata: $ret"
	
	rm -f $tmp $tmp2
	echo $newK | cut -d"," --output-delimiter=$'\r\n' -f1- >> $tmp
	# Eliminar espacios de principio de línea
	cat $tmp | awk '{$1=$1};1' > $tmp2
	# Ordenar líneas y quitar duplicados:
	sort -u $tmp2 > $tmp

	# Escribir etiquetas:
	cat $tmp | while read LINE
	do
		ret=`exiftool -a -keywords+="$LINE" $filename`
		echo "Write new metadata: $LINE"
	done


	# rm -f $tmp $tmp2
	echo "Write new metadata: $ret"
	}



function allphotos (){
	local dirname=$1
	
	echo "Start scan $dirname"

	flist=`find $dirname -type f -name "*.jpg"`
	for filename in $flist;
	do
		echo "photo begin $filename"	
		getKeywords $filename
		# Tags may have spaces. needs " around argument.
		semicolonsToComma "$originalK"
		rewriteKeywords $filename "$originalK" "$newK"
		echo "photo end $filename" 
		echo "                       -*- "
		echo ""
	done
	
	echo "end $dirname"
}


allphotos $1