-- booster_s5_cte_subqueries.sql
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY o.order_id, o.customer_id
),
ranked AS (
  SELECT order_id, customer_id, rev,
         DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rnk
  FROM order_rev
)
SELECT *
FROM ranked
WHERE rnk <= 2
ORDER BY customer_id, rev DESC, order_id;


-- SELECT o1.order_id, o1.customer_id, o1.rev
-- FROM (
--   SELECT o1.*,
--          1 + (
--            SELECT COUNT(DISTINCT o2.rev)
--            FROM order_rev o2
--            WHERE o2.customer_id = o1.customer_id AND o2.rev > o1.rev
--          ) AS rnk
--   FROM order_rev o1
-- ) o1
-- WHERE rnk <= 2
-- ORDER BY o1.customer_id, o1.rev DESC, o1.order_id;

-- 2) Anti-join using NOT EXISTS: customers with NO 'paid' orders
SELECT c.customer_id, c.name
FROM customers c
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.customer_id
    AND o.status = 'paid'
)
ORDER BY c.customer_id;

-- 3) LEFT-ANTI equivalent
WITH paid AS (
  SELECT DISTINCT customer_id FROM orders WHERE status='paid'
)
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN paid p ON p.customer_id = c.customer_id
WHERE p.customer_id IS NULL
ORDER BY c.customer_id;

-- 3b) Equivalence check 
WITH b AS (
  SELECT c.customer_id
  FROM customers c
  WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id AND o.status='paid')
),
l AS (
  WITH paid AS (SELECT DISTINCT customer_id FROM orders WHERE status='paid')
  SELECT c.customer_id
  FROM customers c LEFT JOIN paid p ON p.customer_id=c.customer_id
  WHERE p.customer_id IS NULL
)
SELECT 'B_minus_L' AS diff, * FROM b EXCEPT SELECT * FROM l
UNION ALL
SELECT 'L_minus_B' AS diff, * FROM l EXCEPT SELECT * FROM b;


WITH order_totals AS (
  SELECT o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi ON oi.order_id=o.order_id
  GROUP BY o.customer_id
)
SELECT c.customer_id, c.name, COALESCE(ot.rev,0) AS revenue
FROM customers c
LEFT JOIN order_totals ot ON ot.customer_id=c.customer_id
ORDER BY revenue DESC, c.customer_id;