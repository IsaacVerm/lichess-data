# Useful SQL queries

Puzzles I failed and took a long time for in Puzzle Storm:

```sql
select *, "https://lichess.org" || href as url
from puzzles_puzzle_storm
where result = 'bad' and clock > 7
order by date desc, time desc
```
