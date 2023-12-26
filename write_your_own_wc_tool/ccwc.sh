#!/usr/bin/bash

ccwc() {
    if [[ "$#" -eq 0 ]]; then
        echo "Usage: ccwc [-l] [-c] [-m] [-w] <filename>"
        return
    fi

    local count_lines=false
    local count_bytes=false
    local count_characters=false
    local count_words=false
    local file=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            -l)
                count_lines=true
                shift
                ;;
            -c)
                count_bytes=true
                shift
                ;;
            -m)
                count_characters=true
                shift
                ;;
            -w)
                count_words=true
                shift
                ;;
            *)
                file="$1"
                shift
                ;;
        esac
    done

    if [ -z "$file" ]; then
        if [ "$count_lines" = true ]; then
            lines=0
            while IFS= read -r _; do
                ((lines++))
            done < /dev/stdin
            printf "%8d\n" "$lines"
            return
        fi
        echo "Error: Please provide a filename."
        return
    fi

    if [ ! -e "$file" ]; then
        echo "Error: File '$file' not found."
        return
    fi

    if [ "$count_lines" = true ]; then
        lines=0
        while IFS= read -r _; do
            ((lines++))
        done < "$file"
        printf "%8d %s\n" "$lines" "$file"
        
    elif [ "$count_bytes" = true ]; then
        bytes=$(stat -c %s "$file")
        printf "%8d %s\n" "$bytes" "$file"
        
    elif [ "$count_characters" = true ]; then
        char_count=0
        while IFS= read -r -n 1 char; do
            ((char_count++))
        done < "$file"
        printf "%8d %s\n" "$char_count" "$file"

    elif [ "$count_words" = true ]; then
        words=$(grep -o '\S\+' "$file" | ccwc -l)
        printf "%8d %s\n" "$words" "$file"
    
    else
        lines=$(ccwc -l "$file" | awk '{print $1}')
        words=$(ccwc -w "$file" | awk '{print $1}')
        bytes=$(ccwc -c "$file" | awk '{print $1}')
        printf "%8d %d %d %s\n" "$lines" "$words" "$bytes" "$file"
    fi
}
