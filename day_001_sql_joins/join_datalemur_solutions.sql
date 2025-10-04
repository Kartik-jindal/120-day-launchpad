
```Page With No Likes
Facebook SQL Interview Question```

SELECT p.page_id --- select the column from alias p
FROM pages p --- table with alias p
LEFT JOIN page_likes l --- left join with table page_likes with alias l
  ON p.page_id = l.page_id  --- join condition
WHERE l.page_id IS NULL --- filter for rows where there are no matches in page_likes because not in likes-table means 0 likes
ORDER BY p.page_id; ---order by page_id in ascending order



```Unfinished Parts
Tesla SQL Interview Question```

SELECT part, assembly_step FROM parts_assembly --- select columns part and assembly_step from table parts_assembly
WHERE assembly_step IS NOT NULL --- filter for rows where assembly_step is not null
where finish_date is NULL;

```Cities With Completed Trades
Robinhood SQL Interview Question```

SELECT u.city, COUNT(*) AS total_orders --- count(*) takes count after joining so that no null values come
FROM users u
JOIN trades t 
  ON u.user_id = t.user_id
WHERE t.status = 'Completed'
GROUP BY u.city
ORDER BY total_orders DESC
LIMIT 3;

