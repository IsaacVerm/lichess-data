# lichess-data

Repo to track my progress in Lichess, both with puzzles as games.
At the moment I focus on [Puzzle Storm](https://lichess.org/storm) puzzles, but in time I also want to analyse my games and the relationship between puzzle and game performance. 

## Setup

### Local

[Datasette](https://datasette.io/) is used to analyse the data and is used in combination with `sqlite-utils` (to convert CSV to `sqlite` databases):

[Install sqlite-utils](https://sqlite-utils.datasette.io/en/stable/installation.html#using-pip):

```
pip install -r requirements.txt
```

### Cloud

Datasette is also available as a [hosted version](https://lite.datasette.io/).
This way no setup at all is required.
Since this is a public repo, you can run SQL queries against the data in your browser.
E.g. open [this URL](https://lite.datasette.io/?csv=https%3A%2F%2Fraw.githubusercontent.com%2FIsaacVerm%2Flichess-data%2Frefs%2Fheads%2Fmain%2Fdata%2Fenrich%2Fenrich_puzzles_puzzle_storm.csv#/data?sql=select+url%2C+date%2C+rating%2C+clock%2C+rank_run%0Afrom+enrich_puzzles_puzzle_storm%0Awhere+result+%3D+%27bad%27%0Aorder+by+ceiling%28random%28%29+*+%28select+max%28rank_run%29+from+enrich_puzzles_puzzle_storm%29%29%0Alimit+10) if you want to get 10 random puzzles I failed over time.
More queries can be found in the `src` folder.
All you need to do is point Datasette Lite to the raw content of the CSVs found in the `data` folder.

## Pipeline

The pipeline consists of the following parts:

```
raw > enrich > filter > agg
```

`raw` is the data before any manipulation. The data can be either input manually on GitHub yourself or be fetched automatically from some source like Lichess.
`enrich` is everything related to adding fields to the `raw` data.
`filter` is removing rows from `enrich`.
`agg` is anything related to aggregation (e.g. work at the run instead of puzzle level).

## Folders and important files

- `.github/workflows`: GitHub Actions e.g. to run the pipeline
- `data`: data resulting from running scripts/queries in `src`
- `doc`: how-to's (run pipeline, update query,...) and references
- `doc/reference/training-plan.md`: training plan pointing to which puzzles have to be solved each day. Markdown so you can add manual notes about some puzzles after training.
- `src`: SQL queries and scripts
- `src/pipeline.sh`: master file to run all the queries
- [index.html](./doc/explanation/index.html.md): setup Puzzle Storm session