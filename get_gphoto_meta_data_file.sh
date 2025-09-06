#!/bin/bash

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
echo >&2 length of file name $length_of_file_name
echo >&2 length of suffix $length_of_suffix
echo >&2 total length $total_length max length $MAX_LENGTH
if [[ $total_length -gt $MAX_LENGTH ]] ; then
    number_of_characters_to_keep=$(( ${#shortened_suffix}-1 ))
    echo >&2 number of characters to keep: $number_of_characters_to_keep
    excess_length=$(( total_length-MAX_LENGTH ))
    echo >&2 excess length $excess_length
    if [[ excess_length -ge 0 ]] ; then
        number_of_characters_to_keep=$(( number_of_characters_to_keep-excess_length ))
    fi
    echo >&2 number of characters to keep after shortening: $number_of_characters_to_keep
    if [[ number_of_characters_to_keep -ge 0 ]] ; then
        shortened_suffix=${suffix_for_json_files::number_of_characters_to_keep}
        echo >&2 number of characters to keep $number_of_characters_to_keep
        echo >&2 shortened suffix: \"$shortened_suffix\"
        echo "$photo_file"$shortened_suffix.json
    else
        photo_file_without_jpg=${photo_file%.jpg}
        photo_file_base_name_without_jpg=${photo_file_base_name%.jpg}
        length_of_file_name_without_jpg=${#photo_file_base_name_without_jpg}
        total_length_without_jpg=$(( length_of_file_name_without_jpg+length_of_suffix+length_of_json_extension ))
        echo >&2 length of file name without jpg $length_of_file_name_without_jpg
        echo >&2 length of suffix $length_of_suffix
        echo >&2 total length $total_length_without_jpg max length $MAX_LENGTH
        if [[ $total_length_without_jpg -gt $MAX_LENGTH ]] ; then
            number_of_characters_to_keep=$(( ${#shortened_suffix}-1 ))
            echo >&2 number of characters to keep: $number_of_characters_to_keep
            excess_length_without_jpg=$(( total_length_without_jpg-MAX_LENGTH ))
            echo >&2 excess length without jpg $excess_length
            if [[ excess_length_without_jpg -ge 0 ]] ; then
                number_of_characters_to_keep=$(( number_of_characters_to_keep-excess_length_without_jpg ))
            fi
            echo >&2 number of characters to keep after shortening: $number_of_characters_to_keep
            if [[ number_of_characters_to_keep -ge 0 ]] ; then
                shortened_suffix=${suffix_for_json_files::number_of_characters_to_keep}
                echo >&2 number of characters to keep $number_of_characters_to_keep
                echo >&2 shortened suffix: \"$shortened_suffix\"
                echo "$photo_file_without_jpg"$shortened_suffix.json
            else
                echo >&2 cannot create metadata filename for: \"$photo_file\"
                exit 1
            fi
        else
            echo "$photo_file_without_jpg"$shortened_suffix.json
        fi
    fi
else
    echo "$photo_file"$shortened_suffix.json
fi