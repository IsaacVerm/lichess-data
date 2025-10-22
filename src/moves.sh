jq -r '
  .id as $id # id has to be variable because if not you try to access index of the loop in $repeated_id so 0.id instead of json.id
  | (.moves | split(" ")) as $moves
  | ([range(0, $moves | length) | $id]) as $repeated_id
  | (.analysis | map(.eval)) as $evals
  | [$repeated_id, $moves, .clocks, $evals] | transpose[]
  | @csv
' data/games_example.ndjson > data/moves.csv