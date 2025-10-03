1-- This query retrieves the average weight of players for each conference in college football.
    select teams.conference as conference, avg(players.weight) as avg_weight 
    -- select columns conference from teams and label it as conference, takes average of weight from table players and labels it as avg_weight
    From benn.college_footbal_players players
    -- from db benn takes table college_footbal_players and labels it as players
    Join benn.college_football_teams teams
    -- joins table college_football_teams and labels it as teams and stars the join
    On teams.school_name = players.school_name
    -- condition on which join occurs or basically the common column between the two tables
    group by teams.conference 
    -- groups the results by conference
    -- so that the average weight is calculated for each conference
    order by avg_weight desc;
    -- orders the results by average weight in descending order

--Write a query that selects the school name, player name, position, and weight for every player in Georgia, ordered by weight (heaviest to lightest). Be sure to make an alias for the table, and to reference all column names in relation to the alias.

-- 1. INNER JOIN
-- Returns only the rows where there is a match in both tables.
-- Commonly used to get related data from two tables.

-- Example:
-- SELECT *
-- FROM orders
-- INNER JOIN customers ON orders.customer_id = customers.id; Gives common rows

-- 2. LEFT JOIN (or LEFT OUTER JOIN)
-- Returns all rows from the left table, and the matching rows from the right table.
-- If no match is found, NULL is returned for right table columns.

-- Example:
-- SELECT *
-- FROM customers
-- LEFT JOIN orders ON customers.id = orders.customer_id;

-- 3. RIGHT JOIN (or RIGHT OUTER JOIN)
-- Returns all rows from the right table, and the matching rows from the left table.
-- If no match is found, NULL is returned for left table columns.

-- Example:
-- SELECT *
-- FROM orders
-- RIGHT JOIN customers ON orders.customer_id = customers.id;

-- 4. FULL JOIN (or FULL OUTER JOIN)
-- Returns rows when there is a match in one of the tables.
-- If there is no match, NULLs are returned for missing side.

-- Example:
-- SELECT *
-- FROM customers
-- FULL JOIN orders ON customers.id = orders.customer_id;

-- 5. CROSS JOIN
-- Returns the Cartesian product of both tables (every combination).
-- Use with caution – can return a lot of rows.

-- Example:
-- SELECT *
-- FROM customers
-- CROSS JOIN products;

-- 6. SELF JOIN
-- A table is joined with itself. Useful for comparing rows in the same table.

-- Example:
-- SELECT A.name AS Employee, B.name AS Manager
-- FROM employees A
-- JOIN employees B ON A.manager_id = B.id;