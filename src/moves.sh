# create header
echo 'game_id,ply,move,clock,eval,blunder,end_opening' > data/moves.csv

# the last element in clocks might contain the time of resigning which we don't care about
# id has to be variable because if not you try to access index of the loop in $repeated_id so 0.id instead of json.id
jq -r '
  .id as $id
  | (.division.middle) as $end_opening_ply
  | (.moves | split(" ")) as $moves
  | (.clocks[:-1]) as $clocks
  | (.analysis | map(.eval)) as $evals
  | (.analysis | map(if .judgment.name == "Blunder" then 1 else 0 end)) as $blunders
  | range(0; $moves | length) as $i
  | [
      $id,
      $i+1,
      $moves[$i],
      $clocks[$i],
      $evals[$i],
      $blunders[$i],
      (if $i == $end_opening_ply then 1 else 0 end)
    ]
  | @csv
' data/games.ndjson >> data/moves.csv