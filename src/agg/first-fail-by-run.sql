select
  date,
  row_number() over (partition by date order by time asc) as run_rank_in_session,
  min(rank_in_run) as first_fail_rank_in_run
from
  enrich_puzzles_puzzle_storm
where
  result = 'bad'
group by
  run_id
order by
  date desc, run_rank_in_session asc