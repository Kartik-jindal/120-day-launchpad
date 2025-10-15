/* =========================
   JOINS + ANTI-JOINS
   ========================= */

/* INNER JOIN: return only matches (drops non-matches) */
SELECT o.order_id, c.name
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id;

/* LEFT JOIN: keep all left rows; right becomes NULL when no match */
SELECT c.customer_id, c.name, o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id;

/* Anti-join (preferred): NOT EXISTS is NULL-safe
   How: keep customer if there is NO 'paid' order for that customer. */
SELECT c.customer_id, c.name
FROM customers c
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.customer_id
    AND o.status = 'paid'
);

/* Anti-join (equivalent if keys are correct): LEFT JOIN ... IS NULL */
WITH paid AS (SELECT DISTINCT customer_id FROM orders WHERE status = 'paid')
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN paid p ON p.customer_id = c.customer_id
WHERE p.customer_id IS NULL;

/* Pitfall: NOT IN with NULLs can drop all rows → prefer NOT EXISTS or LEFT-ANTI
-- WHERE c.customer_id NOT IN (SELECT customer_id FROM orders WHERE status='paid')  -- risky if NULL present
*/

/* =========================
   FAN-OUT (ROW EXPLOSION) + FIX
   ========================= */

/* Problem: joining detail before aggregating multiplies rows */
SELECT c.name, o.order_id, oi.product, oi.qty, oi.price
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id;

/* Fix: pre-aggregate detail, then join (1 row per order) */
WITH order_totals AS (
  SELECT order_id, SUM(qty * price) AS revenue
  FROM order_items
  GROUP BY order_id
)
SELECT c.name, o.order_id, ot.revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_totals ot ON ot.order_id = o.order_id;

/* =========================
   AGGREGATIONS, HAVING, COUNT
   ========================= */

/* Per-order revenue; keep only large orders
   WHERE filters rows before aggregation; HAVING filters aggregated groups. */
SELECT oi.order_id, SUM(oi.qty * oi.price) AS revenue
FROM order_items oi
GROUP BY oi.order_id
HAVING SUM(oi.qty * oi.price) >= 1000;

/* Per-customer revenue (include customers with 0) */
WITH order_totals AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi USING (order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT c.customer_id, c.name, COALESCE(SUM(ot.rev), 0) AS revenue
FROM customers c
LEFT JOIN order_totals ot ON ot.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY revenue DESC, c.customer_id;

/* COUNT flavors */
SELECT
  COUNT(*)                      AS rows_all,
  COUNT(product)                AS rows_non_null_product,
  COUNT(DISTINCT product)       AS unique_products   -- SQLite: only one column supported in DISTINCT
FROM order_items;

/* =========================
   CASE, COALESCE, NULLIF (RATES & BUCKETS)
   ========================= */

/* Segmentation with CASE + COALESCE */
WITH order_totals AS (
  SELECT o.customer_id, SUM(oi.qty * oi.price) AS revenue
  FROM orders o
  JOIN order_items oi USING (order_id)
  GROUP BY o.customer_id
)
SELECT
  c.customer_id,
  c.name,
  COALESCE(ot.revenue, 0) AS revenue,
  CASE
    WHEN COALESCE(ot.revenue, 0) >= 5000 THEN 'VIP'
    WHEN COALESCE(ot.revenue, 0) >= 1000 THEN 'Regular'
    ELSE 'New'
  END AS segment
FROM customers c
LEFT JOIN order_totals ot ON ot.customer_id = c.customer_id
ORDER BY revenue DESC, c.customer_id;

/* Daily rate (safe division with NULLIF)
   SQLite: date(ts); MySQL: DATE(ts); Postgres: ts::date or date_trunc('day', ts). */
WITH daily AS (
  SELECT date(ts) AS day,  -- MySQL: DATE(ts); Postgres: (ts)::date or date_trunc('day', ts)
         SUM(CASE WHEN event = 'purchase' THEN 1 ELSE 0 END) AS purchases,
         SUM(CASE WHEN event = 'view'     THEN 1 ELSE 0 END) AS views
  FROM events
  GROUP BY date(ts)
)
SELECT
  day,
  purchases,
  views,
  ROUND(1.0 * purchases / NULLIF(views, 0), 4) AS purchase_rate   -- MySQL: ROUND(purchases / NULLIF(views,0), 4)
FROM daily
ORDER BY day;

/* =========================
   CTEs, SUBQUERIES, QUERY LADDER
   ========================= */

/* Top‑N per group (Window version; requires SQLite v3.25+)
   How: compute per-group DENSE_RANK by metric desc; keep ranks <= N (ties included). */
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi USING (order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT *
FROM (
  SELECT order_id, customer_id, rev,
         DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rnk
  FROM order_rev
)
WHERE rnk <= 2
ORDER BY customer_id, rev DESC, order_id;

/* Fallback Top‑N without windows (older SQLite):
   rank = 1 + number of distinct higher revs within same customer. */
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi USING (order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT o1.order_id, o1.customer_id, o1.rev
FROM (
  SELECT o1.*,
         1 + (
           SELECT COUNT(DISTINCT o2.rev)
           FROM order_rev o2
           WHERE o2.customer_id = o1.customer_id
             AND o2.rev > o1.rev
         ) AS rnk
  FROM order_rev o1
) o1
WHERE rnk <= 2
ORDER BY o1.customer_id, o1.rev DESC, o1.order_id;

/* Scalar correlated subquery (per-customer totals) */
SELECT
  c.customer_id,
  c.name,
  (SELECT COALESCE(SUM(oi.qty * oi.price), 0)
   FROM orders o
   JOIN order_items oi ON oi.order_id = o.order_id
   WHERE o.customer_id = c.customer_id) AS total_revenue
FROM customers c
ORDER BY total_revenue DESC, c.customer_id;

/* =========================
   WINDOW RANKING (ROW_NUMBER, RANK, DENSE_RANK)
   ========================= */

/* Per-customer rankings: rn (no ties), rk (gaps after ties), drk (no gaps) */
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi USING (order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT
  order_id, customer_id, rev,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY rev DESC)  AS rn,  -- unique sequence
  RANK()       OVER (PARTITION BY customer_id ORDER BY rev DESC)  AS rk,  -- ties share rank; gaps after ties
  DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC)  AS drk  -- ties share rank; no gaps
FROM order_rev
ORDER BY customer_id, rev DESC, order_id;

/* Global leaderboard (no partition) */
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi USING (order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT order_id, customer_id, rev,
       RANK() OVER (ORDER BY rev DESC) AS global_rank
FROM order_rev
ORDER BY global_rank, order_id;

/* Top‑1 per group (ROW_NUMBER) */
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi USING (order_id)
  GROUP BY o.order_id, o.customer_id
),
t AS (
  SELECT order_id, customer_id, rev,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rn
  FROM order_rev
)
SELECT order_id, customer_id, rev
FROM t
WHERE rn = 1
ORDER BY customer_id, order_id;

/* =========================
   EXTRA COMMON PATTERNS
   ========================= */

/* Customers with ≥ 2 paid orders (GROUP BY + HAVING) */
SELECT c.customer_id, c.name, COUNT(*) AS paid_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'paid'
GROUP BY c.customer_id, c.name
HAVING COUNT(*) >= 2
ORDER BY paid_orders DESC, c.customer_id;

/* Anti-join equivalence check (NOT EXISTS vs LEFT‑ANTI) → expect zero rows if equivalent */
WITH b AS (
  SELECT c.customer_id
  FROM customers c
  WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'paid'
  )
),
l AS (
  WITH paid AS (SELECT DISTINCT customer_id FROM orders WHERE status='paid')
  SELECT c.customer_id
  FROM customers c
  LEFT JOIN paid p ON p.customer_id = c.customer_id
  WHERE p.customer_id IS NULL
)
SELECT 'B_minus_L' AS diff, * FROM b EXCEPT SELECT * FROM l
UNION ALL
SELECT 'L_minus_B', * FROM l EXCEPT SELECT * FROM b;