#!/bin/bash
# sets up usage
USAGE="usage: $0 -i --inputDir inputDir -c --commandFile -d --debug"

if ! command -v jq >/dev/null 2>&1 ; then
    echo "jq could not be found"
    exit 1
fi

# set up defaults
DEBUG=0
inputDir=$HOME/inputDir
command_file=$HOME/gphotoexifupdater.sh

# parses and reads command line arguments
while [ $# -gt 0 ]
do
  case "$1" in
    (-i) inputDir="$2"; shift;;
    (--inputDir) inputDir="$2"; shift;;
    (-c) inputDir="$2"; shift;;
    (--commandFile) command_file="$2"; shift;;
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
    movie_file="$1"
    file_without_extension="${movie_file%.*}"
    echo "$file_without_extension".suppl.json
}

export -f get_movie_meta_data_file

extract_creation_date_from_meta_data_file() {
    meta_data_file="$1"
    creation_date=$(jq .photoTakenTime.timestamp "${meta_data_file}")
    if [ -z $creation_date ] ; then
        return 1
    fi
    echo ${creation_date//\"/}
}

export -f extract_creation_date_from_meta_data_file

convert_epoch_date_to_exif_date() {
    epoch_date="$1"
    exif_date=$(date -r "$epoch_date" "+%Y:%m:%d %H:%M:%S")
    echo $exif_date
}

export -f convert_epoch_date_to_exif_date

convert_exif_date_to_epoch_date() {
    exif_date="$1"
    epoch_date=$(date -j -f "%Y:%m:%d %H:%M:%S" "$exif_date" +%s)
    echo $epoch_date
}

export -f convert_exif_date_to_epoch_date

abs() {
    value="$1"
    absolute_value=${value%-}
    echo $absolute_value
}

export -f abs

months_between_dates() {
    date1=$(abs "$1")
    date2=$(abs "$2")
    months_between_dates="$(( ($date2-$date1)/2592000 ))"
    echo $months_between_dates
}

export -f months_between_dates

apply_extracted_date_to_photo_or_movie_file() {
    file_name="$1"
    file_create_date_as_epoch="$2"
    command_file="$3"
    file_create_date_as_exif=$(convert_epoch_date_to_exif_date "$file_create_date_as_epoch")
    photo_create_date_as_exif_tuple=$(exiftool -CreateDate "$file_name")
    photo_create_date_as_exif=${photo_create_date_as_exif_tuple#Create Date*: }
    photo_create_date_as_epoch=$(convert_exif_date_to_epoch_date "$photo_create_date_as_exif")
    months_between=$(months_between_dates "$file_create_date_as_epoch" $photo_create_date_as_epoch)
    echo >&2 file create date $file_create_date_as_exif
    echo >&2 photo create date $photo_create_date_as_exif
    echo >&2 months between $months_between
    echo >&2 command file $command_file
    if [[ $months_between > 12 ]] ; then
        echo applying file creation date to photo "$file_name" >> "$HOME/gphotoexifupdater.sh"
    fi
}

export -f apply_extracted_date_to_photo_or_movie_file

update_jpeg_file_modified_date_with_extracted_meta_data() {
    file_name="$1"
    command_file="$2"
    meta_data_file=$(get_photo_meta_data_file "$file_name")
    extracted_creation_date=$(extract_creation_date_from_meta_data_file "$meta_data_file")
    if [ $extracted_creation_date ] ; then
        apply_extracted_date_to_photo_or_movie_file "$file_name" $extracted_creation_date "$command_file"
    else
        echo
        return 1
    fi
    echo
}

export -f update_jpeg_file_modified_date_with_extracted_meta_data

update_mp4_file_modified_date_with_extracted_meta_data() {
    file_name="$1"
    meta_data_file=$(get_photo_meta_data_file "$file_name")
    echo meta data file: "${meta_data_file}"
    echo
}

export -f update_mp4_file_modified_date_with_extracted_meta_data

echo > "$command_file"
find "$inputDir" -type f -iname '*.jpg' -exec sh -c 'update_jpeg_file_modified_date_with_extracted_meta_data "{}" "$command_file"' \;