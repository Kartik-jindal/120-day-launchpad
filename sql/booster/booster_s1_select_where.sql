-- S1: SELECT/WHERE/ORDER + NULLs (Oct 7, 2025)

-- 1) Basic SELECT + ORDER (customers created since 2025-01-01)
SELECT customer_id, name, DATE(created_at) AS created_dt
FROM customers
WHERE DATE(created_at) >= '2025-01-01'
ORDER BY created_dt DESC;

-- 2) WHERE with multiple conditions (non-cancelled orders in Feb–Mar 2025)
SELECT order_id, customer_id, status, created_at
FROM orders
WHERE status != 'cancelled'
  AND DATE(created_at) BETWEEN '2025-02-01' AND '2025-03-31'
ORDER BY created_at;

-- 3) NULL handling (anti-join): customers who never had a paid order
WITH paid AS (
  SELECT DISTINCT customer_id FROM orders WHERE status = 'paid'
)
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN paid p ON p.customer_id = c.customer_id
WHERE p.customer_id IS NULL;  -- use IS NULL, not "= NULL"

-- 4) LeetCode 175: Combine Two Tables

SELECT p.FirstName, p.LastName, a.City, a.State
FROM Person p
LEFT JOIN Address a ON a.PersonId = p.PersonId;

-- 5) LeetCode 181: Employees Earning More Than Their Managers

SELECT e.Name AS Employee
FROM Employee e
JOIN Employee m ON e.ManagerId = m.Id
WHERE e.Salary > m.Salary;
