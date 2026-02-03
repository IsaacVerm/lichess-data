select
    *
from
    enrich_puzzles_puzzle_storm
where
    result = 'bad' and
    rank_in_run <= 20 and
    --https://github.com/copilot/share/8a07411e-40e4-8014-a102-a449a09c617e
    (date = current_date or date = date('now', '-1 days'))