-- 1) Revenue per order; keep only large orders (>= 1000)
SELECT
  oi.order_id,
  SUM(oi.qty * oi.price) AS revenue
FROM order_items oi
GROUP BY oi.order_id
HAVING SUM(oi.qty * oi.price) >= 1000
ORDER BY revenue DESC;

-- 2) Revenue per customer (include customers with 0 revenue)
WITH order_totals AS (
  SELECT
    o.order_id,
    o.customer_id,
    SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY o.order_id, o.customer_id
)
SELECT
  c.customer_id,
  c.name,
  COALESCE(SUM(ot.rev), 0) AS revenue
FROM customers c
LEFT JOIN order_totals ot ON ot.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY revenue DESC, c.customer_id;

-- 3) COUNT flavors
SELECT
  COUNT(*) AS rows_all,
  COUNT(product) AS rows_non_null_product,
  COUNT(DISTINCT product) AS unique_products
FROM order_items;

-- 4) Customers with at least 2 paid orders (GROUP BY + HAVING)
SELECT
  c.customer_id,
  c.name,
  COUNT(*) AS paid_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'paid'
GROUP BY c.customer_id, c.name
HAVING COUNT(*) >= 2
ORDER BY paid_orders DESC, c.customer_id;

-- 5) Monthly revenue (uses SQLite strftime for YYYY-MM)
--    Adjust if your orders.created_at is stored differently.
WITH order_rev AS (
  SELECT
    o.order_id,
    SUM(oi.qty * oi.price) AS rev
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY o.order_id
)
SELECT
  strftime('%Y-%m', o.created_at) AS ym,
  SUM(orv.rev) AS revenue
FROM orders o
JOIN order_rev orv ON orv.order_id = o.order_id
GROUP BY ym
ORDER BY ym;

--  596 Classes More Than 5 Students
-- Example 
select class from courses
group by class
having count(class)>=5;
-- SELECT class
-- FROM Courses
-- GROUP BY class
-- HAVING COUNT(DISTINCT student) >= 5;

-- 6b) 1251 Average Selling Price
with ave as (SELECT P.PRODUCT_ID , SUM(PRICE*UNITS) AS TOTALSUM , SUM(UNITS) AS U
FROM prices p
left JOIN unitssold u 
  ON p.product_id = u.product_id
 AND u.purchase_date BETWEEN p.start_date AND p.end_date
 GROUP BY P.PRODUCT_ID)
 select ave.product_id , 
 case when ave.u IS NULL then 0 else
 round(ave.TOTALSUM*1.0 / ave.U,2) end as average_price from ave;
-- SELECT p.product_id,
--        ROUND(COALESCE(SUM(u.units * p.price) / NULLIF(SUM(u.units), 0), 0), 2) AS average_price
-- FROM Prices p
-- LEFT JOIN UnitsSold u
--   ON u.product_id = p.product_id
--  AND u.purchase_date BETWEEN p.start_date AND p.end_date
-- GROUP BY p.product_id
-- ORDER BY p.product_id;