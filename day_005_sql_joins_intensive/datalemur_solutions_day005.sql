-- Highest-Grossing Items

WITH summed_spend AS ( -- created a Common Table Expression (CTE) to hold intermediate results of total spend per product per category
  SELECT 
    category, 
    product, 
    SUM(spend) AS total_spend
  FROM product_spend
  WHERE YEAR(transaction_date) = 2022
  GROUP BY category, product
),

ranked AS ( -- Step 2: Rank products within each category by total spend
  SELECT 
    category, 
    product, 
    total_spend, 
    ROW_NUMBER() OVER ( -- Window function to rank products by spend within each category 
      PARTITION BY category -- works like a GROUP BY for window functions 
      ORDER BY total_spend DESC -- highest spend first
    ) AS `rank`
  FROM summed_spend -- taken from the previous made summed_spend CTE by reference 
)

SELECT 
  category, 
  product, 
  total_spend
FROM ranked
WHERE `rank` <= 2
ORDER BY category, total_spend DESC;
