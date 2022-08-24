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
