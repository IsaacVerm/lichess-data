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

## Calculate accuracy at several steps in run

```sql
with puzzles as (
  select
    *,
    row_number() over (partition by run_id order by rating asc) as seq,
    case when result = 'good' then 1 else 0 end as result_in
  from puzzles_puzzle_storm
)
select
  a.run_id,
  count(*) as count_total,
  sum(a.result_in) as count_good_total,
  b.count_good as count_good_after_20_puzzles,
  /* accuracy is between 0 and 1 and without * 1.0 you get the default integer division */
  round(sum(a.result_in) * 1.0 / count(*), 2) as accuracy_total,
  (b.count_good * 1.0 / 20) as accuracy_after_20_puzzles
from puzzles as a
left join (
  select
    run_id,
    count(*) as count_total,
    sum(result_in) as count_good
  from puzzles
  where seq < 21
  group by run_id
) as b
  on a.run_id = b.run_id
group by a.run_id
order by accuracy_total desc;
```

There are [some optimizations to be made](https://github.com/copilot/share/0a6e500e-40c0-8c10-a941-a609a4de412d):
- use `AVG` function instead of dividing sum by count manually
- drop the `JOIN` function by moving the filter from `where seq < 21` to a `CASE` statement:

```sql
with puzzles as (
  select
    *,
    row_number() over (partition by run_id order by rating asc) as seq,
    case when result = 'good' then 1 else 0 end as result_in
  from puzzles_puzzle_storm
)
select
  run_id,
  count(*) as count_total,
  sum(result_in) as count_good_total,
  sum(case when seq < 21 then result_in else 0 end) as count_good_after_20_puzzles,
  round(avg(result_in), 2) as accuracy_total,
  round(sum(case when seq < 21 then result_in else 0 end) * 1.0 / 20, 2) as accuracy_after_20_puzzles
from puzzles
group by run_id
order by count_total desc;
```

## Count purple heart at several steps in run

The above accuracy calculation can be simplified.
When you score 100% accuracy, it's considered a Purple Heart.
I no longer care about the exact amount of puzzles solved or solved correctly, just whether all the puzzles.
This seems to be the best indication of a good score (because Puzzle Storm gives you bonus seconds if you have solved multiple puzzles succesfully in succession).

```sql
with puzzles as (
  select
    *,
    row_number() over (partition by run_id order by rating asc) as seq,
    case when result = 'good' then 1 else 0 end as result_in
  from puzzles_puzzle_storm
)
select
  run_id,
  /* max(seq) or count(*) give the same result */
  max(seq) as score_total,
  round(avg(result_in), 2) as accuracy_total,
  round(sum(case when seq < 21 then result_in else 0 end) * 1.0 / 20, 2) as accuracy_after_20_puzzles
from puzzles
group by run_id
order by score_total desc;
```

## Calculate score by run

```sql
with puzzles as (select date, time, sum(case when result = 'good' then 1 else 0 end) as score
from puzzles_puzzle_storm
group by run_id)
select * from puzzles order by score desc
```
