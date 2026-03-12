# clean out previous data (only raw data is kept)
find data/enrich -type f -delete 2>/dev/null || true
find data/filter -type f -delete 2>/dev/null || true
find data/agg -type f -delete 2>/dev/null || true

# fetch puzzle themes from Lichess API for all failed puzzles
bash src/raw/fetch_puzzle_themes.sh

# enrich
sqlite-utils memory data/raw/puzzles_puzzle_storm.csv data/raw/raw_puzzle_themes.csv "$(cat src/enrich/enrich_puzzles_puzzle_storm.sql)" --csv \
    > data/enrich/enrich_puzzles_puzzle_storm.csv

# filter
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/filter/recent-puzzles-failed.sql)" --csv \
    > data/filter/recent-puzzles-failed.csv
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/filter/hardest-puzzles-failed.sql)" --csv \
    > data/filter/hardest-puzzles-failed.csv
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/filter/10-random-puzzles.sql)" --csv \
    > data/filter/10-random-puzzles.csv
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/filter/puzzles_advantage.sql)" --csv \
    > data/filter/puzzles_advantage.csv

# agg
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/agg/first-fail-by-run.sql)" --csv \
    > data/agg/first-fail-by-run.csv
sqlite-utils memory data/enrich/enrich_puzzles_puzzle_storm.csv "$(cat src/agg/stats-first-fail-by-date.sql)" --csv \
    > data/agg/stats-first-fail-by-date.csv
