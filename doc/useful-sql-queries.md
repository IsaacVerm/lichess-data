# Useful SQL queries

I try to order these queries from more general to more specific purposes.

## Overview runs

```sql
select
  run_id,
  date,
  time,
  sum(case when result = 'good' then 1 else 0 end) as score
from
  puzzles_puzzle_storm
group by
  run_id
order by
  score desc
```

I order by score but could have ordered by date as well.

## Average score by day

```sql
select
  date,
  count(*) as count_runs,
  round(avg(score),1) as avg_score
from (
  select
    date,
    sum(case when result = 'good' then 1 else 0 end) as score
  from
    puzzles_puzzle_storm
  group by
    run_id
)
group by
  date
order by
  date desc
```

## [Puzzles I failed today](https://lite.datasette.io/?csv=https%3A%2F%2Fraw.githubusercontent.com%2FIsaacVerm%2Flichess-data%2Fmain%2Fdata%2Fpuzzles_puzzle_storm.csv#/data?sql=select%0A++%22https%3A%2F%2Flichess.org%22+%7C%7C+href+as+url%2C%0A++case%0A++++when+rating+%3C+1200+then+1%0A++++when+rating+%3E%3D+1200+and+rating+%3C+1400+then+2%0A++++else+3%0A++end+as+rating_class%2C%0A++rating%2C%0A++clock%0Afrom+puzzles_puzzle_storm%0Awhere+date+%3D+current_date+and+result+%3D+%27bad%27%0Aorder+by+rating_class%2C+clock+desc)

Ordered so the easiest puzzles (low `rating_class`) solved the slowest are first on the list.

```sql
select
  "https://lichess.org" || href as url,
  case
    when rating < 1200 then 1
    when rating >= 1200 and rating < 1400 then 2
    else 3
  end as rating_class,
  rating,
  clock
from puzzles_puzzle_storm
where date = current_date and result = 'bad'
order by rating_class, clock desc
```

`current_date` is defined by default in SQL (not just in `sqlite`).

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
  date,
  time,
  /* max(seq) or count(*) give the same result */
  max(seq) as score_total,
  round(avg(result_in), 2) as accuracy_total,
  round(sum(case when seq < 21 then result_in else 0 end) * 1.0 / 20, 2) as accuracy_after_20_puzzles
from puzzles
group by run_id
order by score_total desc;
```

## Only select puzzles from Purple Heart run

When I aim for very high accuracy ("Purple Heart run"), the puzzles I fail I failed because I really missed something.
This is not just a random fail because I didn't pay attention, but a puzzle failed because I was fooled by something.
By definition there's less of those puzzles as well, since I pay attention and aim for quality (rather less puzzles solved with high accuracy than more puzzles solved but lower accuracy).

```sql
SELECT "https://lichess.org" || href as url, run_id
FROM puzzles_puzzle_storm
WHERE run_id IN (
  SELECT run_id
  FROM puzzles_puzzle_storm
  GROUP BY run_id
  HAVING AVG(CASE WHEN result = 'good' THEN 1 ELSE 0 END) > 0.90
) AND result = 'bad';
```

Now I defined a Purple Heart run as a run with a very high accuracy but there are other definitions possible.
I could for example filter all runs in which the first 20 puzzles solved were all solved succesfully.
That might even be a more accurate definition.

## Calculate score by run

```sql
with puzzles as (select date, time, sum(case when result = 'good' then 1 else 0 end) as score
from puzzles_puzzle_storm
group by run_id)
select * from puzzles order by score desc
```
