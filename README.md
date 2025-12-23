# lichess-data

[Lichess games I played](https://lichess.org/api#tag/Games/operation/apiGamesUser) are fetched and then cleaned using `jq`, `awk` and [`sqlite-utils`](https://sqlite-utils.datasette.io/en/stable/index.html). I'm not sure I'll keep using `sqlite-utils`, but SQL often is a lot less awkward than `awk`.



## Setup

[Install sqlite-utils](https://sqlite-utils.datasette.io/en/stable/installation.html#using-pip):

```
pip install sqlite-utils
```

Install [datasette](https://github.com/simonw/datasette?tab=readme-ov-file#installation):

```
pip install datasette
```

## Tables by concept

I have a separate CSV file for each concept (opening, game result,...).
I use [the star schema as recommended in Power BI](https://learn.microsoft.com/en-us/power-bi/guidance/star-schema). 
`games` is the fact table containing only keys to link to `openings`, `game_results`,... which are dimension tables.

E.g. scripts to run to fetch my games:

```
chmod +x fetch_games.sh
./fetch_games.sh
```

To enrich failed Puzzle Storm puzzles with details from the Lichess API:

```
chmod +x src/enrich_failed_puzzles_puzzle_storm.sh
cd src
./enrich_failed_puzzles_puzzle_storm.sh
```

This will read `data/failed_puzzles_puzzle_storm.csv` and create `data/enriched_failed_puzzles_puzzle_storm.csv` with the following fields:
- `game_id` - The ID of the game the puzzle came from
- `puzzle_id` - The puzzle ID
- `puzzle_rating` - The puzzle difficulty rating
- `puzzle_initial_ply` - The move number where the puzzle starts

## Explore data

I use `datasette` to explore my data.
E.g. check `game_results`:

```
sqlite-utils insert game_results.db game_results data/game_results.csv --csv
datasette serve game_results.db
```