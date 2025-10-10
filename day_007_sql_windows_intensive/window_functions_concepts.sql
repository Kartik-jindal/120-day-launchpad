Core Syntax: FUNCTION() OVER (PARTITION BY ... ORDER BY ...)

1. FUNCTION(): The specific calculation to be performed (e.g., RANK(), SUM(), LAG()).

2. OVER(): The non-negotiable keyword that signals the start of a window function clause.

3. PARTITION BY <column(s)>: This is the "magic." It divides the dataset into independent groups or "windows." The function is applied and calculated separately for each partition. When the value of the partitioning column changes, the function resets.

4. ORDER BY <column(s)>: This sorts the rows *within each partition*. This is essential for functions that depend on order, like RANK(), LEAD(), and LAG().

Ranking Functions:
RANK(): "Standard competition ranking. Handles ties by skipping the next rank(s). (1, 2, 2, 4)"
DENSE_RANK(): "Handles ties without skipping ranks. (1, 2, 2, 3)"
ROW_NUMBER(): "Assigns a unique number to each row, ignoring ties. (1, 2, 3, 4)"
Offset Functions:
LAG(column, offset, default_value): "Looks backwards a number of rows (offset) within the partition and returns the value of column from that row."
LEAD(column, offset, default_value): "Looks forwards a number of rows (offset) within the partition and returns the value of column from that row."