# create header
echo 'id,eco' > data/games.csv

# extract values
jq -r '[.id, .opening.eco] | @csv' data/games.ndjson >> data/games.csv
