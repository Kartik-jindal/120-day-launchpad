--  code for lc1782_rank_scores.sql
select score ,
dense_rank() over (order by score desc) as 'rank'
from scores;

-- code for lc181 employees earning more than their managers.sql
select em.name as 'Employee'
from Employee as em
join Employee as ma
on em.managerid = ma.id 
where em.salary > ma.salary;

-- code for lc 183 customers who never order.sql
select c.name as Customers
from Customers c
left join Orders o 
on c.id = o.customerId
where o.customerId is Null;

-- code for lc 175 combine two tables.sql
select p.firstname , p.lastName , a.city , a.state
from person p
left join Address a
on p.personId = a.personId;

-- code for lc 1251 average selling price.sql
with ave as (SELECT P.PRODUCT_ID , SUM(PRICE*UNITS) AS TOTALSUM , SUM(UNITS) AS U
FROM prices p
left JOIN unitssold u 
  ON p.product_id = u.product_id
 AND u.purchase_date BETWEEN p.start_date AND p.end_date
 GROUP BY P.PRODUCT_ID)
 select ave.product_id , 
 case when ave.u IS NULL then 0 else
 round(ave.TOTALSUM*1.0 / ave.U,2) end as average_price from ave;