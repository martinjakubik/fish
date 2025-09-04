#!/bin/bash

MAX_LENGTH=52
photo_file="$1"
photo_file_base_name=$(basename "$photo_file")
length_of_file_name=${#photo_file_base_name}
suffix_for_json_files=supplemental-metadata
shortened_suffix=$suffix_for_json_files
length_of_suffix=${#shortened_suffix}
total_length=$(( length_of_file_name+length_of_suffix+5 ))
echo >&2 length of file name $length_of_file_name
echo >&2 length of suffix $length_of_suffix
echo >&2 total length $total_length max length $MAX_LENGTH
if [[ $total_length -gt $MAX_LENGTH ]] ; then
    number_of_characters_to_keep=26
    excess_length=$(( total_length-MAX_LENGTH-5 ))
    echo >&2 excess length $excess_length
    if [[ excess_length -ge 0 ]] ; then
        number_of_characters_to_keep=$(( 26-excess_length ))
    fi
    if [[ number_of_characters_to_keep -ge 0 ]] ; then
        shortened_suffix=${suffix_for_json_files::number_of_characters_to_keep}
        echo >&2 number of characters to keep $number_of_characters_to_keep
        echo >&2 shortened suffix: \"$shortened_suffix\"
        echo "$photo_file".$shortened_suffix.json
    else
        echo cannot create metadata filename for: \"$photo_file\"
    fi
else
    echo "$photo_file".$shortened_suffix.json
fi
