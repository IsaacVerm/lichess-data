select
  rating,
  clock,
  url
from
  enrich_puzzles_puzzle_storm
where
  --difference = 0 for last run so < 5 means 5 last runs
  --I could have filtered on the date as well but sometimes I don't play for days
  ((select max(rank_run) from enrich_puzzles_puzzle_storm) - rank_run) < 5
  and result = 'bad'
order by
  clock desc
