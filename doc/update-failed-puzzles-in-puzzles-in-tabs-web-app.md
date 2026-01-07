# Update failed puzzles in puzzles-in-tabs web app

## Download folder Puzzle Storm from Google Drive

The Puzzle Storm folder consists of a lot of Untitled files containing links of puzzles I failed over time in Puzzle Storm.
Unzip the contents in any folder locally.

## `cd` into Puzzle Storm downloads folder locally

`cd ~/Downloads/Puzzle Storm...`

## fetch the script and save it into the Puzzle Storm downloads folder

`curl https://raw.githubusercontent.com/IsaacVerm/lichess-data/refs/heads/main/src/failed_puzzles_puzzle_storm.sh > failed_puzzles_puzzle_storm.sh`

Run `cat failed_puzzles_puzzle_storm.sh` to check if the script has been downloaded correctly.

## run the script

```
chmod +x failed_puzzles_puzzle_storm.sh
./failed_puzzles_puzzle_storm.sh
```

Test with `cat failed_puzzles_puzzle_storm.csv`.

## copy the printed array to `index.html ` in [puzzles-in-tab](https://github.com/IsaacVerm/puzzles-in-tabs) repo

Copy into the file and create a commit.

## Wait for GitHub Pages to redeploy the 

Open the [puzzles-in-tabs web app](https://isaacverm.github.io/puzzles-in-tabs) in your browser and check the HTML source.
The new puzzle ids should be in the `puzzleUrls` array.
