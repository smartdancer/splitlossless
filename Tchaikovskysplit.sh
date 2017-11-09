#!/bin/bash -x

# dependencies:		shntool	cuetools flac
# v1.0 smartdancer


cdir=$(pwd)
audiofiletxt=$cdir/audiofile.txt
storagebase=/home/jack/Lossless

[[ ! -f "$audiofiletxt" ]] && touch "$audiofiletxt"
find "$cdir" -name "*.flac"  > "$audiofiletxt"

## split flac audio
while read audiofile;
do
   audiodir=$(dirname "$audiofile") && cd "$audiodir"
   ## Delete copy cue file
   copycue=$(ls "$audiodir" | grep Copy.cue)
   [[ -f "$copycue" ]] && mv "$copycue" "${copycue}.bak"
   ## create directory for splited audio files
   trackdir=$(dirname "$audiodir")
   trackname=$(basename "$trackdir")
   storagepath=$storagebase/$trackname
   [[ ! -f "$storagepath" ]] && mkdir -p "$storagepath"
   shnsplit -d "$storagepath" -f *.cue -o "flac flac -V --best -o %f -" *.flac -t "%n%p-%t"
   wrongfile=$(ls "$storagepath" | grep '^00')
   [[ -f "$storagepath/$wrongfile" ]] &&  rm "$storagepath/$wrongfile"
   cuetag.sh *.cue "$storagepath"/*.flac
done < "$audiofiletxt"

cd "$cdir"
rm "$audiofiletxt"
