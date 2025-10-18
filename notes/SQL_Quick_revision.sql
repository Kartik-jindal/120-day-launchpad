/* SQL_Mega_Revision.sql
   Purpose: One-file reference of core SQL patterns with concise WHAT/WHY comments and runnable snippets.
   Engine notes:
   - SQLite: no RIGHT/FULL OUTER JOIN; window functions require v3.25+; COUNT(DISTINCT col1, col2) not supported.
   - MySQL: IFNULL ≈ COALESCE; supports COUNT(DISTINCT col1, col2); DATE(ts) for day bucketing.
   - Postgres: COALESCE; DATE_TRUNC for bucketing; rich windows/frames.

   (Assumes sandbox with customers, orders, order_items, events)
*/

/* =========================
   0) QUICK COUNTS (context)
   ========================= */
SELECT 'customers' AS t, COUNT(*) AS n FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

/* =========================
   1) JOINS + ANTI-JOINS
   ========================= */

/* INNER JOIN: return only matches (drops non-matches)
   WHY: use when you only want rows present in both tables. */
SELECT o.order_id, c.name
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id;

/* LEFT JOIN: keep all left rows; right columns NULL if no match
   WHY: preserve the left side even when there’s no related row. */
SELECT c.customer_id, c.name, o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_id;

/* Anti-join (preferred): NOT EXISTS is NULL-safe
   WHY: find left rows with NO matching right rows; avoids NOT IN + NULL pitfalls. */
SELECT c.customer_id, c.name
FROM customers c
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.customer_id
    AND o.status = 'paid'
)
ORDER BY c.customer_id;

/* Anti-join (equivalent if keys correct): LEFT JOIN ... IS NULL
   WHY: left rows where the right side failed to match stay NULL. */
WITH paid AS (SELECT DISTINCT customer_id FROM orders WHERE status='paid')
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN paid p ON p.customer_id = c.customer_id
WHERE p.customer_id IS NULL
ORDER BY c.customer_id;

/* NOT IN pitfall (doc): if subquery returns NULL, NOT IN can drop all rows.
   Prefer NOT EXISTS or LEFT-ANTI. */

/* =========================
   2) ANTI-JOIN EQUIVALENCE CHECK
   ========================= */
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
SELECT 'L_minus_B', * FROM l EXCEPT SELECT * FROM b;  -- expect zero rows

/* =========================
   3) FAN-OUT (ROW EXPLOSION) + FIX
   ========================= */

/* Problem demo: join parent->child (1→many) multiplies rows
   WHY: each order has multiple items, so rows “explode”. */
SELECT c.name, o.order_id, oi.product, oi.qty, oi.price
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
ORDER BY c.name, o.order_id;

/* Assert explosion: item_rows >= order_rows (more rows after detail join) */
WITH raw AS (
  SELECT o.order_id
  FROM orders o JOIN order_items oi USING(order_id)
)
SELECT
  (SELECT COUNT(*) FROM raw)   AS item_rows,
  (SELECT COUNT(*) FROM orders) AS order_rows;

/* Fix: pre-aggregate child to parent grain, then join (1 row per order)
   WHY: reduce detail to a single row per parent to avoid duplication. */
WITH order_totals AS (
  SELECT order_id, SUM(qty*price) AS revenue
  FROM order_items
  GROUP BY order_id
)
SELECT c.name, o.order_id, ot.revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_totals ot ON ot.order_id = o.order_id
ORDER BY c.name, o.order_id;

/* Assert fix: each order_id appears once after pre-aggregation */
WITH order_totals AS (
  SELECT order_id, SUM(qty*price) AS revenue
  FROM order_items
  GROUP BY order_id
),
fixed AS (
  SELECT o.order_id
  FROM orders o LEFT JOIN order_totals ot USING(order_id)
)
SELECT COUNT(*) AS rows_after_fix, COUNT(DISTINCT order_id) AS distinct_orders
FROM fixed;  -- values should match

/* =========================
   4) AGGREGATIONS + HAVING + COUNT
   ========================= */

/* Per-order revenue; keep only large orders
   WHY: aggregated predicates go in HAVING (post-aggregation). */
SELECT oi.order_id, SUM(oi.qty*oi.price) AS revenue
FROM order_items oi
GROUP BY oi.order_id
HAVING SUM(oi.qty*oi.price) >= 1000
ORDER BY revenue DESC;

/* Per-customer revenue (include customers with 0 revenue)
   WHY: LEFT JOIN from customers to aggregated orders. */
WITH order_totals AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT c.customer_id, c.name, COALESCE(SUM(ot.rev), 0) AS revenue
FROM customers c
LEFT JOIN order_totals ot ON ot.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY revenue DESC;

/* COUNT flavors (know the differences) */
SELECT
  COUNT(*)                 AS rows_all,             -- all rows
  COUNT(product)           AS rows_non_null_product,-- non-NULL product
  COUNT(DISTINCT product)  AS unique_products       -- SQLite: one column only
FROM order_items;

/* =========================
   5) CASE + COALESCE + NULLIF (SEGMENTS & RATES)
   ========================= */

/* Segmentation by revenue thresholds
   WHY: COALESCE handles NULLs; CASE buckets into labels. */
WITH order_totals AS (
  SELECT o.customer_id, SUM(oi.qty*oi.price) AS revenue
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.customer_id
)
SELECT c.customer_id, c.name,
       COALESCE(ot.revenue, 0) AS revenue,
       CASE
         WHEN COALESCE(ot.revenue,0) >= 5000 THEN 'VIP'
         WHEN COALESCE(ot.revenue,0) >= 1000 THEN 'Regular'
         ELSE 'New'
       END AS segment
FROM customers c
LEFT JOIN order_totals ot ON ot.customer_id = c.customer_id
ORDER BY revenue DESC, c.customer_id;

/* Daily rate with safe division
   WHY: NULLIF(denom,0) avoids divide-by-zero; 1.0 forces float. */
WITH daily AS (
  SELECT date(ts) AS day,
         SUM(CASE WHEN event='purchase' THEN 1 ELSE 0 END) AS purchases,
         SUM(CASE WHEN event='view'     THEN 1 ELSE 0 END) AS views
  FROM events
  GROUP BY date(ts)
)
SELECT day, purchases, views,
       ROUND(1.0 * purchases / NULLIF(views, 0), 4) AS purchase_rate
FROM daily
ORDER BY day;

/* =========================
   6) CTE LADDER + TOP‑N PER GROUP
   ========================= */

/* Window version (preferred): DENSE_RANK for “top-N including ties”
   WHY: compute a per-group rank, then keep ranks <= N. (Requires SQLite 3.25+.) */
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
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

/* Fallback (no windows): rank = 1 + count of distinct higher values in group
   WHY: emulate DENSE_RANK via correlated subquery. */
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT o1.order_id, o1.customer_id, o1.rev
FROM (
  SELECT o1.*,
         1 + (
           SELECT COUNT(DISTINCT o2.rev)
           FROM order_rev o2
           WHERE o2.customer_id = o1.customer_id AND o2.rev > o1.rev
         ) AS rnk
  FROM order_rev o1
) o1
WHERE rnk <= 2
ORDER BY o1.customer_id, o1.rev DESC, o1.order_id;

/* Scalar correlated subquery (per-customer totals)
   WHY: compute one scalar per outer row (customer). */
SELECT c.customer_id, c.name,
       (SELECT COALESCE(SUM(oi.qty*oi.price),0)
        FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
        WHERE o.customer_id = c.customer_id) AS total_revenue
FROM customers c
ORDER BY total_revenue DESC, c.customer_id;

/* =========================
   7) WINDOW RANKING (RN/RANK/DENSE_RANK)
   ========================= */
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT order_id, customer_id, rev,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY rev DESC)  AS rn,  -- unique sequence (no ties)
       RANK()       OVER (PARTITION BY customer_id ORDER BY rev DESC)  AS rk,  -- ties share rank; gaps (1,1,3)
       DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC)  AS drk  -- ties share rank; no gaps (1,1,2)
FROM order_rev
ORDER BY customer_id, rev DESC, order_id;

/* Global leaderboard (no partition) */
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
)
SELECT order_id, customer_id, rev,
       RANK() OVER (ORDER BY rev DESC) AS global_rank
FROM order_rev
ORDER BY global_rank, order_id;

/* =========================
   8) LAG/LEAD + CUMULATIVE + ROLLING
   ========================= */

/* Daily per-customer revenue with LAG, cumulative SUM, 7-row rolling AVG
   WHY: LAG compares to previous row; ROWS frame defines exact row counts. */
WITH order_daily AS (
  SELECT o.customer_id,
         date(o.created_at) AS dt,
         SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.customer_id, date(o.created_at)
),
lagged AS (
  SELECT customer_id, dt, rev,
         LAG(rev, 1) OVER (PARTITION BY customer_id ORDER BY dt) AS prev_rev
  FROM order_daily
)
SELECT customer_id, dt, rev, prev_rev,
       (rev - COALESCE(prev_rev, 0)) AS dod_change,
       SUM(rev) OVER (PARTITION BY customer_id ORDER BY dt
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_rev,
       ROUND(AVG(rev) OVER (PARTITION BY customer_id ORDER BY dt
                            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS avg7_rev
FROM lagged
ORDER BY customer_id, dt;

/* Global cumulative and rolling (no partition) */
WITH order_daily AS (
  SELECT date(o.created_at) AS dt, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY date(o.created_at)
)
SELECT dt, rev,
       SUM(rev) OVER (ORDER BY dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_rev_all,
       ROUND(AVG(rev) OVER (ORDER BY dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS avg7_all
FROM order_daily
ORDER BY dt;

/* Sanity checks (expect zero rows)
   - First row per customer has NULL prev_rev
   - cum_rev is non-decreasing within a customer */
WITH order_daily AS (
  SELECT o.customer_id, date(o.created_at) dt, SUM(oi.qty*oi.price) rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.customer_id, date(o.created_at)
),
lagged AS (
  SELECT customer_id, dt,
         LAG(rev) OVER (PARTITION BY customer_id ORDER BY dt) AS prev_rev,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY dt) AS rn
  FROM order_daily
)
SELECT customer_id, dt FROM lagged WHERE rn = 1 AND prev_rev IS NOT NULL;

WITH order_daily AS (
  SELECT o.customer_id, date(o.created_at) dt, SUM(oi.qty*oi.price) rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.customer_id, date(o.created_at)
),
w AS (
  SELECT customer_id, dt, rev,
         SUM(rev) OVER (PARTITION BY customer_id ORDER BY dt
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_rev
  FROM order_daily
)
SELECT a.customer_id, a.dt, a.cum_rev, b.cum_rev AS next_cum
FROM w a
JOIN w b
  ON a.customer_id = b.customer_id
 AND b.dt = (SELECT MIN(dt) FROM w w2 WHERE w2.customer_id=a.customer_id AND w2.dt > a.dt)
WHERE b.cum_rev < a.cum_rev;  -- expect zero

/* =========================
   9) SET OPERATIONS + DISTINCT PITFALL
   ========================= */

/* UNION ALL vs UNION
   WHY: UNION ALL stacks rows (no dedup); UNION dedups (costly). */
SELECT 'A' AS src, customer_id FROM customers WHERE customer_id IN (1,2)
UNION ALL
SELECT 'B', customer_id FROM customers WHERE customer_id IN (2,3);

SELECT customer_id FROM customers WHERE customer_id IN (1,2)
UNION
SELECT customer_id FROM customers WHERE customer_id IN (2,3);

/* DISTINCT masking duplicates (BAD) vs pre-aggregation (GOOD)
   WHY: DISTINCT hides a fan-out bug; fix the grain instead. */
SELECT DISTINCT c.customer_id, c.name, o.order_id
FROM customers c
JOIN orders o USING(customer_id)
JOIN order_items oi USING(order_id)
ORDER BY c.customer_id, o.order_id;  -- BAD: masks duplication

WITH order_totals AS (
  SELECT order_id, SUM(qty*price) AS rev FROM order_items GROUP BY order_id
)
SELECT c.customer_id, c.name, o.order_id, ot.rev
FROM customers c
JOIN orders o USING(customer_id)
LEFT JOIN order_totals ot USING(order_id)
ORDER BY c.customer_id, o.order_id;  -- GOOD: correct grain

/* INTERSECT / EXCEPT (SQLite supports both)
   WHY: set intersection/difference over compatible SELECTs. */
SELECT DISTINCT customer_id FROM orders WHERE status='paid'
INTERSECT
SELECT DISTINCT customer_id FROM orders WHERE status='cancelled';

SELECT DISTINCT customer_id FROM orders WHERE status='paid'
EXCEPT
SELECT DISTINCT customer_id FROM orders WHERE status='cancelled';

/* =========================
   10) COMMON QUERIES (handy)
   ========================= */

/* Customers with >= 2 paid orders */
SELECT c.customer_id, c.name, COUNT(*) AS paid_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'paid'
GROUP BY c.customer_id, c.name
HAVING COUNT(*) >= 2
ORDER BY paid_orders DESC, c.customer_id;

/* Top-1 order per customer (ROW_NUMBER filter) */
WITH order_rev AS (
  SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
  FROM orders o JOIN order_items oi USING(order_id)
  GROUP BY o.order_id, o.customer_id
),
t AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rn
  FROM order_rev
)
SELECT order_id, customer_id, rev
FROM t
WHERE rn = 1
ORDER BY customer_id, order_id;



- Never fix duplicate explosion with DISTINCT — fix join grain with pre-aggregation.
- Pre-aggregate before join:
  WITH child_agg AS (
    SELECT parent_id, SUM(val) AS sum_val
    FROM child
    GROUP BY parent_id
  )
  SELECT p.*, ca.sum_val
  FROM parent p
  LEFT JOIN child_agg ca USING (parent_id);

- Anti-join (preferred): customers with NO paid orders
  SELECT c.customer_id, c.name
  FROM customers c
  WHERE NOT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.customer_id AND o.status = 'paid'
  );

- Top-K per group (DENSE_RANK)
  WITH order_rev AS (
    SELECT o.order_id, o.customer_id, SUM(oi.qty*oi.price) AS rev
    FROM orders o JOIN order_items oi USING(order_id)
    GROUP BY o.order_id, o.customer_id
  )
  SELECT *
  FROM (
    SELECT order_id, customer_id, rev,
           DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY rev DESC) AS rnk
    FROM order_rev
  )
  WHERE rnk <= 2;

- Cumulative sum (daily)
  WITH order_daily AS (
    SELECT o.customer_id, date(o.created_at) AS dt, SUM(oi.qty*oi.price) AS rev
    FROM orders o JOIN order_items oi USING(order_id)
    GROUP BY o.customer_id, date(o.created_at)
  )
  SELECT customer_id, dt, rev,
         SUM(rev) OVER (PARTITION BY customer_id ORDER BY dt
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_rev
  FROM order_daily;