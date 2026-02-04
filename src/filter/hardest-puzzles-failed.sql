select
  date,
  time,
  rating,
  url
from
  enrich_puzzles_puzzle_storm
where
  result = 'bad'
order by
  rating desc
limit 10