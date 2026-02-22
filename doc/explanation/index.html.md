# `index.html`

`index.html` is automatically deployed to GitHub pages whenever a change is made in the repo.
[Open the file](https://isaacverm.github.io/lichess-data/) and a couple of extra tabs are opened.
These are the tabs you need to play a Puzzle Storm session and save the results.
You have to be logged in to GitHub for this to work but being logged in to Lichess isn't required.

The following tabs are opened:

- `index.html` called "Lichess Data" itself but this file is empty and no longer required after it's opened
- Lichess Puzzle Storm
- script to extract the results from the Lichess Puzzle Storm summary
- editable version `data/raw/puzzles_puzzle_storm.csv`
- Datasette pointing to the latest version of `enrich_puzzles_puzzle_storm`

Steps to procede:

- play Puzzle Storm session
- run script in browser console
- copy results to editable version `data/raw/puzzles_puzzle_storm.csv`