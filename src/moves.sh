# the last element in clocks might contain the time of resigning which we don't care about
# id has to be variable because if not you try to access index of the loop in $repeated_id so 0.id instead of json.id

jq -r '
  .id as $id 
  | (.moves | split(" ")) as $moves
  | (.clocks[:-1]) as $clocks 
  | ([range(0, $moves | length) | $id]) as $repeated_id
  | (.analysis | map(.eval)) as $evals
  | [$repeated_id, $moves, $clocks, $evals] | transpose[]
  | @csv
' data/games.ndjson > data/moves.csv