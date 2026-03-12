select
    p.date,
    p.rating,
    p.url,
    j.value as theme
from
    enrich_puzzles_puzzle_storm p,
    json_each(p.themes) j
where
    p.result = 'bad'
order by
    p.date desc, p.rating desc
