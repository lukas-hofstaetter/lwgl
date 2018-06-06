#!/bin/bash

#
#This script removes all fileinformation from given Input file and creates all files specified by the fileinformation.
#
# Usage: ./lwfs.sh inputFile.txt
#
#Example of inputFile.txt file:
#	Some Random Text
#	Blabla ...
#	*/home/user/foo.log< 48 65 6c 6c 6f 20 57 6f  72 6c 64 0a
#	Some more text ...
#	*../bar.txt< 54 77 65 6e 74 79 20 66  6f 75 72 20 69 73 20 74 54 77 65 6e 74 79 20 66  6f 75 72 20 69 73 20 74
#
#Will be converted to three files foo.log, bar.txt, inputFile.txt.data and inputFile.txt.files
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
#	*../bar.txt< 54 77 65 6e 74 79 20 66  6f 75 72 20 69 73 20 74 54 77 65 6e 74 79 20 66  6f 75 72 20 69 73 20 74
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
echo "$TEXT" > $INPUT.data
echo "$FILES" > $INPUT.files

#Write the files
while read -r file; do
	NAME=`grep -o -P "(?<=$START)(.+)(?=$SEPARATOR)" <<< $file`
	DATA=`grep -o -P "(?<=$SEPARATOR)(.+)" <<< $file`
	echo "  LWFS    Creating file: `realpath --relative-to="$WD" "$NAME"` (${#file} bytes)"
	echo $DATA | xxd -r -p - $NAME
	#FIXME Non-existend folders must be created before dumping the data via xxd
done <<< "$FILES"
