#!/bin/bash
# sets up usage
USAGE="usage: $0 -i --inputDir inputDir -c --commandFile --require-exiftool yes|no -d --debug"

# set up defaults
DEBUG=0
REQUIRE_EXIFTOOL=0
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
    (--require-exiftool) requireExifTool="$2"; shift;;
    (-d) DEBUG=1;;
    (--debug) DEBUG=1;;
    (-*) echo >&2 ${USAGE}
    exit 1;;
  esac
  shift
done

if ! command -v jq >/dev/null 2>&1 ; then
    echo "jq could not be found"
    exit 1
fi

if ! command -v jhead >/dev/null 2>&1 ; then
    echo "jhead could not be found"
    exit 1
fi

if [[ $requireExifTool = 'yes' ]] ; then
    REQUIRE_EXIFTOOL=1
fi

if [[ $REQUIRE_EXIFTOOL -eq 1 ]] ; then
    if ! command -v exiftool >/dev/null 2>&1 ; then
        echo "exiftool could not be found"
        exit 1
    fi
fi

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

get_jpeg_photo_meta_data_file() {
    MAX_LENGTH=52
    photo_file="$1"
    photo_file_base_name=$(basename "$photo_file")
    length_of_file_name=${#photo_file_base_name}
    suffix_for_json_files=.supplemental-metadata
    shortened_suffix=$suffix_for_json_files
    length_of_suffix=${#shortened_suffix}
    json_extension=".json"
    length_of_json_extension=${#json_extension}
    total_length=$(( length_of_file_name+length_of_suffix+length_of_json_extension ))
    if [[ $DEBUG = 1 ]] ; then echo >&2 length of file name $length_of_file_name; fi
    if [[ $DEBUG = 1 ]] ; then echo >&2 length of suffix $length_of_suffix; fi
    if [[ $DEBUG = 1 ]] ; then echo >&2 total length $total_length max length $MAX_LENGTH; fi
    if [[ ${photo_file_base_name%[ ]-[ ]*[0-9].jpg} != ${photo_file_base_name} ]] ; then
        # checks edge case if file has a space-hyphen-space and then digits (ex. IMG1000 - 11.jpg)
        # and drops the .jpg from the metadata filename
        photo_file_without_jpg=${photo_file%.jpg}
        photo_file_base_name_without_jpg=${photo_file_base_name%.jpg}
        length_of_file_name_without_jpg=${#photo_file_base_name_without_jpg}
        total_length_without_jpg=$(( length_of_file_name_without_jpg+length_of_suffix+length_of_json_extension ))
        if [[ $DEBUG = 1 ]] ; then echo >&2 length of file name without jpg $length_of_file_name_without_jpg; fi
        if [[ $DEBUG = 1 ]] ; then echo >&2 length of suffix $length_of_suffix; fi
        if [[ $DEBUG = 1 ]] ; then echo >&2 total length $total_length_without_jpg max length $MAX_LENGTH; fi
        if [[ $total_length_without_jpg -gt $MAX_LENGTH ]] ; then
            number_of_characters_to_keep=$(( ${#shortened_suffix}-1 ))
            if [[ $DEBUG = 1 ]] ; then echo >&2 number of characters to keep: $number_of_characters_to_keep; fi
            excess_length_without_jpg=$(( total_length_without_jpg-MAX_LENGTH ))
            if [[ $DEBUG = 1 ]] ; then echo >&2 excess length without jpg $excess_length; fi
            if [[ excess_length_without_jpg -ge 0 ]] ; then
                number_of_characters_to_keep=$(( number_of_characters_to_keep-excess_length_without_jpg ))
            fi
            if [[ $DEBUG = 1 ]] ; then echo >&2 number of characters to keep after shortening: $number_of_characters_to_keep; fi
            if [[ number_of_characters_to_keep -ge 0 ]] ; then
                shortened_suffix=${suffix_for_json_files::number_of_characters_to_keep}
                if [[ $DEBUG = 1 ]] ; then echo >&2 number of characters to keep $number_of_characters_to_keep; fi
                if [[ $DEBUG = 1 ]] ; then echo >&2 shortened suffix: \"$shortened_suffix\"; fi
                echo "$photo_file_without_jpg"$shortened_suffix.json
            else
                echo >&2 cannot create metadata filename for: \"$photo_file\"
                exit 1
            fi
        else
            echo "$photo_file_without_jpg"$shortened_suffix.json
        fi
    elif [[ $total_length -gt $MAX_LENGTH ]] ; then
        # checks case if metadata file exceeds max length and tries to shorten it
        number_of_characters_to_keep=$(( ${#shortened_suffix}-1 ))
        if [[ $DEBUG = 1 ]] ; then echo >&2 number of characters to keep: $number_of_characters_to_keep; fi
        excess_length=$(( total_length-MAX_LENGTH ))
        if [[ $DEBUG = 1 ]] ; then echo >&2 excess length $excess_length; fi
        if [[ excess_length -ge 0 ]] ; then
            number_of_characters_to_keep=$(( number_of_characters_to_keep-excess_length ))
        fi
        if [[ $DEBUG = 1 ]] ; then echo >&2 number of characters to keep after shortening: $number_of_characters_to_keep; fi
        if [[  number_of_characters_to_keep -lt 0 ]] ; then
            # checks if metadata file name is still too long after shortening
            photo_file_without_jpg=${photo_file%.jpg}
            photo_file_base_name_without_jpg=${photo_file_base_name%.jpg}
            length_of_file_name_without_jpg=${#photo_file_base_name_without_jpg}
            total_length_without_jpg=$(( length_of_file_name_without_jpg+length_of_suffix+length_of_json_extension ))
            if [[ $DEBUG = 1 ]] ; then echo >&2 length of file name without jpg $length_of_file_name_without_jpg; fi
            if [[ $DEBUG = 1 ]] ; then echo >&2 length of suffix $length_of_suffix; fi
            if [[ $DEBUG = 1 ]] ; then echo >&2 total length $total_length_without_jpg max length $MAX_LENGTH; fi
            if [[ $total_length_without_jpg -gt $MAX_LENGTH ]] ; then
                # checks if dropping the .jpg from the original file shortens the metadata file name enough
                number_of_characters_to_keep=$(( ${#shortened_suffix}-1 ))
                if [[ $DEBUG = 1 ]] ; then echo >&2 number of characters to keep: $number_of_characters_to_keep; fi
                excess_length_without_jpg=$(( total_length_without_jpg-MAX_LENGTH ))
                if [[ $DEBUG = 1 ]] ; then echo >&2 excess length without jpg $excess_length; fi
                if [[ excess_length_without_jpg -ge 0 ]] ; then
                    number_of_characters_to_keep=$(( number_of_characters_to_keep-excess_length_without_jpg ))
                fi
                if [[ $DEBUG = 1 ]] ; then echo >&2 number of characters to keep after shortening: $number_of_characters_to_keep; fi
                if [[ number_of_characters_to_keep -ge 0 ]] ; then
                    shortened_suffix=${suffix_for_json_files::number_of_characters_to_keep}
                    if [[ $DEBUG = 1 ]] ; then echo >&2 number of characters to keep $number_of_characters_to_keep; fi
                    if [[ $DEBUG = 1 ]] ; then echo >&2 shortened suffix: \"$shortened_suffix\"; fi
                    echo "$photo_file_without_jpg"$shortened_suffix.json
                else
                    echo >&2 cannot create metadata filename for: \"$photo_file\"
                    exit 1
                fi
            else
                echo "$photo_file_without_jpg"$shortened_suffix.json
            fi
        elif [[ number_of_characters_to_keep -ge 0 ]] ; then
            # checks case when metadata suffix can be shortened by a few characters and
            # if this allows it to fit
            shortened_suffix=${suffix_for_json_files::number_of_characters_to_keep}
            if [[ $DEBUG = 1 ]] ; then echo >&2 number of characters to keep $number_of_characters_to_keep; fi
            if [[ $DEBUG = 1 ]] ; then echo >&2 shortened suffix: \"$shortened_suffix\"; fi
            echo "$photo_file"$shortened_suffix.json
        fi
    else
        # uses the entire suffix for the metadata file name
        echo "$photo_file"$shortened_suffix.json
    fi
    # note: here is a regular expression to find long file names
    # ^[^/]+/[^/]+/[^/]+/[^/]+/[^/]+/.{48}\.jpg
}

export -f get_jpeg_photo_meta_data_file

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
    DEBUG=$2
    exif_date=$(date -r "$epoch_date" "+%Y:%m:%d-%H:%M:%S")
    echo $exif_date
}

export -f convert_epoch_date_to_exif_date

convert_exif_date_to_epoch_date() {
    exif_date="$1"
    DEBUG=$2
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
    DEBUG=$3
    months_between_dates="$(( ($date2-$date1)/2592000 ))"
    echo $months_between_dates
}

export -f months_between_dates

apply_extracted_date_to_photo_or_movie_file() {
    file_name="$1"
    json_metadata_create_date_as_epoch="$2"
    command_file="$3"
    DEBUG=$4
    file_create_date_as_exif=$(convert_epoch_date_to_exif_date "$json_metadata_create_date_as_epoch" $DEBUG)
    photo_create_date_as_exif_tuple=$(jhead "$file_name" | grep Date/Time)
    if [[ ! -z $photo_create_date_as_exif_tuple ]] ; then
        photo_create_date_as_exif=${photo_create_date_as_exif_tuple#Date/Time*: }
        photo_create_date_as_epoch=$(convert_exif_date_to_epoch_date "$photo_create_date_as_exif" $DEBUG)
        months_between=$(months_between_dates "$json_metadata_create_date_as_epoch" $photo_create_date_as_epoch $DEBUG)
        if [[ $months_between > 12 ]] ; then
            echo jhead -ts\"$file_create_date_as_exif\" \"$file_name\" >> "$HOME/gphotoexifupdater.sh"
        fi
    fi
}

export -f apply_extracted_date_to_photo_or_movie_file

update_jpeg_file_modified_date_with_extracted_meta_data() {
    file_name="$1"
    command_file="$2"
    DEBUG=$3
    if meta_data_file=$(get_jpeg_photo_meta_data_file "$file_name" $DEBUG) ; then
        extracted_creation_date=$(extract_creation_date_from_meta_data_file "$meta_data_file" $DEBUG)
        if [ $extracted_creation_date ] ; then
            apply_extracted_date_to_photo_or_movie_file "$file_name" $extracted_creation_date "$command_file" $DEBUG
        else
            if [[ $DEBUG = 1 ]] ; then echo ; fi
            return 1
        fi
        if [[ $DEBUG = 1 ]] ; then echo ; fi
    fi
}

export -f update_jpeg_file_modified_date_with_extracted_meta_data

update_webp_file_modified_date_with_extracted_meta_data() {
    file_name="$1"
    command_file="$2"
    DEBUG=$3
    meta_data_file=$(get_webp_photo_meta_data_file "$file_name")
    extracted_creation_date=$(extract_creation_date_from_meta_data_file "$meta_data_file")
    if [ $extracted_creation_date ] ; then
        apply_extracted_date_to_photo_or_movie_file "$file_name" $extracted_creation_date "$command_file" $DEBUG
    else
        if [[ $DEBUG = 1 ]] ; then echo ; fi
        return 1
    fi
    if [[ $DEBUG = 1 ]] ; then echo ; fi
}

export -f update_webp_file_modified_date_with_extracted_meta_data

update_mp4_file_modified_date_with_extracted_meta_data() {
    file_name="$1"
    meta_data_file=$(get_jpeg_photo_meta_data_file "$file_name")
    echo meta data file: "${meta_data_file}"
    echo
}

export -f update_mp4_file_modified_date_with_extracted_meta_data

echo > "$command_file"
if [[ $DEBUG = 1 ]] ; then
    find "$inputDir" -type f -iname '*.jpg' -ok sh -c 'update_jpeg_file_modified_date_with_extracted_meta_data "{}" "$command_file" 1' \;
else
    find "$inputDir" -type f -iname '*.jpg' -exec sh -c 'update_jpeg_file_modified_date_with_extracted_meta_data "{}" "$command_file"' \;
fi