#!/bin/bash
# sets up usage
USAGE="usage: $0 -i --inputDir inputDir -d --debug"

if ! command -v jq >/dev/null 2>&1 ; then
    echo "jq could not be found"
    exit 1
fi

# set up defaults
DEBUG=0
inputDir=~/inputDir

# parses and reads command line arguments
while [ $# -gt 0 ]
do
  case "$1" in
    (-i) inputDir="$2"; shift;;
    (--inputDir) inputDir="$2"; shift;;
    (-d) DEBUG=1;;
    (--debug) DEBUG=1;;
    (-*) echo >&2 ${USAGE}
    exit 1;;
  esac
  shift
done

echo you entered values
echo   "From inputDir     : $inputDir"

is_file_a_movie_or_photo() {
    file_to_check="$1"
    if [ -z "$file_to_check" ] ; then
        return 1
    elif [[ "${file_to_check}" == *.jpg ]] ; then
        return 0
    elif [[ "${file_to_check}" == *.JPG ]] ; then
        return 0
    elif [[ "${file_to_check}" == *.png ]] ; then
        return 0
    elif [[ "${file_to_check}" == *.PNG ]] ; then
        return 0
    elif [[ "${file_to_check}" == *.mp4 ]] ; then
        return 0
    elif [[ "${file_to_check}" == *.MP4 ]] ; then
        return 0
    elif [[ "${file_to_check}" == *.mov ]] ; then
        return 0
    elif [[ "${file_to_check}" == *.MOV ]] ; then
        return 0
    fi
    return 1
}

export -f is_file_a_movie_or_photo

get_photo_meta_data_file() {
    photo_file="$1"
    echo "$photo_file".supplemental-metadata.json
}

export -f get_photo_meta_data_file

get_movie_meta_data_file() {
    movie_or_photo_file="$1"
    file_without_extension="${movie_or_photo_file%.*}"
    echo "$file_without_extension"
}

export -f get_photo_meta_data_file

extract_creation_date_from_meta_data_file() {
    meta_data_file="$1"
    echo >&2 jq "${meta_data_file}"
    creation_date=$(jq .photoTakenTime.timestamp "${meta_data_file}")
    if [ -z $creation_date ] ; then
        return 1
    fi
    echo "$creation_date"
}

export -f extract_creation_date_from_meta_data_file

update_photo_file_modified_date_with_extracted_meta_data() {
    file_name="$1"
    meta_data_file=$(get_photo_meta_data_file "$file_name")
    echo meta data file: "${meta_data_file}"
    extracted_creation_date=$(extract_creation_date_from_meta_data_file "$meta_data_file")
    if [ $extracted_creation_date ] ; then
        echo apply_extracted_date_to_photo_or_movie_file "$file_name" $extracted_creation_date
    else
        echo
        return 1
    fi
    echo
}

export -f update_photo_file_modified_date_with_extracted_meta_data

update_movie_file_modified_date_with_extracted_meta_data() {
    file_name="$1"
    meta_data_file=$(get_photo_meta_data_file "$file_name")
    echo meta data file: "${meta_data_file}.suppl.json"
    echo
}

export -f update_movie_file_modified_date_with_extracted_meta_data

find "$inputDir" -type f -iname '*.jpg' -ok sh -c 'update_photo_file_modified_date_with_extracted_meta_data "{}"' \;
find "$inputDir" -type f -iname '*.png' -ok sh -c 'update_photo_file_modified_date_with_extracted_meta_data "{}"' \;
find "$inputDir" -type f -iname '*.mp4' -ok sh -c 'update_movie_file_modified_date_with_extracted_meta_data "{}"' \;
find "$inputDir" -type f -iname '*.mov' -ok sh -c 'update_movie_file_modified_date_with_extracted_meta_data "{}"' \;