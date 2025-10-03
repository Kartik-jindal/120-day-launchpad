-- 1) Basic projection
-- SELECT first_name, last_name FROM employees;

-- 2) Filters with AND/OR
-- SELECT * FROM orders WHERE total > 100 AND status = 'paid';

-- 3) IN + BETWEEN
-- SELECT * FROM products WHERE category IN ('A','B') AND price BETWEEN 10 AND 50;

-- 4) LIKE for pattern matching
-- SELECT * FROM users WHERE email LIKE '%@gmail.com';

-- 5) NULL-safe filtering
-- SELECT * FROM events WHERE cancelled IS NULL; -- not "= NULL"