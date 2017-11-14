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
tmpdir=$storagebase/tmp
[[ ! -d "tmpdir" ]] && mkdir -p "$tmpdir"
audiofiletxt=$cdir/audiofile.txt
[[ ! -f "$audiofiletxt" ]] && touch "$audiofiletxt"

## find all audio files
find "$sdir" -regextype posix-extended -regex ".*(flac|wav|ape)$" | sort >  "$audiofiletxt"
## convert file enconding to UTF-8
find "$sdir" -name "*cue" -exec iconv -f ISO-8859-1 -t UTF-8 -o {} {} \;

while read audiofile;
do
    audiodir=$(dirname "$audiofile") && cd "$audiodir"
    audioname=$(basename "$audiofile")
    #audiotype=${audioname##*.}
    #trackname=${audioname%.*}
    trackname=${audioname%%.*}
    storagepath=$storagebase/$trackname
    [[ ! -d "$storagepath" ]] && mkdir -p "$storagepath"
    if [[ -f "${trackname}.cue" ]];then
        shnsplit -d "$tmpdir" -f "$trackname".cue -o "flac flac --no-utf8-convert -V --best -o %f -" "$audioname" -t "%n%p-%t"
        ## Delete the wrong track file
        find "$storagepath" -regextype posix-extended -regex ".*/00.*" -exec rm {} \;
        cuetag.sh "$trackname".cue "$tmpdir"/*.flac
    elif [[ -f "${audioname}.cue" ]];then
        shnsplit -d "$tmpdir" -f "$audioname".cue -o "flac flac --no-utf8-convert -V --best -o %f -" "$audioname" -t "%n%p-%t"
        ## Delete the wrong track file
        find "$tmpdir" -regextype posix-extended -regex ".*/00.*" -exec rm {} \;
        cuetag.sh "$audioname".cue "$tmpdir"/*.flac
    else
        echo "Wrong cue file path"
        exit 1
    fi
    [[ -d "$tmpdir" ]] && mv "$tmpdir"/* "$storagepath"
done < "$audiofiletxt"

cd "$sdir"
[[ -f "$audiofiletxt" ]] && rm "$audiofiletxt"
[[ -d "$tmpdir" ]] && rmdir "$tmpdir"
