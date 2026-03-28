with
fail as (
  select
    date,
    row_number() over (partition by date order by time asc) as [session],
    min(rank_in_run) as first_fail
  from enrich_puzzles_puzzle_storm
  where result = 'bad'
  group by run_id
),
score as (
    select
      date,
      row_number() over (partition by date order by time asc) as [session],
      count(*) as score
    from enrich_puzzles_puzzle_storm
    where result = 'good'
    group by run_id
)
select
  score.date,
  score.session,
  score.score,
  fail.first_fail
--every run has a score but I'm not sure if every run has a fail, so left join
from score
left join fail using (date, session)
