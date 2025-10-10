# lichess-data

## Run `fetch_games` script

```
chmod +x fetch_games.sh
./fetch_games.sh
```

## Turn `NDJSON` data into CSV

You can do this using `jq`:

```
jq -r '. as $game | .moves | split(" ")[] | [$game.id, .] | @csv' data/games.ndjson > test.csv
```

`jq` will loop over each line so you don't have to explicitly define a loop yourself.