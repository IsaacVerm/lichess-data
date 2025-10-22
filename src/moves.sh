jq -r '
  (.moves | split(" ")) as $moves
  | (.analysis | map(.eval)) as $evals
  | [$moves, .clocks, $evals] | transpose[]
  | @csv
' data/games_example.ndjson > data/moves.csv