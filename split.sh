#!/bin/bash  -x

## Date     20171109

cdir=$(pwd)

if [[ ! -d "$1" ]];then
    sdir=$cdir
    echo "Selected the current directory:"
    echo "---------------------------------"
    echo "$cdir"
    echo "---------------------------------"
else
   case $1 in
        -h | --help)
            echo "Usage: $0 [Path]" 
            echo "The default Path is the current directory@@@"
            exit 1
            ;;
        *)
            if [[ -d "$1" ]];then
                cd "$1" && sdir=$(pwd)
                echo "Selected directory:"
                echo "---------------------------------"
                echo "$1"
                echo "---------------------------------"
            else
                echo "Usage: $0 [Path]"
                exit 1
            fi
            ;;
    esac
fi

storagebase=$HOME/Lossless
audiofiletxt=$cdir/audiofile.txt
[[ ! -f "$audiofiletxt" ]] && touch "$audiofiletxt"

## find all audio files
find "$sdir" -regextype posix-extended -regex ".*(flac|wav|ape)$" | sort >  "$audiofiletxt"

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
    find "$storagepath" -regextype posix-extended -regex ".*/00.*" -exec rm {} \;
    cuetag.sh "$trackname".cue "$storagepath"/*."$audiotype"
done < "$audiofiletxt"

cd "$sdir"
rm "$audiofiletxt"
