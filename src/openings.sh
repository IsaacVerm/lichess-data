# create header
echo 'game_id,opening' > data/openings.csv

# extract values
jq -r '[.id, .opening.name] | @csv' data/games.ndjson >> data/openings.csv
