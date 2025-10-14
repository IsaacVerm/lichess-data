# create header
echo 'id,status,white_id,white_rating,black_id,black_rating' > data/game_results.csv

# extract values
jq -r '[.id, .status, .players.white.user.id, .players.white.rating, .players.black.user.id, .players.black.rating] | @csv' data/games.ndjson >> data/game_results.csv