--This file contains notes on the logical order of SQL operations.
--Understanding this order is crucial for writing correct SQL queries, especially when using clauses like WHERE,
--GROUP BY, HAVING, and ORDER BY.
--Logical Order of SQL Operations


-- STEP 1: FROM / JOIN
-- The database first identifies the tables in the `FROM` clause and performs all the `JOIN` operations.
-- The result is a giant, temporary, in-memory table that contains all possible combinations of rows that meet the join conditions.

-- STEP 2: WHERE
-- Next, the `WHERE` clause is applied to this giant temporary table.
-- It scans each individual row and discards any row that does not meet the filter conditions.
-- CRITICAL: This happens *before* any grouping. `WHERE` knows nothing about groups or aggregate functions like COUNT().

-- STEP 3: GROUP BY
-- With the rows that survived the `WHERE` filter, the database now uses the `GROUP BY` clause.
-- It collapses all rows that have the same value in the `GROUP BY` column(s) into a single summary row.

-- STEP 4: HAVING
-- After the groups have been created, the `HAVING` clause is applied.
-- It filters these new summary rows (the groups themselves).
-- CRITICAL: Because this happens *after* `GROUP BY`, you can use aggregate functions here (e.g., `HAVING COUNT(*) > 10`). This is the key difference between `HAVING` and `WHERE`.

-- STEP 5: SELECT
-- Only now does the database look at the `SELECT` list.
-- It calculates any final aggregate functions (like `COUNT()`, `SUM()`, `AVG()`) for the remaining groups.
-- It then picks out the final columns and expressions that you requested to be in the output.

-- STEP 6: ORDER BY
-- Finally, if there is an `ORDER BY` clause, the database sorts the final set of rows that resulted from all the previous steps.
-- This is always the last operation performed.