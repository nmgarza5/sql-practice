-- In the accounts table, there is a column holding the website for each company. The last three
-- digits specify what type of web address they are using. A list of extensions (and pricing) is
-- provided here. Pull these extensions and provide how many of each website type exist in the
-- accounts table.
SELECT
    RIGHT(website, 4) as extensions,
    COUNT(*) as count
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;



-- There is much debate about how much the name (or even the first letter of a company name) matters.
-- Use the accounts table to pull the first letter of each company name to see the distribution of
-- company names that begin with each letter (or number).
SELECT
    LEFT(UPPER(name), 1) as first_character,
    COUNT(*) as count
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- Use the accounts table and a CASE statement to create two groups: one group of company names
-- that start with a number and a second group of those company names that start with a letter.
-- What proportion of company names start with a letter?
WITH type_counts as
                (SELECT
                    CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 'Number'
                    ELSE 'Letter' END AS type,
                    COUNT(*) as count
                FROM accounts
                GROUP BY 1)
SELECT CONCAT(
    LEFT(
        CAST((MAX(count) / SUM(count) * 100) as varchar),
        5),
    '%')
     proportion FROM type_counts;

-- Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and
-- what percent start with anything else?
WITH vowel_counts as
                (SELECT
                    CASE WHEN LEFT(LOWER(name), 1) IN ('a', 'e', 'i', 'o', 'u') THEN 'vowel'
                    ELSE 'not_vowel' END AS type,
                    COUNT(*) as count
                FROM accounts
                GROUP BY 1)
SELECT
    type,
    CONCAT(LEFT(CAST((count / (SELECT SUM(count) FROM vowel_counts) * 100) as varchar),5), '%') as proportion
FROM vowel_counts
GROUP BY 1, count
