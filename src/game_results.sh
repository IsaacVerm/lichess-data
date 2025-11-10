# create header
echo 'id,status,my_rating,my_score,my_color' > data/game_results.csv

# extract values
jq -r '[.id, .status, .players.white.user.id, .players.white.rating, .players.black.user.id, .players.black.rating, .winner] | @csv' data/games.ndjson >> data/game_results.csv

# add my_score
awk -F, '
BEGIN {OFS=","}
NR==1 {print $0; next}
{
    id=$1
    status=$2

    white_id=$3
    black_id=$5

    white_rating=$4
    black_rating=$6

    winner=$7

    my_rating=white_rating
    if (black_id ~ /indexinator/) my_rating=black_rating

    my_score=0
    if (white_id ~ /indexinator/ && winner ~ /white/) my_score=1
    if (black_id ~ /indexinator/ && winner ~ /black/) my_score=1
    if (status ~ /draw|stalemate/) my_score=0.5

    my_color="white"
    if (black_id ~ /indexinator/) my_color="black"

    print $1,$2,my_rating,my_score,my_color
}
' data/game_results.csv > data/game_results.tmp.csv

mv data/game_results.tmp.csv data/game_results.csv