``` Average Review Ratings
Amazon SQL Interview Question ```
SELECT EXTRACT(MONTH FROM submit_date) AS mth,
product_id as product ,
round(avg(stars),2) as avg_stars
FROM reviews
GROUP by Extract(MONTH FROM submit_date), product
order by mth , product
;

'''Average Post Hiatus (Part 1)
Facebook SQL Interview Question
'''
SELECT user_id,
DATEDIFF(MAX(DATE(post_date)), Min(date(post_date))) as days_between
''' datediff gives difference between two dates in days , date() makes sure time part is removed and we deal only in dates 
, max and min to get the first and last post dates'''
FROM posts
where year(post_date) = 2021
group by user_id
having count(post_id) >1;

'''Cities With Completed Trades
Robinhood SQL Interview Question'''

SELECT u.city, COUNT(*) AS total_orders
FROM users u
JOIN trades t 
  ON u.user_id = t.user_id
WHERE t.status = 'Completed'
GROUP BY u.city
ORDER BY total_orders DESC
LIMIT 3;


