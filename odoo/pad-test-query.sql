-- With the Fact that these tables are populated with 10000 users and 30 cities.
-- 10.2) Write a SQL query to find cities with highest number of users and reutrn city id,name and number
-- users in descending order.
SELECT
    c.id,
    c.name,
    COUNT(*) as num_users
FROM cities as c
JOIN users as u ON u.city_id = c.id
GROUP BY c.name, c.id
ORDER BY num_users DESC;

-- 10.3) How would you populate the tables with ramdon test datas for a tables created at problem 1.
-- answer is in pad-test.js
