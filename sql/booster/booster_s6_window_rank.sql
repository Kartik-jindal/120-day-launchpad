

-- 1) CTE: per-order revenue
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
)
-- 2) Show three rankings per customer (ties illustration)
SELECT order_id, customer_id, rev,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY rev DESC)  AS rn,
       RANK()       OVER (PARTITION BY customer_id ORDER BY rev DESC)  AS rk,
       DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC)  AS drk
FROM order_rev
ORDER BY customer_id, rev DESC;

-- 3) Top-2 per customer (include ties)
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
),
ranked AS (
  SELECT order_id, customer_id, rev,
         DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rnk
  FROM order_rev
)
SELECT * FROM ranked
WHERE rnk <= 2
ORDER BY customer_id, rev DESC, order_id;

-- 4) Global leaderboard (no partition)
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT order_id, customer_id, rev,
       RANK() OVER (ORDER BY rev DESC) AS global_rank
FROM order_rev
ORDER BY global_rank, order_id;

-- 5) “Assertions” (sanity checks; expect zero rows)
-- 5a) ROW_NUMBER uniqueness per (customer_id, rn)
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
),
t AS (
  SELECT customer_id,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rn
  FROM order_rev
)
SELECT customer_id, rn, COUNT(*) AS cnt
FROM t
GROUP BY customer_id, rn
HAVING COUNT(*) > 1;

-- 5b) Top-2 per customer should yield <= 2 rows per customer
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
),
ranked AS (
  SELECT customer_id,
         DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rnk
  FROM order_rev
)
SELECT customer_id, COUNT(*) AS rows_cnt
FROM ranked
WHERE rnk <= 2
GROUP BY customer_id
HAVING COUNT(*) > 2;

