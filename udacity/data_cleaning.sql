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
GROUP BY 1, count;




-- Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.


 SELECT
    LEFT(primary_poc, POSITION(' ' in primary_poc)-1) as first_name,
    RIGHT(primary_poc, (LENGTH(primary_poc) - POSITION(' ' in primary_poc))) as last_name
FROM accounts;

-- Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last
-- name columns.
 SELECT
    LEFT(name, POSITION(' ' in name)-1) as first_name,
    RIGHT(name, (LENGTH(name) - POSITION(' ' in name))) as last_name
FROM sales_reps;



-- Each company in the accounts table wants to create an email address for each primary_poc. The email address should be
-- the first name of the primary_poc . last name primary_poc @ company name .com.
WITH email_components as
                        (SELECT
                            name as company_name,
                            primary_poc,
                            LEFT(primary_poc, POSITION(' ' in primary_poc)-1) as first_name,
                            RIGHT(primary_poc, (LENGTH(primary_poc) - POSITION(' ' in primary_poc))) as last_name,
                            REPLACE(name, ' ', '') as name
                        FROM accounts
                            )
SELECT
    company_name,
    primary_poc,
    CONCAT(first_name, '.', last_name, '@', name, '.com') as email_address
FROM email_components;


-- You may have noticed that in the previous solution some of the company names include spaces, which will certainly not
-- work in an email address. See if you can create an email address that will work by removing all of the spaces in the
-- account name, but otherwise your solution should be just as in question 1. Some helpful documentation is here.


-- We would also like to create an initial password, which they will change after their first log in. The first password
-- will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name
-- (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the
-- number of letters in their first name, the number of letters in their last name, and then the name of the company
-- they are working with, all capitalized with no spaces.
WITH password_components as
        (SELECT
            primary_poc,
            LEFT(LOWER(primary_poc), 1) as first_first,
            RIGHT(LEFT(LOWER(primary_poc), POSITION(' ' in primary_poc)-1), 1) as first_last,
            LEFT(RIGHT(LOWER(primary_poc), (LENGTH(primary_poc) - POSITION(' ' in primary_poc))), 1) as last_first,
            RIGHT(RIGHT(LOWER(primary_poc), (LENGTH(primary_poc) - POSITION(' ' in primary_poc))), 1) as last_last,
            LENGTH(LEFT(primary_poc, POSITION(' ' in primary_poc)-1)) as first_name_length,
            LENGTH(RIGHT(primary_poc, (LENGTH(primary_poc) - POSITION(' ' in primary_poc)))) as last_name_length,
            REPLACE(UPPER(name), ' ', '') as company_name
        FROM accounts)

SELECT
    company_name,
    primary_poc,
    CONCAT(first_first, first_last, last_first, last_last, first_name_length,
            last_name_length, company_name) as password
FROM password_components;
