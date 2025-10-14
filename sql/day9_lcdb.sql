-- 183. Customers Who Never Order


# Write your MySQL query statement below
select c.name as Customers
from Customers c
left join Orders o 
on c.id = o.customerId
where o.customerId is Null;


-- 1251. Average Selling Price
with ave as (SELECT P.PRODUCT_ID , SUM(PRICE*UNITS) AS TOTALSUM , SUM(UNITS) AS U
FROM prices p
left JOIN unitssold u 
ON p.product_id = u.product_id
AND u.purchase_date BETWEEN p.start_date AND p.end_date
GROUP BY P.PRODUCT_ID)
select ave.product_id , 
case when ave.u IS NULL then 0 else
round(ave.TOTALSUM*1.0 / ave.U,2) end as average_price from ave;