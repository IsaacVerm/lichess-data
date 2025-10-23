# create header
echo 'game_id,ply,move,clock,eval,type_of_mistake,end_opening' > data/moves.csv

# the last element in clocks might contain the time of resigning which we don't care about
# id has to be variable because if not you try to access index of the loop in $repeated_id so 0.id instead of json.id
jq -r '
  .id as $id
  | (.division.middle) as $end_opening_ply
  | (.moves | split(" ")) as $moves
  | range(0; $moves | length) as $i
  | [
      $id,
      $i+1,
      $moves[$i],
      .clocks[$i],
      .analysis[$i].eval,
      .analysis[$i].judgment.name,
      (if $i == $end_opening_ply then 1 else 0 end)
    ]
  | @csv
' data/games.ndjson >> data/moves.csv