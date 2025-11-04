# lichess-data

[Lichess games I played](https://lichess.org/api#tag/Games/operation/apiGamesUser) are fetched and then cleaned using `jq`, `awk` and [`sqlite-utils`](https://sqlite-utils.datasette.io/en/stable/index.html). I'm not sure I'll keep using `sqlite-utils`, but SQL often is a lot less awkward than `awk`.

## Setup

[Install sqlite-utils](https://sqlite-utils.datasette.io/en/stable/installation.html#using-pip).

## Run scripts

E.g. to fetch my games.

```
chmod +x fetch_games.sh
./fetch_games.sh
```

## Each concept is a CSV file

I have a separate CSV file for each concept (opening, game result,...).
I use [the star schema as recommended in Power BI](https://learn.microsoft.com/en-us/power-bi/guidance/star-schema). 
`games` is the fact table containing only keys to link to `openings`, `game_results`,... which are dimension tables.