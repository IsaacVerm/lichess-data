#!/bin/bash

# This script enriches failed puzzle data by fetching puzzle details from the Lichess API
# It reads puzzle URLs from data/failed_puzzles_puzzle_storm.csv
# and saves enriched data to data/enriched_failed_puzzles_puzzle_storm.csv
# 
# Required fields from API response:
# - game.id
# - puzzle.id
# - puzzle.rating
# - puzzle.initialPly

INPUT_FILE="data/failed_puzzles_puzzle_storm.csv"
OUTPUT_FILE="data/enriched_failed_puzzles_puzzle_storm.csv"
TEMP_FILE="data/enriched_failed_puzzles_puzzle_storm.tmp.csv"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' does not exist" >&2
    exit 1
fi

# Create CSV header
echo "game_id,puzzle_id,puzzle_rating,puzzle_initial_ply" > "$OUTPUT_FILE"

# Read each URL from the CSV file (skip header)
tail -n +2 "$INPUT_FILE" | while IFS= read -r url; do
    # Extract puzzle ID from URL
    # URL format: https://lichess.org/training/{puzzle_id}
    puzzle_id=$(echo "$url" | awk -F'/' '{print $NF}')
    
    # Skip empty lines
    if [ -z "$puzzle_id" ]; then
        continue
    fi
    
    echo "Fetching puzzle: $puzzle_id" >&2
    
    # Fetch puzzle data from Lichess API
    response=$(curl -s "https://lichess.org/api/puzzle/$puzzle_id")
    
    # Check if response is empty or contains an error
    if [ -z "$response" ] || echo "$response" | jq -e '.error' > /dev/null 2>&1; then
        echo "Warning: Failed to fetch puzzle $puzzle_id" >&2
        # Write a row with the puzzle_id and empty values for other fields
        echo ",$puzzle_id,," >> "$OUTPUT_FILE"
        continue
    fi
    
    # Extract required fields using jq
    game_id=$(echo "$response" | jq -r '.game.id // ""')
    puzzle_rating=$(echo "$response" | jq -r '.puzzle.rating // ""')
    puzzle_initial_ply=$(echo "$response" | jq -r '.puzzle.initialPly // ""')
    
    # Write to CSV file
    echo "$game_id,$puzzle_id,$puzzle_rating,$puzzle_initial_ply" >> "$OUTPUT_FILE"
    
    # Add a small delay to avoid rate limiting (optional)
    sleep 0.1
done

echo "Successfully enriched puzzle data saved to $OUTPUT_FILE"
