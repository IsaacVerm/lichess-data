# Useful SQL queries

## Puzzles I failed and took a long time for in Puzzle Storm

```sql
select *, "https://lichess.org" || href as url
from puzzles_puzzle_storm
where result = 'bad' and clock > 7
order by clock desc
```

## Add puzzle sequence number

For each `run_id` puzzles start a low rating steadily going up.
I want sequence number 1 for the lowest rating and increasing by 1.

```sql
WITH puzzles AS (
  SELECT *,
         row_number() OVER (PARTITION BY run_id
                            ORDER BY rating ASC) AS seq
  FROM puzzles_puzzle_storm
)
SELECT *
FROM puzzles
```

This uses the window function `row_number`([original chat](https://github.com/copilot/share/8847430c-49e0-8096-a940-244980dc016c) and [explanation in chat](https://github.com/copilot/share/0846119c-40e0-8c12-a143-3641a41c293c)) and WITH ([explanation in chat](https://github.com/copilot/share/0007431c-41e0-8010-b101-3409a0d4207c) for CTE (Common Table Expression).

## Calculate accuracy

Because accuracy is the good count / total count, you need a CTE.
If not you have to duplicate the calculation of good count and total count.

```sql
WITH puzzles AS (
  SELECT *,
         case when result = 'good' then 1 else 0 end as result_int,
         row_number() OVER (PARTITION BY run_id
                            ORDER BY rating ASC) AS seq
  FROM puzzles_puzzle_storm
)
SELECT run_id, sum(result_int) as count_good, max(seq) as total_count, round(sum(result_int) * 1.0 / max(seq), 2) as accuracy
FROM puzzles
group by run_id
order by accuracy desc
```

## Calculate score by run

```sql
with puzzles as (select date, time, sum(case when result = 'good' then 1 else 0 end) as score
from puzzles_puzzle_storm
group by run_id)
select * from puzzles order by score desc
```
