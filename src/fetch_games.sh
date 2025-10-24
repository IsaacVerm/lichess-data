#!/bin/bash

# Fetch game results from Lichess API
# Usage: ./fetch_games.sh

USERNAME="indexinator"

echo "Fetching games for user: $USERNAME"

# Create data directory if it doesn't exist
mkdir -p data

# Fetch rated games from Lichess API
# The API returns NDJSON (newline-delimited JSON)
curl -s "https://lichess.org/api/games/user/$USERNAME?rated=true&clocks=true&evals=true&division=true&opening=true&max=10" \
  -H "Accept: application/x-ndjson" \
  > data/games.ndjson

# Check if the request was successful
if [ $? -eq 0 ]; then
    echo "Successfully fetched games data"
    echo "Number of games fetched: $(wc -l < data/games.ndjson)"
else
    echo "Error fetching games data"
    exit 1
fi

# Show first game as example
# head -1 data/games.ndjson | jq '.'