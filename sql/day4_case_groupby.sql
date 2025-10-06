-- 1174. Immediate Food Delivery II
select round(100*sum(case when order_date = customer_pref_delivery_date then 1 else 0 end )/count(*) , 2) as immediate_percentage 
from delivery
where (customer_id , order_date) in (select customer_id, min(order_date) from delivery
group by customer_id);


-- 1179. Reformat Department Table
SELECT
  id,
  SUM(CASE WHEN month = 'Jan' THEN revenue END) AS Jan_Revenue,
  SUM(CASE WHEN month = 'Feb' THEN revenue END) AS Feb_Revenue,
  SUM(CASE WHEN month = 'Mar' THEN revenue END) AS Mar_Revenue,
  SUM(CASE WHEN month = 'Apr' THEN revenue END) AS Apr_Revenue,
  SUM(CASE WHEN month = 'May' THEN revenue END) AS May_Revenue,
  SUM(CASE WHEN month = 'Jun' THEN revenue END) AS Jun_Revenue,
  SUM(CASE WHEN month = 'Jul' THEN revenue END) AS Jul_Revenue,
  SUM(CASE WHEN month = 'Aug' THEN revenue END) AS Aug_Revenue,
  SUM(CASE WHEN month = 'Sep' THEN revenue END) AS Sep_Revenue,
  SUM(CASE WHEN month = 'Oct' THEN revenue END) AS Oct_Revenue,
  SUM(CASE WHEN month = 'Nov' THEN revenue END) AS Nov_Revenue,
  SUM(CASE WHEN month = 'Dec' THEN revenue END) AS Dec_Revenue
FROM Department
GROUP BY id;