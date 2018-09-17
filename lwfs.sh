#!/bin/bash

#
#This script removes all file information from given input file and creates all files by specified syntax.
#
#Usage: ./lwfs.sh inputFile.txt
#
#Example of inputFile.txt file:
#	Some Random Text
#	Blabla ...
#	*/home/user/foo.log< 48 65 6c 6c 6f 20 57 6f  72 6c 64 0a
#	Some more text ...
#	*../bar.txt< 54 77 65 6e 74 79 20 66  6f 75 72 20 69 73 20 74 54 77 65 6e 74 79 20 66 6f 75 72 20 69 73 20 74
#
#Will be converted to foo.log, bar.txt, inputFile.txt.data and inputFile.txt:
#
#foo.log:
#	Hello World
#
#bar.txt:
#	Twenty four is the solution
#
#inputFile.txt.data:
#	Some Random Text
#	Blabla ...
#	Some more text ...
#
#inputFile.txt.files:
#	*/home/user/foo.log< 48 65 6c 6c 6f 20 57 6f  72 6c 64 0a
#	*../bar.txt< 54 77 65 6e 74 79 20 66  6f 75 72 20 69 73 20 74 54 77 65 6e 74 79 20 66 6f 75 72 20 69 73 20 74
#

if [ -n "$V" ] 
then
	set -o xtrace
fi
WD=`pwd`

INPUT=$1

START="\*"
SEPARATOR="<"

#Splitting File-information and Text
echo "  LWFS    Extracting file information and text from $INPUT. ($(wc -c <"$INPUT") bytes)"
echo "  LWFS    Working directory: $WD"
FILES=`egrep -a "$START(.+)$SEPARATOR[1234567890 ABCDEF]+" $INPUT`
TEXT=`egrep -av "$START(.+)$SEPARATOR[1234567890 ABCDEF]+" $INPUT`
echo -n "$TEXT" > $INPUT.data
echo -n "$FILES" > $INPUT.files
echo "  LWFS    Extracted $(wc -c <$INPUT.files) file characters"
echo "  LWFS    Extracted $(wc -c <$INPUT.data) text characters"

if [ -s  $INPUT.files ]; then
	#Write the files
	while read -r file; do
		NAME=`grep -o -P "(?<=$START)(.+)(?=$SEPARATOR)" <<< $file`
		DATA=`grep -o -P "(?<=$SEPARATOR)(.+)" <<< $file`
		echo "  LWFS    Creating file: `realpath --relative-to="$WD" "$NAME"` (${#file} bytes)"
		rm -f $NAME
		echo $DATA | xxd -r -p - $NAME
		#FIXME Non-existend folders must be created before dumping the data via xxd
	done <<< "$FILES"
else
	echo "Error: No coverage files.";
	exit 1;
fi
