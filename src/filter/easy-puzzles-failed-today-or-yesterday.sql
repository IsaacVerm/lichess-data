select
    *
from
    enrich_puzzles_puzzle_storm
where
    result = 'bad' and
    rank_in_run <= 20 and
    date = current_date or date = date('now', '-2 days')