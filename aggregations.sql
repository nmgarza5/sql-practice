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
