-- Find the total amount of poster_qty paper ordered in the orders table.
SELECT
    SUM(poster_qty) AS poster_qty_total
FROM orders;

-- Find the total amount of standard_qty paper ordered in the orders table.
SELECT
    SUM(standard_qty) AS standard_qty_total
FROM orders;

-- Find the total dollar amount of sales using the total_amt_usd in the orders table.
SELECT
    SUM(total_amt_usd) AS sales_total
FROM orders;

-- Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table.
-- This should give a dollar amount for each order in the table.
SELECT
    standard_amt_usd + gloss_amt_usd AS std_gloss_total_usd
FROM orders;

-- Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both an aggregation and a
-- mathematical operator.
SELECT
    CAST(SUM(standard_amt_usd) / SUM(standard_qty) AS DECIMAL(10,2)) AS avg_unit_price
FROM orders;

-- When was the earliest order ever placed? You only need to return the date.
SELECT
    MIN(occurred_at) AS earliest_order
FROM orders;

-- Try performing the same query as in question 1 without using an aggregation function.
SELECT
    occurred_at
FROM orders
ORDER BY occurred_at ASC
LIMIT 1;

-- When did the most recent (latest) web_event occur?
SELECT
    MAX(occurred_at) AS latest_web_event
FROM web_events;

-- Try to perform the result of the previous query without using an aggregation function.
SELECT
    occurred_at AS latest_web_event
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

-- Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type
-- purchased per order. Your final answer should have 6 values - one for each paper type for the average number of
-- sales, as well as the average amount.
SELECT
    CAST(AVG(standard_amt_usd) AS DECIMAL(10,2)) AS avg_std_usd_spend,
    CAST(AVG(gloss_amt_usd) AS DECIMAL(10,2)) AS avg_gloss_usd_spent,
    CAST(AVG(poster_amt_usd) AS DECIMAL(10,2)) AS avg_poster_usd_spent,
    CAST(AVG(standard_qty) AS DECIMAL(10,2)) AS avg_std_qty,
    CAST(AVG(gloss_qty) AS DECIMAL(10,2)) AS avg_gloss_qty,
    CAST(AVG(poster_qty) AS DECIMAL(10,2)) AS avg_poster_qty
FROM orders;


-- Via the video, you might be interested in how to calculate the MEDIAN. Though this is more advanced than what we
-- have covered so far try finding - what is the MEDIAN total_usd spent on all orders?

-- this chunk of code build a median aggregate that you can use
CREATE OR REPLACE FUNCTION _final_median(numeric[])
   RETURNS numeric AS
$$
   SELECT AVG(val)
   FROM (
     SELECT val
     FROM unnest($1) val
     ORDER BY 1
     LIMIT  2 - MOD(array_upper($1, 1), 2)
     OFFSET CEIL(array_upper($1, 1) / 2.0) - 1
   ) sub;
$$
LANGUAGE 'sql' IMMUTABLE;

CREATE AGGREGATE median(numeric) (
  SFUNC=array_append,
  STYPE=numeric[],
  FINALFUNC=_final_median,
  INITCOND='{}'
);

SELECT median(total_amt_usd) AS median_value FROM orders;

-- this is how you can calculate it without having to define a median function. MEDIAN is 50th percentile
-- PERCENTILE_CONT(fraction) returns a value at the specified fraction in the ordered grouping
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY total_amt_usd) FROM orders;


-- Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
SELECT
    a.name,
    o.occurred_at AS earliest_order
FROM accounts AS a
JOIN orders AS o ON a.id = o.account_id
ORDER BY earliest_order ASC
LIMIT 1;


-- Find the total sales in usd for each account. You should include two columns - the total sales for each company's
-- orders in usd and the company name.
SELECT
    a.name,
    SUM(o.total_amt_usd) AS total_sales
FROM accounts AS a
JOIN orders AS o ON o.account_id = a.id
GROUP BY a.name;

-- Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event?
-- Your query should return only three values - the date, channel, and account name.
SELECT
    a.name,
    w.channel,
    w.occurred_at AS latest_date
FROM web_events AS w
JOIN accounts AS a ON w.account_id = a.id
ORDER BY latest_date DESC
LIMIT 1;



-- Find the total number of times each type of channel from the web_events was used. Your final table should have two
-- columns - the channel and the number of times the channel was used.
SELECT
    COUNT(w.id) AS times_used,
    w.channel
FROM web_events AS w
GROUP BY w.channel;

-- Who was the primary contact associated with the earliest web_event?
SELECT
    a.primary_poc
FROM web_events AS w
JOIN accounts AS a ON a.id = w.account_id
GROUP BY a.primary_poc, w.occurred_at
ORDER BY w.occurred_at ASC
LIMIT 1;

-- What was the smallest order placed by each account in terms of total usd. Provide only two columns - the
-- account name and the total usd. Order from smallest dollar amounts to largest.
SELECT
    a.name,
    MIN(o.total_amt_usd) AS smallest_order_sales
FROM accounts AS a
JOIN orders as o ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order_sales;

-- Find the number of sales reps in each region. Your final table should have two columns - the region and
-- the number of sales_reps. Order from fewest reps to most reps.
SELECT
    r.name,
    COUNT(s.id) AS num_sales_reps
FROM region as r
JOIN sales_reps AS s ON s.region_id = r.id
GROUP BY r.name
ORDER BY num_sales_reps;


-- For each account, determine the average amount of each type of paper they purchased across their orders. Your
-- result should have four columns - one for the account name and one for the average quantity purchased for each
-- of the paper types for each account.
SELECT
    a.name,
    CAST(AVG(o.standard_qty) AS DECIMAL(10,2)) AS standard_qty_avg,
    CAST(AVG(o.gloss_qty) AS DECIMAL(10,2)) AS gloss_qty_avg,
    CAST(AVG(o.poster_qty) AS DECIMAL(10,2)) AS poster_qty_avg
FROM accounts AS a
JOIN orders AS o ON o.account_id = a.id
GROUP BY a.name
ORDER BY a.name;


-- For each account, determine the average amount spent per order on each paper type. Your result should have
-- four columns - one for the account name and one for the average amount spent on each paper type.
SELECT
    a.name,
    CAST(AVG(o.standard_amt_usd) AS MONEY) AS standard_sales_avg,
    CAST(AVG(o.gloss_amt_usd) AS MONEY) AS gloss_sales_avg,
    CAST(AVG(o.poster_amt_usd) AS MONEY) AS poster_sales_avg
FROM accounts AS a
JOIN orders AS o ON o.account_id = a.id
GROUP BY a.name
ORDER BY a.name;

-- Determine the number of times a particular channel was used in the web_events table for each sales rep. Your
-- final table should have three columns - the name of the sales rep, the channel, and the number of occurrences.
-- Order your table with the highest number of occurrences first.
SELECT
    s.name,
    w.channel,
    COUNT(*) AS occurrences
FROM web_events AS w
JOIN accounts AS a ON w.account_id = a.id
JOIN sales_reps AS s ON a.sales_rep_id = s.id
GROUP BY s.name, w.channel
ORDER BY occurrences DESC;


-- Determine the number of times a particular channel was used in the web_events table for each region. Your
-- final table should have three columns - the region name, the channel, and the number of occurrences. Order your
-- table with the highest number of occurrences first.
SELECT
    r.name,
    w.channel,
    COUNT(*) AS occurrences
FROM web_events AS w
JOIN accounts AS a ON w.account_id = a.id
JOIN sales_reps AS s ON s.id = a.sales_rep_id
JOIN region AS r ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY occurrences DESC;


-- Use DISTINCT to test if there are any accounts associated with more than one region.
SELECT DISTINCT
    a.id AS "account_id",
    r.id AS "region_id",
    a.name,
    r.name
FROM accounts AS a
JOIN sales_reps AS s ON s.id = a.sales_rep_id
JOIN region AS r ON r.id = s.region_id;

SELECT DISTINCT id, name
FROM accounts;

-- Have any sales reps worked on more than one account?
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;

SELECT DISTINCT id, name
FROM sales_reps;


-- How many of the sales reps have more than 5 accounts that they manage?
SELECT
    s.id,
    s.name,
    COUNT(*) AS num_accounts
FROM sales_reps AS s
JOIN accounts AS a ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;


-- How many accounts have more than 20 orders?
SELECT
    a.id,
    a.name,
    COUNT(*) AS num_orders
FROM accounts AS a
JOIN orders AS o ON o.account_id = a.id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY num_orders;


-- Which account has the most orders?
SELECT
    a.id,
    a.name,
    COUNT(*) AS num_orders
FROM accounts AS a
JOIN orders AS o ON o.account_id = a.id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1;

-- Which accounts spent more than 30,000 usd total across all orders?
SELECT
    a.id AS account_id,
    a.name,
    CAST(SUM(o.total_amt_usd) AS MONEY) AS total_sales
FROM accounts AS a
JOIN orders AS o ON o.account_id = a.id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 20000
ORDER BY total_sales DESC
LIMIT 10;

-- Which accounts spent less than 1,000 usd total across all orders?
SELECT
    a.id AS account_id,
    a.name,
    CAST(SUM(o.total_amt_usd) AS MONEY) AS total_sales
FROM accounts AS a
JOIN orders AS o ON o.account_id = a.id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_sales DESC
LIMIT 10;

-- Which account has spent the most with us?
SELECT
    a.id AS account_id,
    a.name,
    CAST(SUM(o.total_amt_usd) AS MONEY) AS total_sales
FROM accounts AS a
JOIN orders AS o ON o.account_id = a.id
GROUP BY a.id, a.name
ORDER BY total_sales DESC
LIMIT 1;

-- Which account has spent the least with us?
SELECT
    a.id AS account_id,
    a.name,
    CAST(SUM(o.total_amt_usd) AS MONEY) AS total_sales
FROM accounts AS a
JOIN orders AS o ON o.account_id = a.id
GROUP BY a.id, a.name
ORDER BY total_sales ASC
LIMIT 1;

-- Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT
    a.id AS account_id,
    a.name,
    COUNT(*) AS occurrences
FROM accounts AS a
JOIN web_events AS w ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING w.channel = 'facebook' AND COUNT(*) > 6;

-- Which account used facebook most as a channel?
SELECT
    a.id AS account_id,
    a.name,
    COUNT(*) AS occurrences
FROM accounts AS a
JOIN web_events AS w ON a.id = w.account_id
-- ORDER BY w.channel = 'facebook' | this works too instead of HAVING
GROUP BY a.id, a.name, w.channel
HAVING w.channel = 'facebook'
ORDER BY occurrences DESC
LIMIT 1;
-- Note: This query above only works if there are no ties for the account that used facebook the most. It is a best practice to use a larger
-- limit number first such as 3 or 5 to see if there are ties before using LIMIT 1.

-- Which channel was most frequently used by most accounts?
SELECT
    a.id AS account_id,
    a.name,
    w.channel,
    COUNT(*) AS occurrences
FROM accounts AS a
JOIN web_events AS w ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY occurrences DESC
LIMIT 10;


-- Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least.
-- Do you notice any trends in the yearly sales totals?
SELECT
    EXTRACT(YEAR FROM o.occurred_at) AS year,
    CAST(SUM(o.total_amt_usd) AS MONEY) AS total_sales
FROM orders AS o
GROUP BY EXTRACT(YEAR FROM o.occurred_at)
ORDER BY EXTRACT(YEAR FROM o.occurred_at) DESC;


-- Which month did Parch & Posey have the greatest sales in terms of total dollars?
-- Are all months evenly represented by the dataset?
SELECT
    EXTRACT(MONTH FROM o.occurred_at) AS MONTH,
    -- DATE_PART('month',  o.occurred_at) AS month, | this works too
    CAST(SUM(o.total_amt_usd) AS MONEY) AS total_sales
FROM orders AS o
GROUP BY EXTRACT(MONTH FROM o.occurred_at)
ORDER BY EXTRACT(MONTH FROM o.occurred_at) DESC;


-- Which year did Parch & Posey have the greatest sales in terms of total number of orders?
-- Are all years evenly represented by the dataset?
SELECT
    EXTRACT(YEAR FROM o.occurred_at) AS year,
    SUM(o.total) AS total_qty_sold
FROM orders AS o
GROUP BY EXTRACT(YEAR FROM o.occurred_at)
ORDER BY EXTRACT(YEAR FROM o.occurred_at) DESC;

-- Which month did Parch & Posey have the greatest sales in terms of total number of orders?
-- Are all months evenly represented by the dataset?
SELECT
    EXTRACT(MONTH FROM o.occurred_at) AS MONTH,
    SUM(o.total) AS total_qty_sold
FROM orders AS o
GROUP BY EXTRACT(MONTH FROM o.occurred_at)
ORDER BY EXTRACT(MONTH FROM o.occurred_at) DESC;

-- In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT
    EXTRACT(MONTH FROM o.occurred_at) AS MONTH,
    EXTRACT(YEAR FROM o.occurred_at) AS year,
    SUM(o.gloss_amt_usd) AS gloss_usd_spent
FROM orders AS o
JOIN accounts AS a ON a.id = o.account_id
WHERE a.name LIKE 'Walmart'
GROUP BY EXTRACT(MONTH FROM o.occurred_at), EXTRACT(YEAR FROM o.occurred_at)
ORDER BY SUM(o.gloss_amt_usd) DESC;


-- Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for standard
-- paper for each order. Limit the results to the first 10 orders, and include the id and account_id fields.
-- NOTE - you will be thrown an error with the correct solution to this question. This is for a division by zero.
-- You will learn how to get a solution without an error to this query when you learn about CASE statements in a later section.
-- Now, let's use a CASE statement. This way any time the standard_qty is zero, we will return 0, and otherwise we will return the unit_price.
-- SELECT
--     account_id,
--     CASE
--     WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
--         ELSE standard_amt_usd/standard_qty END AS unit_price
-- FROM orders
-- LIMIT 10;


-- -- Write a query to display for each order, the account ID, total amount of the order, and the level of the order -
-- -- ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
-- SELECT
--     account_id,
--     total_amt_usd,
--     CASE WHEN total_amt_usd > 3000 THEN 'Large'
--     ELSE 'Small' END AS order_level
-- FROM orders
-- LIMIT 20;

-- -- Write a query to display the number of orders in each of three categories, based on the total number of items
-- -- in each order. The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
-- SELECT
--     CASE WHEN total >= 2000 THEN 'At least 2000'
--          WHEN total < 2000 AND total >= 1000 THEN 'Between 1000 and 2000'
--          ELSE 'Less than 1000' END AS order_category,
--     COUNT(*) AS order_count
-- FROM orders
-- -- BELOW: group by the first column of your result set regardless of what it's called.
-- GROUP BY 1;



-- -- We would like to understand 3 different lev;els of customers based on the amount associated with their purchases.
-- -- The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd.
-- -- The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. Provide a
-- -- table that includes the level associated with each account. You should provide the account name, the total sales
-- -- of all orders for the customer, and the level. Order with the top spending customers listed first.
-- SELECT
--     a.name,
--     CAST(SUM(o.total_amt_usd) AS MONEY) AS total_sales,
--     CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Top'
--          WHEN SUM(o.total_amt_usd) <= 200000 AND SUM(o.total_amt_usd) >= 100000 THEN 'Second'
--          ELSE 'lowest' END AS level
-- FROM accounts AS a
-- JOIN orders AS o ON a.id = o.account_id
-- GROUP BY a.name
-- ORDER BY total_sales DESC;


-- -- We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by
-- -- customers only in 2016 and 2017. Keep the same levels as in the previous question. Order with the top spending
-- -- customers listed first.
-- SELECT
--     a.name,
--     CAST(SUM(o.total_amt_usd) AS MONEY) AS total_sales,
--     CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Top'
--          WHEN SUM(o.total_amt_usd) <= 200000 AND SUM(o.total_amt_usd) >= 100000 THEN 'Second'
--          ELSE 'lowest' END AS level
-- FROM accounts AS a
-- JOIN orders AS o ON a.id = o.account_id
-- WHERE EXTRACT(YEAR FROM o.occurred_at) BETWEEN 2016 AND 2017
-- GROUP BY a.name
-- ORDER BY total_sales DESC;

-- -- We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders.
-- -- Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if
-- -- they have more than 200 orders. Place the top sales people first in your final table.
-- SELECT
--     s.name,
--     COUNT(*) AS num_orders,
--     CASE WHEN COUNT(*) > 200 THEN 'yes'
--     ELSE 'no' END AS top_performing
-- FROM sales_reps AS s
-- JOIN accounts as a ON a.sales_rep_id = s.id
-- JOIN orders AS o ON o.account_id = a.id
-- GROUP BY s.name
-- ORDER BY num_orders DESC;

-- -- -- The previous didn't account for the middle, nor the dollar amount associated with the sales. Management decides
-- -- they want to see these characteristics represented as well. We would like to identify top performing sales reps,
-- -- which are sales reps associated with more than 200 orders or more than 750000 in total sales. The middle group has
-- -- any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, the total number of
-- -- orders, total sales across all orders, and a column with top, middle, or low depending on this criteria. Place the
-- -- top sales people based on dollar amount of sales first in your final table. You might see a few upset sales people
-- -- by this criteria!
-- SELECT
--     s.name,
--     COUNT(*) AS num_orders,
--     CAST(SUM(o.total_amt_usd) AS MONEY) AS total_sales,
--     CASE WHEN COUNT(*) > 200 OR  SUM(o.total_amt_usd) > 750000 THEN 'top'
--          WHEN COUNT(*) > 150 AND SUM(o.total_amt_usd) > 500000 THEN 'middle'
--          ELSE 'low' END AS Performance
-- FROM sales_reps AS s
-- JOIN accounts AS a ON a.sales_rep_id = s.id
-- JOIN orders AS o ON o.account_id = a.id
-- GROUP BY s.name
-- ORDER BY total_sales DESC;
