-- -- Try pulling all the data from the accounts table, and all the data from the orders table.
SELECT *
FROM accounts
JOIN orders ON accounts.id = orders.account_id
LIMIT 10;


-- -- Try pulling standard_qty, gloss_qty, and poster_qty from the orders table, and the website and
-- -- the primary_poc from the accounts table
SELECT
orders.standard_qty, orders.gloss_qty, orders.poster_qty,
accounts.website, accounts.primary_poc
FROM accounts
JOIN orders ON accounts.id = orders.account_id
LIMIT 10;


-- -- Provide a table for all web_events associated with account name of Walmart. There should be three columns. Be sure to
-- -- include the primary_poc, time of the event, and the channel for each event. Additionally, you might choose to add a
-- -- fourth column to assure only Walmart events were chosen.
SELECT
a.name, a.primary_poc,
w.occurred_at, w.channel
FROM accounts AS a
JOIN web_events AS w ON w.account_id = a.id
WHERE a.name LIKE 'Walmart';

-- -- Provide a table that provides the region for each sales_rep along with their associated accounts. Your final table should
-- -- include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z)
-- -- according to account name.
SELECT
r.name AS region,
s.name AS Sales Rep,
a.name AS Account Name
FROM accounts AS a
JOIN sales_reps AS s ON a.sales_rep_id = s.id
JOIN region AS r ON r.id = s.region_id
LIMIT 10;

-- Provide the name for each region for every order, as well as the account name and the unit price they paid
-- (total_amt_usd/total) for the order. Your final table should have 3 columns: region name, account name, and unit price.
-- A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.

-- using CAST(YOURCOLUMN AS DECIMAL(PRECISION,SCALE)) a will round your column to the parameters you set
-- For instance, decimal (4,2) indicates that the number will have 2 digits before the decimal point and 2 digits after the
-- decimal point, something like this has to be the number value- ##.##.
-- One important thing to note here is, ??? parameter s (Scale) can only be specified if p (Precision) is specified.
-- The scale must always be less than or equal to the precision.
SELECT
r.name,
a.name,
CAST((o.total_amt_usd / (o.total + 0.01)) AS DECIMAL(10,2)) AS unit_price
FROM orders AS o
JOIN accounts AS a ON o.account_id = a.id
JOIN sales_reps AS s ON s.id = a.sales_rep_id
JOIN region AS r ON r.id = s.region_id
LIMIT 10;


-- Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for the
-- Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account
-- name. Sort the accounts alphabetically (A-Z) according to account name.
SELECT
r.name AS region,
s.name AS sales_rep,
a.name AS account
FROM region AS r
JOIN sales_reps AS s ON s.region_id = r.id
JOIN accounts AS a ON a.sales_rep_id = s.id
WHERE r.name LIKE 'Midwest'
ORDER BY a.name ASC;

-- Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for
-- accounts where the sales rep has a first name starting with S and in the Midwest region. Your final table should include
-- three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according
-- to account name.
SELECT
r.name AS region,
s.name AS sales_rep,
a.name AS account
FROM region AS r
JOIN sales_reps AS s ON s.region_id = r.id
JOIN accounts AS a ON a.sales_rep_id = s.id
WHERE r.name LIKE 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name ASC;

-- Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for
-- accounts where the sales rep has a last name starting with K and in the Midwest region. Your final table should include
-- three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according
-- to account name.
SELECT
r.name AS region,
s.name AS sales_rep,
a.name AS account
FROM region AS r
JOIN sales_reps AS s ON s.region_id = r.id
JOIN accounts AS a ON a.sales_rep_id = s.id
WHERE r.name LIKE 'Midwest' AND s.name LIKE '% K%'
ORDER BY a.name ASC;

-- Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total)
-- for the order. However, you should only provide the results if the standard order quantity exceeds 100. Your final table
-- should have 3 columns: region name, account name, and unit price. In order to avoid a division by zero error, adding .01
-- to the denominator here is helpful total_amt_usd/(total+0.01).
SELECT
r.name AS region,
a.name AS account,
CAST((o.total_amt_usd / (o.total + 0.01)) AS DECIMAL(10,2)) AS unit_price
FROM region AS r
JOIN sales_reps AS s ON s.region_id = r.id
JOIN accounts AS a ON a.sales_rep_id = s.id
JOIN orders AS o ON a.id = o.account_id
WHERE o.standard_qty > 100;

-- Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total)
-- for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster
-- order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for
-- the smallest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is
-- helpful (total_amt_usd/(total+0.01).
SELECT
r.name AS region,
a.name AS account,
CAST((o.total_amt_usd / (o.total + 0.01)) AS DECIMAL(10,2)) AS unit_price
FROM region AS r
JOIN sales_reps AS s ON s.region_id = r.id
JOIN accounts AS a ON a.sales_rep_id = s.id
JOIN orders AS o ON a.id = o.account_id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price ASC;

-- Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total)
-- for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster
-- order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for
-- the largest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is
-- helpful (total_amt_usd/(total+0.01).
SELECT
r.name AS region,
a.name AS account,
CAST((o.total_amt_usd / (o.total + 0.01)) AS DECIMAL(10,2)) AS unit_price
FROM region AS r
JOIN sales_reps AS s ON s.region_id = r.id
JOIN accounts AS a ON a.sales_rep_id = s.id
JOIN orders AS o ON a.id = o.account_id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price DESC;

-- What are the different channels used by account id 1001? Your final table should have only 2 columns: account name and the
-- different channels. You can try SELECT DISTINCT to narrow down the results to only the unique values.
SELECT DISTINCT
a.name,
w.channel
FROM accounts AS a
JOIN web_events AS w ON a.id = w.account_id
WHERE a.id = 1001;

-- Find all the orders that occurred in 2015. Your final table should have 4 columns: occurred_at, account name, order
-- total, and order total_amt_usd.
SELECT
o.occurred_at,
a.name,
o.total,
o.total_amt_usd
FROM orders as o
JOIN accounts as a ON o.account_id = a.id
-- WHERE o.occurred_at BETWEEN '01/01/2015 00:00:00' AND '12/31/2015 11:59:59';
WHERE EXTRACT(YEAR FROM o.occurred_at) = 2015;
