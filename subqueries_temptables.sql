-- We want to find the average number of events for each day for each channel. The first table
-- will provide us the number of events for each day and channel, and then we will need to
-- average these values together using a second query.
SELECT
    channel,
    CasT(AVG(num_events) as DECIMAL(10,2)) as avg_num_events
FROM
    (SELECT
        DATE_TRUNC('day', occurred_at) as day,
        channel,
        COUNT(*) as num_events
    FROM web_events
    GROUP BY 1,2) events_per_day
GROUP BY channel
ORDER BY 2 DESC;

--  sub query on the where clause. logical compariason available because subquery returns one value
-- it returns the month of the first order. Then we can find the average of all paper qty's
-- where the month is equal to the subquery (first month)
SELECT
    DATE_TRUNC('month', occurred_at) as first_month,
    CasT(AVG(standard_qty) as DECIMAL(10,2)) as standard_avg,
    CasT(AVG(gloss_qty) as DECIMAL(10,2)) as gloss_avg,
    CasT(AVG(poster_qty) as DECIMAL(10,2)) as poster_avg
FROM orders
WHERE
    DATE_TRUNC('month', occurred_at) =
    (SELECT
        DATE_TRUNC('month', MIN(occurred_at))
    FROM orders)
GROUP BY 1;



-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
SELECT
    t3.rep_name,
    t2.region,
    CAST(t3.total as MONEY)
FROM
    (SELECT
        region,
        MAX(total) as Total
    FROM
        (SELECT
            s.name as rep_name,
            r.name as region,
            SUM(o.total_amt_usd) as total
        FROM region as r
        JOIN sales_reps as s ON s.region_id = r.id
        JOIN accounts as a ON a.sales_rep_id = s.id
        JOIN orders as o ON o.account_id = a.id
        GROUP BY 1, 2) t1
    GROUP BY 1) t2
JOIN
    (SELECT
        s.name as rep_name,
        r.name as region,
        SUM(o.total_amt_usd) as total
    FROM region as r
    JOIN sales_reps as s ON s.region_id = r.id
    JOIN accounts as a ON a.sales_rep_id = s.id
    JOIN orders as o ON o.account_id = a.id
    GROUP BY 1, 2
    ORDER BY 3 DESC) t3
ON t3.region = t2.region AND t3.total = t2.total;



-- For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders
-- were placed?
-- OUTER QUERY: returns the count of all orders and region name where region id = result of
-- subquery(region with most sales)
SELECT
    r.name,
    COUNT(*) as order_count
FROM region as r
JOIN sales_reps as s ON s.region_id = r.id
JOIN accounts as a ON a.sales_rep_id = s.id
JOIN orders as o ON o.account_id = a.id
WHERE r.id =
    -- INNER SUBQUERY: returns the id of the region with the most sales
    (SELECT
        r.id
    FROM region as r
    JOIN sales_reps as s ON s.region_id = r.id
    JOIN accounts as a ON a.sales_rep_id = s.id
    JOIN orders as o ON o.account_id = a.id
    GROUP BY 1
    ORDER BY SUM(o.total_amt_usd) DESC
    LIMIT 1)
GROUP BY 1;



-- How many accounts had more total purchases than the account name which has bought the most
-- standard_qty paper throughout their lifetime as a customer?
-- outer query: returns the count of all accounts from t2
SELECT
    COUNT(*) as num_accounts
FROM
    -- inner query - t2: returns accounts whose # total orders is greater than results from t1
    (SELECT
        a.name,
        SUM(o.total) as total
    FROM accounts as a
    JOIN orders as o ON a.id = o.account_id
    GROUP BY 1
    HAVING SUM(o.total) >
        -- inner query - no identifier: return the value of overall total orders for the account from t1
        (SELECT total
        FROM
            -- inner query - t1:dfind the account with the top # of standard_qty. return id, and overall total
            (SELECT
                a.id,
                SUM(o.total) as total
            FROM accounts as a
            JOIN orders as o ON o.account_id = a.id
            GROUP BY 1
            ORDER BY SUM(standard_qty) DESC
            LIMIT 1) t1) ) t2;



-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
-- how many web_events did they have for each channel?
-- Outer query: return count of all events for each channel of the account returned by subquery
SELECT
    w.channel,
    COUNT(*) as num_events
FROM web_events as w
JOIN accounts as a ON w.account_id = a.id
WHERE w.account_id =
    -- subquery: return account id for customer that spent most
    (SELECT
        a.id
    FROM accounts as a
    JOIN orders as o ON a.id = o.account_id
    GROUP BY 1
    ORDER BY SUM(o.total_amt_usd) DESC
    LIMIT 1)
GROUP BY 1;



-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total
-- spending accounts?
-- outer query: return the average amount spent for accounts having names in the result of subquery
SELECT
    a.name as account,
    CAST(AVG(o.total_amt_usd) as MONEY) as lifetime_avg_spent
FROM accounts as a
JOIN orders as o ON o.account_id = a.id
GROUP BY 1
HAVING a.name IN
    -- subquery: return the names of the top spending accounts
    (SELECT
        a.name
    FROM accounts as a
    JOIN orders as o ON o.account_id = a.id
    GROUP BY 1
    ORDER BY SUM(o.total_amt_usd) DESC
    LIMIT 10)
ORDER BY 2 DESC;



-- What is the lifetime average amount spent in terms of total_amt_usd, including only the
-- companies that spent more per order, on average, than the average of all orders.
SELECT
    CAST(AVG(avg_amt) as MONEY) as lifetime_avg_spent
FROM
    -- subquery: return the names of all accounts and their avg_amt per order who on average
    -- spent more per order than the overall average
    (SELECT
        a.name,
        AVG(o.total_amt_usd) avg_amt
    FROM accounts as a
    JOIN orders as o ON o.account_id = a.id
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) >
        -- subquery: average usd per order of all orders
        (SELECT
            AVG(total_amt_usd)
        FROM orders)) t1;




--
-- DOING THE SAME 6 QUESTIONS AS ABOVE BUT USING CTE'S WITH THE 'WITH' EXPRESSION
--
--
--
-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
WITH t1 as
        (SELECT
                s.name as rep_name,
                r.name as region,
                SUM(o.total_amt_usd) as total
            FROM region as r
            JOIN sales_reps as s ON s.region_id = r.id
            JOIN accounts as a ON a.sales_rep_id = s.id
            JOIN orders as o ON o.account_id = a.id
            GROUP BY 1, 2),
    t2 as
        (SELECT
            region,
            MAX(total) as Total
        FROM t1
        GROUP BY 1),
    t3 as
        (SELECT
                s.name as rep_name,
                r.name as region,
                SUM(o.total_amt_usd) as total
            FROM region as r
            JOIN sales_reps as s ON s.region_id = r.id
            JOIN accounts as a ON a.sales_rep_id = s.id
            JOIN orders as o ON o.account_id = a.id
            GROUP BY 1, 2
            ORDER BY 3 DESC)

-- OUTER QUERY
SELECT
    t3.rep_name,
    t2.region,
    CAST(t3.total as MONEY)
FROM t2
JOIN t3
ON t3.region = t2.region AND t3.total = t2.total;



-- For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders
-- were placed?
-- INNER SUBQUERY: returns the id of the region with the most sales
WITH top_region as
        (SELECT
            r.id as id
        FROM region as r
        JOIN sales_reps as s ON s.region_id = r.id
        JOIN accounts as a ON a.sales_rep_id = s.id
        JOIN orders as o ON o.account_id = a.id
        GROUP BY 1
        ORDER BY SUM(o.total_amt_usd) DESC
        LIMIT 1)

-- OUTER QUERY: returns the count of all orders and region name where region id = result of
-- subquery(region with most sales)
SELECT
    r.name,
    COUNT(*) as order_count
FROM region as r
JOIN sales_reps as s ON s.region_id = r.id
JOIN accounts as a ON a.sales_rep_id = s.id
JOIN orders as o ON o.account_id = a.id
WHERE r.id = (SELECT id FROM top_region)

GROUP BY 1;



-- How many accounts had more total purchases than the account name which has bought the most
-- standard_qty paper throughout their lifetime as a customer?
-- inner query - t1: find the account with the top # of standard_qty. return id, and overall total
WITH top_standard_customer as
        (SELECT
            a.id,
            SUM(o.total) as total
        FROM accounts as a
        JOIN orders as o ON o.account_id = a.id
        GROUP BY 1
        ORDER BY SUM(standard_qty) DESC
        LIMIT 1),

    -- inner query - t2: returns accounts whose # total orders is greater than results from t1
     top_accounts as
        (SELECT
            a.name,
            SUM(o.total) as total
        FROM accounts as a
        JOIN orders as o ON a.id = o.account_id
        GROUP BY 1
        HAVING SUM(o.total) > (SELECT total FROM top_standard_customer))

-- outer query: returns the count of all accounts from t2
SELECT COUNT(*) as num_accounts FROM top_accounts;


-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
-- how many web_events did they have for each channel?
-- Outer query: return count of all events for each channel of the account returned by subquery
WITH spent_most as
                (SELECT
                    a.id as id
                FROM accounts as a
                JOIN orders as o ON a.id = o.account_id
                GROUP BY 1
                ORDER BY SUM(o.total_amt_usd) DESC
                LIMIT 1)
SELECT
    w.channel,
    COUNT(*) as num_events
FROM web_events as w
JOIN accounts as a ON w.account_id = a.id
WHERE w.account_id = (SELECT id FROM spent_most)
GROUP BY 1;


-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total
-- spending accounts?
    -- subquery: return the names of the top spending accounts
WITH top_accounts as
                (SELECT
                    a.name as name
                FROM accounts as a
                JOIN orders as o ON o.account_id = a.id
                GROUP BY 1
                ORDER BY SUM(o.total_amt_usd) DESC
                LIMIT 10)

-- outer query: return the average amount spent for accounts having names in the result of subquery
SELECT
    a.name as account,
    CAST(AVG(o.total_amt_usd) as MONEY) as lifetime_avg_spent
FROM accounts as a
JOIN orders as o ON o.account_id = a.id
GROUP BY 1
HAVING a.name IN (SELECT name FROM top_accounts)
ORDER BY 2 DESC;


-- What is the lifetime average amount spent in terms of total_amt_usd, including only the
-- companies that spent more per order, on average, than the average of all orders.

-- subquery: return the names of all accounts and their avg_amt per order who on average
-- spent more per order than the overall average
WITH avg_order_accounts as
                        (SELECT
                            a.name,
                            AVG(o.total_amt_usd) avg_amt
                        FROM accounts as a
                        JOIN orders as o ON o.account_id = a.id
                        GROUP BY 1
                        HAVING AVG(o.total_amt_usd) > (SELECT AVG(total_amt_usd) FROM orders))

SELECT
    CAST(AVG(avg_amt) as MONEY) as lifetime_avg_spent
FROM avg_order_accounts
