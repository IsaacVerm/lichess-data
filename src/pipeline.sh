# clean out previous data (only raw data is kept)
rm data/enrich/*
rm data/filter/*
rm data/agg/*
rm lichess.db

# enrich
sqlite-utils memory data/raw/puzzles_puzzle_storm.csv "$(cat src/enrich/enrich_puzzles_puzzle_storm.sql)" --csv \
    > data/enrich/enrich_puzzles_puzzle_storm.csv

# filter
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/filter/10_random_puzzles.sql)" --csv \
    > data/filter/10_random_puzzles.csv
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/filter/focus_training_sets.sql)" --csv \
    > data/filter/focus_training_sets.csv

# agg
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/agg/dashboard_by_session.sql)" --csv \
    > data/agg/dashboard_by_session.csv

# insert
sqlite-utils insert lichess.db puzzles data/enrich/enrich_puzzles_puzzle_storm.csv --csv --detect-types
sqlite-utils insert lichess.db dashboard data/agg/dashboard_by_session.csv --csv --detect-types
