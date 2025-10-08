
-- 1) INNER JOIN: orders with customer names
SELECT o.order_id, c.name, o.status, date(o.created_at) AS order_dt
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- 2) LEFT JOIN: keep customers even if no orders
SELECT c.customer_id, c.name, o.order_id, o.status
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_id;

-- 3) LEFT-ANTI JOIN: customers who never had a 'paid' order
WITH paid AS (
  SELECT DISTINCT customer_id FROM orders WHERE status='paid'
)
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN paid p ON p.customer_id = c.customer_id
WHERE p.customer_id IS NULL;

-- 4) MULTI-JOIN caution (row explosion): customers -> orders -> items
SELECT c.name, o.order_id, oi.product, oi.qty, oi.price
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
ORDER BY c.name, o.order_id;

-- 5) FIX fan-out: pre-aggregate items before joining
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


-- International Call Percentage
SELECT
  ROUND(100.0 * SUM(is_international) / COUNT(*), 1) AS international_calls_pct
FROM (
  SELECT
    pc.caller_id,
    pc.receiver_id,
    caller_info.country_id AS caller_country,
    receiver_info.country_id AS receiver_country,
    CASE
      WHEN caller_info.country_id <> receiver_info.country_id THEN 1
      ELSE 0
    END AS is_international
  FROM phone_calls pc
  JOIN phone_info caller_info
    ON pc.caller_id = caller_info.caller_id
  JOIN phone_info receiver_info
    ON pc.receiver_id = receiver_info.caller_id
) AS call_data;
