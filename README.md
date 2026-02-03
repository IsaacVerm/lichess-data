# Lichess Data

A data pipeline for fetching, processing, and analyzing personal chess games and puzzle performance from [Lichess](https://lichess.org). The project transforms raw data from the Lichess API into structured CSV files using SQL transformations, enabling detailed analysis of game openings, puzzle performance, and playing patterns.

## Features

- **Game Data Collection**: Fetch rated chess games via the Lichess API
- **Puzzle Storm Analysis**: Track and analyze Puzzle Storm performance over time
- **SQL-Based Transformations**: Process data through enrich, filter, and aggregation stages
- **Star Schema Design**: Organized data structure following dimensional modeling best practices
- **Interactive Data Exploration**: Visualize data using Datasette and Datasette Lite

## Prerequisites

- Python 3.x
- [sqlite-utils](https://sqlite-utils.datasette.io/) - SQL toolkit for processing CSV data
- [Datasette](https://datasette.io/) - Tool for exploring and publishing data
- [jq](https://jqlang.github.io/jq/) - Command-line JSON processor
- Node.js (for puzzle scraping scripts)

## Installation

1. Install Python dependencies:
```bash
pip install sqlite-utils datasette
```

2. Install jq (if not already installed):
```bash
# On macOS
brew install jq

# On Ubuntu/Debian
sudo apt-get install jq
```

## Usage

### Fetching Game Data

Fetch your Lichess games (update the `USERNAME` variable in the script first):

```bash
chmod +x src/fetch_games.sh
./src/fetch_games.sh
```

This will create `data/games.ndjson` with all your rated games including opening information.

### Processing Game Data

Extract specific data dimensions (openings, game results, moves) from the raw game data:

```bash
# Extract games with opening codes
bash src/games.sh

# Extract opening information
bash src/openings.sh

# Extract game results
bash src/game_results.sh

# Extract move data
bash src/moves.sh
```

### Processing Puzzle Data

The puzzle data pipeline runs automatically via GitHub Actions when raw puzzle data is updated. To run it manually:

```bash
chmod +x src/pipeline.sh
./src/pipeline.sh
```

The pipeline performs:
1. **Enrichment**: Add computed fields like run ranks and sequences
2. **Filtering**: Extract specific puzzle subsets (e.g., easy puzzles failed recently)
3. **Aggregation**: Generate summary statistics (e.g., first failure per run)

### Exploring Data with Datasette

View and query your data interactively:

```bash
# Create a database from CSV files
sqlite-utils insert games.db games data/games.csv --csv
sqlite-utils insert games.db openings data/openings.csv --csv

# Launch Datasette
datasette serve games.db
```

Then open your browser to `http://localhost:8001` to explore the data.

### Puzzle Storm Data Collection

The project includes a browser-based scraper for collecting Puzzle Storm results:

1. Play a Puzzle Storm session on Lichess
2. Open the browser console on the Puzzle Storm history page
3. Run the scraper code from `src/raw/scrape-puzzles-puzzle-storm.js`
4. Save the output to `data/raw/puzzles_puzzle_storm.csv`

## Project Structure

```
lichess-data/
├── data/                          # Data files organized by processing stage
│   ├── raw/                      # Raw data from Lichess API and scrapers
│   ├── enrich/                   # Enriched data with computed fields
│   ├── filter/                   # Filtered data subsets
│   └── agg/                      # Aggregated/summary data
├── src/                          # Source scripts
│   ├── fetch_games.sh           # Fetch games from Lichess API
│   ├── pipeline.sh              # Main data processing pipeline
│   ├── enrich/                  # SQL enrichment queries
│   ├── filter/                  # SQL filter queries
│   ├── agg/                     # SQL aggregation queries
│   └── raw/                     # Data collection scripts
├── doc/                          # Documentation
│   ├── useful-sql-queries.md   # Collection of useful SQL queries
│   └── how-to/                  # How-to guides
├── scripts/                      # Utility scripts
└── index.html                    # Web app for opening puzzle tabs

```

## Data Architecture

The project uses a **star schema** design with:

- **Fact Tables**: `games` - contains game IDs and foreign keys
- **Dimension Tables**: `openings`, `game_results`, `moves` - contain descriptive attributes

This design follows [Power BI best practices](https://learn.microsoft.com/en-us/power-bi/guidance/star-schema) for analytical data modeling.

## Documentation

- **[Useful SQL Queries](doc/useful-sql-queries.md)**: Collection of SQL queries for analyzing puzzle and game data
- **[How-to Guides](doc/how-to/)**: Step-by-step guides for specific tasks

## CI/CD

The repository includes GitHub Actions workflows:

- **Run Pipeline**: Automatically processes puzzle data when raw data files are updated
- **Generate Count Matrix**: (Currently disabled) - Available for manual trigger

## License

This is a personal project for analyzing individual Lichess data.