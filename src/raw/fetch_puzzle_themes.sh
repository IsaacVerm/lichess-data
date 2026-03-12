#!/bin/bash

# Fetch puzzle themes from Lichess API for all failed puzzles
# Saves results to data/raw/raw_puzzle_themes.csv
# Usage: bash src/raw/fetch_puzzle_themes.sh

set -e

OUTPUT="data/raw/raw_puzzle_themes.csv"

echo "puzzle_id,themes" > "$OUTPUT"

# Extract unique puzzle IDs for bad result puzzles
# href format is /training/{puzzle_id}, result is the 6th field
tail -n +2 data/raw/puzzles_puzzle_storm.csv | \
  awk -F',' '$6 == "bad" {print $5}' | \
  sed 's|.*/||' | \
  sort -u | \
  while IFS= read -r puzzle_id; do
    response=$(curl -s --max-time 10 "https://lichess.org/api/puzzle/$puzzle_id")
    themes=$(echo "$response" | jq -c '.puzzle.themes // empty' 2>/dev/null)
    if [ -z "$themes" ]; then
      echo "Warning: no themes for puzzle $puzzle_id, skipping" >&2
      sleep 1
      continue
    fi
    # Escape double quotes for CSV (double them) and wrap in quotes
    themes_csv=$(echo "$themes" | sed 's/"/""/g')
    echo "$puzzle_id,\"$themes_csv\""
    sleep 1
  done >> "$OUTPUT"

echo "Saved puzzle themes to $OUTPUT"
