# extract values
jq -r '[.opening.eco, .opening.name, .opening.ply] | @csv' data/games.ndjson >> data/openings.csv

# remove duplicates
sort -u data/openings.csv -o data/openings.csv

# create header
# header is added now instead of before because if not it might be deleted when removing duplicates with sort -u
sed '1i eco,name,ply' data/openings.csv > data/openings.csv.tmp && mv data/openings.csv.tmp data/openings.csv