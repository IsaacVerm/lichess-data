select url, date, rating, clock, rank_run
from enrich_puzzles_puzzle_storm
where result = 'bad'
order by ceiling(random() * (select max(rank_run) from enrich_puzzles_puzzle_storm))
limit 10
