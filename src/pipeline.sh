# enrich_puzzles_puzzle_storm
sqlite-utils memory data/raw/puzzles_puzzle_storm.csv "$(cat src/enrich/enrich_puzzles_puzzle_storm.sql)" --csv \
    > data/enrich/enrich_puzzles_puzzle_storm.csv