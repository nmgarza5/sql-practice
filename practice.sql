-- displays data from  orders, accounts, and sales_rep tables via joins
SELECT
orders.occurred_at, orders.total, orders.total_amt_usd,
accounts.name,
sales_reps.name
FROM orders
JOIN accounts on (orders.account_id = accounts.id)
JOIN sales_reps on (accounts.sales_rep_id = sales_reps.id)
--where dollar amount is greater than 1000
WHERE orders.total_amt_usd > 1000
-- order by total descending (greatest to least) | *default: ascending is ASC (least to greates)
ORDER BY orders.total DESC
-- limit to 10
LIMIT 10;


-- Write a query to return the 10 earliest orders in the orders table. Include the id,
-- occurred_at, and total_amt_usd.
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at ASC
LIMIT 10;

-- Write a query to return the top 5 orders in terms of largest total_amt_usd. Include the id,
-- account_id, and total_amt_usd.
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;


-- Write a query to return the lowest 20 orders in terms of smallest total_amt_usd. Include the
-- id, account_id, and total_amt_usd.
SELECT id, account_id, total_amt_usd
FROM orders
WHERE total_amt_usd > 0
ORDER BY total_amt_usd ASC
LIMIT 20;


-- Write a query that displays the order ID, account ID, and total dollar amount for all the orders,
-- sorted first by the account ID (in ascending order), and then by the total dollar amount (in descending order).
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id ASC, total_amt_usd DESC
LIMIT 10;

-- Now write a query that again displays order ID, account ID, and total dollar amount for each
-- order, but this time sorted first by total dollar amount (in descending order), and then by account ID (in ascending order).
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id ASC
LIMIT 10;


-- Pulls the first 5 rows and all columns from the orders table that have a dollar amount
-- of gloss_amt_usd greater than or equal to 1000.
SELECT *
FROM orders
WHERE gloss_amt_usd >= 1000

-- Pulls the first 10 rows and all columns from the orders table that have a total_amt_usd
-- less than 500.
