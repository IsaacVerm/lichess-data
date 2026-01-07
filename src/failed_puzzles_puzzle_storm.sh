#!/bin/bash

# After each session of Puzzle Storm I save the failed puzzles to Google Drive in the Puzzle Storm folder
# Each failed puzzle is a text file in that folder
# This script compiles the Lichess puzzle URLs from these text files into a CSV file
# Files are expected to be named: Untitled, Untitled(1).txt, Untitled(2).txt, etc.
# Each file should contain a single URL
# You first have to manually download the folder with failed puzzles before you can launch the script

# Directory containing the URL files (default to current directory)
DIR="${1:-.}"

# Check if directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' does not exist" >&2
    exit 1
fi

# Collect URLs into an array
urls=()

# Find all files matching the pattern and process them
# Match: Untitled, Untitled(1).txt, Untitled(2).txt, etc.
while IFS= read -r file; do
    # Read the URL from the file (trim whitespace)
    url=$(tr -d '\r\n' < "$file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Skip empty files
    if [ -n "$url" ]; then
        # Escape backslashes and single quotes in URLs
        url="${url//\\/\\\\}"
        url="${url//\'/\\\'}"
        urls+=("$url")
    fi
done < <(find "$DIR" -maxdepth 1 -type f \( -name "Untitled" -o -name "Untitled*.txt" \) | sort -V)

# Save urls as a csv file failed_puzzles_puzzle_storm.csv
OUTPUT_FILE="failed_puzzles_puzzle_storm.csv"

# Write CSV header
echo "url" > "$OUTPUT_FILE"

# Write each URL to the CSV file
for url in "${urls[@]}"; do
    echo "$url" >> "$OUTPUT_FILE"
done

echo "Successfully saved ${#urls[@]} URLs to $OUTPUT_FILE"

# Print URLs in array format
echo "["
for i in "${!urls[@]}"; do
    if [ $i -eq $((${#urls[@]} - 1)) ]; then
        # Last element - no comma
        echo "            '${urls[$i]}'"
    else
        # Not last element - add comma
        echo "            '${urls[$i]}',"
    fi
done
echo "]"