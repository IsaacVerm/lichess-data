# clean out previous data (only raw data is kept)
rm data/enrich/*
rm data/filter/*
rm data/agg/*

# enrich
sqlite-utils memory data/raw/puzzles_puzzle_storm.csv "$(cat src/enrich/enrich_puzzles_puzzle_storm.sql)" --csv \
    > data/enrich/enrich_puzzles_puzzle_storm.csv

# filter
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/filter/easy-puzzles-failed-today-or-yesterday.sql)" --csv \
    > data/filter/easy-puzzles-failed-today-or-yesterday.csv

# agg
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/agg/first-fail-by-run.sql)" --csv \
    > data/agg/first-fail-by-run.csv