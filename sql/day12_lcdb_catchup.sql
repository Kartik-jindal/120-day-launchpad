-- LeetCode DB: Rank Scores — https://leetcode.com/problems/rank-scores/
-- Accepted (web schema): paste as comments if you like
-- Local demo (sandbox): DENSE_RANK over order revenue (Rank Scores analog)
WITH order_rev AS (
  SELECT o.order_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi USING(order_id)
  GROUP BY o.order_id
)
SELECT order_id, rev,
       DENSE_RANK() OVER (ORDER BY rev DESC) AS rnk
FROM order_rev
ORDER BY rnk, order_id;

-- LeetCode DB: Consecutive Numbers — https://leetcode.com/problems/consecutive-numbers/
-- Accepted (web schema): paste as comments if you like
-- Local demo (sandbox): customers with 3 consecutive order days (streaks analog)
WITH daily AS (
  SELECT o.customer_id, date(o.created_at) AS dt, COUNT(*) AS orders
  FROM orders o
  GROUP BY o.customer_id, date(o.created_at)
),
seq AS (
  SELECT customer_id, dt, orders,
         julianday(dt) - ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY dt) AS grp
  FROM daily
),
streaks AS (
  SELECT customer_id, MIN(dt) AS start_dt, MAX(dt) AS end_dt, COUNT(*) AS days
  FROM seq
  GROUP BY customer_id, grp
)
SELECT customer_id, start_dt, end_dt, days
FROM streaks
WHERE days >= 3
ORDER BY customer_id, start_dt;

-- LeetCode DB: Managers With At Least 5 Direct Reports — https://leetcode.com/problems/managers-with-at-least-5-direct-reports/
-- Accepted (web schema): paste as comments if you like
-- Local demo (sandbox): customers with >= 2 paid orders (GROUP BY + HAVING analog)
SELECT o.customer_id, COUNT(*) AS paid_orders
FROM orders o
WHERE o.status = 'paid'
GROUP BY o.customer_id
HAVING COUNT(*) >= 2
ORDER BY paid_orders DESC;