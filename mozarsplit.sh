#!/bin/bash -x
## Date     20171109
## Author   smartdancer


## Dependencies     shntool flac
## System   centos

cdir=$(pwd)
audiofiletxt=$cdir/audiofile.txt
storagebase=~/Lossless

[[ ! -f "$audiofiletxt" ]] && touch "$audiofiletxt"
find "$cdir" -name "*.flac" > "$audiofiletxt"

while read audiofile ;
do
    trackname=$(basename "$audiofile" .flac)
    storagepath=$storagebase/$trackname
    [[ ! -f "$storagepath" ]] && mkdir -p "$storagepath"
    shnsplit -d "$storagepath" -f "$trackname".cue -o "flac flac -V --best -o %f -" "$audiofile" -t "%n%p-%t"
    cuetag.sh "$trackname".cue "$storagepath"/*.flac
done < "$audiofiletxt"


rm "$audiofiletxt"
