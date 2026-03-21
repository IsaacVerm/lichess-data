select * from enrich_puzzles_puzzle_storm
where result = 'bad' and training_set in (1,2,3)
order by training_set