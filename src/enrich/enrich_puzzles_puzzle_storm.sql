select
    *,
    "https://lichess.org" || href as url,
    row_number() over (partition by run_id order by rating asc) as rank_in_run
from
    puzzles_puzzle_storm