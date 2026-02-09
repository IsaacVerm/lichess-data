select
  date,
  count(distinct run_id) as count_runs,
  min(rank_in_run) as min_rank_first_fail,
  max(rank_in_run) as max_score,
  case
    when count(distinct run_id) > 1
    then max(rank_in_run) - min(rank_in_run)
    else NULL
    end as deviation_early_fail_high_score,
  round(avg(rank_in_run), 2) as avg_rank_in_run_first_fail
from
  enrich_puzzles_puzzle_storm
where
  result = 'bad'
group by
  date
order by
  date desc
