#!/bin/bash

# This script creates failed_puzzles.csv with puzzle URLs
# It reads from data/enriched_failed_puzzles_puzzle_storm.csv
# and adds a puzzle_url column with format: https://lichess.org/{game_id}#{puzzle_initial_ply + 1}

# Get the script's directory and navigate to repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit 1

INPUT_FILE="data/enriched_failed_puzzles_puzzle_storm.csv"
OUTPUT_FILE="data/failed_puzzles.csv"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' does not exist" >&2
    exit 1
fi

# Create CSV header
echo "game_id,puzzle_id,puzzle_rating,puzzle_initial_ply,puzzle_url" > "$OUTPUT_FILE"

# Read each line from the CSV file (skip header)
# The || [ -n "$game_id" ] ensures the last line is processed even if it doesn't end with a newline
tail -n +2 "$INPUT_FILE" | while IFS=, read -r game_id puzzle_id puzzle_rating puzzle_initial_ply || [ -n "$game_id" ]; do
    # Skip empty lines
    if [ -z "$game_id" ]; then
        continue
    fi
    
    # Calculate puzzle_initial_ply + 1
    if [ -n "$puzzle_initial_ply" ]; then
        ply_plus_one=$((puzzle_initial_ply + 1))
    else
        ply_plus_one=""
    fi
    
    # Construct puzzle URL
    if [ -n "$game_id" ] && [ -n "$ply_plus_one" ]; then
        puzzle_url="https://lichess.org/${game_id}#${ply_plus_one}"
    else
        puzzle_url=""
    fi
    
    # Write to CSV file
    echo "$game_id,$puzzle_id,$puzzle_rating,$puzzle_initial_ply,$puzzle_url" >> "$OUTPUT_FILE"
done

echo "Successfully created $OUTPUT_FILE with puzzle URLs"
