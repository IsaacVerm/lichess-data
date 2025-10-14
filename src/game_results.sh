# create header
echo 'id,status,white_id,white_rating,black_id,black_rating,winner' > data/game_results.csv

# extract values
jq -r '[.id, .status, .players.white.user.id, .players.white.rating, .players.black.user.id, .players.black.rating, .winner] | @csv' data/games.ndjson >> data/game_results.csv

# add my_score
awk -F, '
BEGIN {OFS=","}
NR==1 {print $0,"my_score"; next}
{
    status=$2; white_id=$3; black_id=$5; winner=$7
    my_score=0
    if (white_id ~ /indexinator/ && winner ~ /white/) my_score=1
    if (black_id ~ /indexinator/ && winner ~ /black/) my_score=1
    if (status ~ /draw/) my_score=0.5
    print $0,my_score
}
' data/game_results.csv > data/game_results.tmp.csv

mv data/game_results.tmp.csv data/game_results.csv