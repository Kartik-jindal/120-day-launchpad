--Grid of BSF / DFS
# 4-dir neighbors
for dr, dc in ((1,0),(-1,0),(0,1),(0,-1)):
    nr, nc = r+dr, c+dc


-- Build in named steps; debug each step
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
),
ranked AS (
  SELECT order_id, customer_id, rev,
         DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rnk
  FROM order_rev
)
SELECT * FROM ranked WHERE rnk <= 2;
-- Debug: SELECT COUNT(*) FROM order_rev; SELECT customer_id, COUNT(*) FROM ranked GROUP BY customer_id;


ANTI JOIN

-- Preferred (NULL-safe)
SELECT c.*
FROM customers c
WHERE NOT EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.customer_id AND o.status = 'paid'
);

-- Equivalent via LEFT-ANTI
WITH paid AS (SELECT DISTINCT customer_id FROM orders WHERE status='paid')
SELECT c.*
FROM customers c
LEFT JOIN paid p ON p.customer_id = c.customer_id
WHERE p.customer_id IS NULL;

-- NOT IN pitfall (doc)
-- If subquery returns NULL, NOT IN can drop all rows. Prefer NOT EXISTS.

Top n Tier Groups
-- Window (preferred)
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT order_id, customer_id, rev
FROM (
  SELECT order_id, customer_id, rev,
         DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rnk
  FROM order_rev
)
WHERE rnk <= 2;

-- Fallback (no windows): "count how many are greater"
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT o1.order_id, o1.customer_id, o1.rev
FROM (
  SELECT o1.*,
         1 + (SELECT COUNT(DISTINCT o2.rev)
              FROM order_rev o2
              WHERE o2.customer_id = o1.customer_id AND o2.rev > o1.rev) AS rnk
  FROM order_rev o1
) o1
WHERE rnk <= 2;
