# lichess-data

For now I just fetch [Lichess games](https://lichess.org/api#tag/Games/operation/apiGamesUser) I played.

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

## CSV files

I want a separate CSV file for each concept:

### `game_results`

- `id`
- `status`
- `players.white.user.id`
- `players.white.rating`
- `players.black.user.id`
- `players.black.rating`

If `status` is "draw", there's no `winner` field.

`rating` is rating at the moment the game was played.

### other files

- openings
    - game id
    - opening
- game evolution
    - game id
    - division (opening, middlegame, endgame)
- moves