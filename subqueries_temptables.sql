-- We want to find the average number of events for each day for each channel. The first table
-- will provide us the number of events for each day and channel, and then we will need to
-- average these values together using a second query.
SELECT
    channel,
    CAST(AVG(num_events) AS DECIMAL(10,2)) AS avg_num_events
FROM
    (SELECT
        DATE_TRUNC('day', occurred_at) AS day,
        channel,
        COUNT(*) AS num_events
    FROM web_events
    GROUP BY 1,2) events_per_day
GROUP BY channel
ORDER BY 2 DESC;

--  sub query on the where clause. logical compariason available because subquery returns one value
-- it returns the month of the first order. Then we can find the average of all paper qty's
-- where the month is equal to the subquery (first month)
SELECT
    DATE_TRUNC('month', occurred_at) AS first_month,
    CAST(AVG(standard_qty) AS DECIMAL(10,2)) AS standard_avg,
    CAST(AVG(gloss_qty) AS DECIMAL(10,2)) AS gloss_avg,
    CAST(AVG(poster_qty) AS DECIMAL(10,2)) AS poster_avg
FROM orders
WHERE
    DATE_TRUNC('month', occurred_at) =
    (SELECT
        DATE_TRUNC('month', MIN(occurred_at))
    FROM orders)
GROUP BY 1
