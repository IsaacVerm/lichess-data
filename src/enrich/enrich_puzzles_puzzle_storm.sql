with runs as (
    -- earliest timestamp string per run_id (ISO date + HH:MM:SS makes min() valid)
    select
        run_id,
        min(date || ' ' || time) as run_ts
    from puzzles_puzzle_storm
    group by run_id
),
run_ranks as (
    -- assign 1..N in order of earliest run timestamp
    select
        run_id,
        row_number() over (order by run_ts) as rank_run
    from runs
)
select
    p.*,
    'https://lichess.org' || href as url,
    row_number() over (partition by run_id order by rating asc) as rank_in_run,
    row_number() over (partition by result order by date, time, rating asc) as rank_in_result,
    (row_number() over (partition by result order by date, time, rating asc)) / 20 as training_bucket,
    r.rank_run
from
    puzzles_puzzle_storm p
    join run_ranks r using (run_id)
    order by date desc, time desc
