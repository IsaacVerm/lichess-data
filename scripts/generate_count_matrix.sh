#!/bin/bash

# Script to generate count_matrix.json from puzzles_puzzle_storm.json
# This groups puzzles by correctness (result: good/bad) and speed (clock: fast/slow)

INPUT_FILE="data/puzzles_puzzle_storm.json"
OUTPUT_FILE="data/count_matrix.json"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file $INPUT_FILE not found"
    exit 1
fi

# Generate count matrix using jq
# - Add speed field based on clock value (< 7 is fast, >= 7 is slow)
# - Add correctness field from result
# - Group by both correctness and speed
# - Count entries in each group
# - Sort for consistent output
jq '
  map(
    . + {
      speed: (if .clock < 7 then "fast" else "slow" end),
      correctness: .result
    }
  ) |
  group_by([.correctness, .speed]) |
  map({
    correctness: .[0].correctness,
    speed: .[0].speed,
    count: length
  }) |
  sort_by(.correctness, .speed)
' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE"
