#!/bin/bash

# Script to generate count_matrix.json from puzzles_puzzle_storm.json
# This groups puzzles by rating range, correctness (result: good/bad) and speed (clock: fast/slow)

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
# - Add rating_range field based on rating (e.g., "1000-1100", "1100-1200")
# - Add rating_floor for numeric sorting
# - Group by rating range, correctness and speed
# - Count entries in each group
# - Sort for consistent output (numerically by rating_floor)
if ! jq '
  map(
    (((.rating / 100) | floor) * 100) as $rating_floor |
    . + {
      speed: (if .clock < 7 then "fast" else "slow" end),
      correctness: .result,
      rating_range: "\($rating_floor)-\($rating_floor + 100)",
      rating_floor: $rating_floor
    }
  ) |
  group_by([.rating_floor, .correctness, .speed]) |
  map({
    rating_range: .[0].rating_range,
    correctness: .[0].correctness,
    speed: .[0].speed,
    count: length
  }) |
  sort_by(.rating_range, .correctness, .speed)
' "$INPUT_FILE" > "$OUTPUT_FILE"; then
    echo "Error: jq command failed"
    exit 1
fi

echo "Generated $OUTPUT_FILE"
