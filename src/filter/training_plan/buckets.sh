#!/bin/bash

INPUT="data/enrich/enrich_puzzles_puzzle_storm.csv"
OUTPUT_DIR="data/filter/training_plan"

mkdir -p "$OUTPUT_DIR"

awk -F',' -v output_dir="$OUTPUT_DIR" '
NR == 1 {
    header = $0
    next
}
{
    rank = $10
    bucket = int((rank - 1) / 20) + 1
    file = output_dir "/bucket_" bucket ".csv"
    if (!(file in headers_written)) {
        print header > file
        headers_written[file] = 1
    }
    print $0 >> file
}' "$INPUT"
