#!/bin/bash -x

## Date     20171109

cdir=$(pwd)
storagebase=$HOME/Lossless
audiofiletxt=$cdir/audiofile.txt
[[ ! -f "$audiofiletxt" ]] && touch "$audiofiletxt"



find "$cdir" -regextype posix-extended -regex ".*(flac|wav|ape)$" > "$audiofiletxt"

while read audiofile;
do
    audiodir=$(dirname "$audiofile") && cd "$audiodir"
    audioname=$(basename "$audiofile")
    audiotype=${audioname##*.}
    trackname=${audioname%.*}
    storagepath=$storagebase/$trackname
    [[ ! -f "$storagepath" ]] && mkdir -p "$storagepath"
    shnsplit -d "$storagepath" -f "$trackname".cue -o "flac flac -V --best -o %f -" "$audioname" -t "%n%p-%t"
    ## Delete the wrong track file
    find "$storagepath" -type f -size -1024k -exec rm {} \;
    cuetag.sh "$trackname".cue "$storagepath"/*."$audiotype"
done < "$audiofiletxt"

cd "$cdir"
rm "$audiofiletxt"
