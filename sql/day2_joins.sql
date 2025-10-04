--175. Combine Two Tables

select p.firstname , p.lastName , a.city , a.state
from person p
left join Address a
on p.personId = a.personId;


--183. Customers Who Never Order

select c.name as Customers
from Customers c
left join Orders o 
on c.id = o.customerId
where o.customerId is Null;

---1068. Product Sales Analysis I
select p.product_name , s.year , s.price
from sales s
join product p
on s.product_id = p.product_id;