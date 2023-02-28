/*
SQL code for exercises of Udacity course
*/

/* Data Cleaning */

/* LEFT & RIGHT */

/*
1. In the accounts table, there is a column holding the website for each
company. The last three digits specify what type of web address they are
using. A list of extensions (and pricing) is provided here. Pull these
extensions and provide how many of each website type exist in the accounts
table.
*/

SELECT
  RIGHT(website, 3) extensions,
  COUNT(RIGHT(website, 3)) quantity
FROM accounts
GROUP BY 1;

/*
2. There is much debate about how much the name (or even the first letter of a
company name) matters. Use the accounts table to pull the first letter of each
company name to see the distribution of company names that begin with each
letter (or number).
*/

SELECT
  LEFT(name, 1) First_letter,
  COUNT(LEFT(name, 1)) quantity
FROM accounts
GROUP BY 1
ORDER BY 1;

/*
3. Use the accounts table and a CASE statement to create two groups: one group
of company names that start with a number and a second group of those company
names that start with a letter. What proportion of company names start with a
letter?
*/

WITH name_groups AS (
  SELECT
    name,
    CASE
      WHEN name ~ '[0-9].*' THEN 'starts with number'
      ELSE 'starts with letter'
    END groups
    FROM accounts
)

SELECT
  groups,
  COUNT(*)/SUM(COUNT(*)) OVER () proportion
FROM name_groups
GROUP BY 1;

/*
4. Consider vowels as a, e, i, o, and u. What proportion of company names start
with a vowel, and what percent start with anything else?
*/

WITH name_groups AS (
  SELECT
    name,
    CASE
      WHEN name ~ '^[aeiouAEIOU].*' THEN 'starts with vowel'
      ELSE 'starts with non-vowel'
    END groups
    FROM accounts
)

SELECT
  groups,
  COUNT(*)/SUM(COUNT(*)) OVER () proportion
FROM name_groups
GROUP BY 1;

/* POSITION & STRPOS */

/*
1. Use the accounts table to create first and last name columns that hold the
first and last names for the primary_poc.
*/

SELECT
  LEFT(primary_poc, POSITION(' ' IN primary_poc)) first_name,
  RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) last_name
FROM accounts;

/*
2. Now see if you can do the same thing for every rep name in the sales_reps
table. Again provide first and last name columns.
*/

SELECT
  LEFT(name, POSITION(' ' IN name)) first_name,
  RIGHT(name, LENGTH(name) - POSITION(' ' IN name)) last_name
FROM sales_reps;

/* CONCAT */

/*
1. Each company in the accounts table wants to create an email address for each
primary_poc. The email address should be the first name of the primary_poc .
last name primary_poc @ company name .com.
*/

SELECT
  primary_poc,
  LEFT(primary_poc, POSITION(' ' IN primary_poc)-1) ||
  RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) ||
  '@' ||
  name ||
  '.com' company_email
FROM accounts;

/*
2. You may have noticed that in the previous solution some of the company names
include spaces, which will certainly not work in an email address. See if you
can create an email address that will work by removing all of the spaces in the
account name, but otherwise your solution should be just as in question 1. Some
helpful documentation is here.
*/

SELECT
  primary_poc,
  LOWER(LEFT(primary_poc, POSITION(' ' IN primary_poc)-1)) ||
  LOWER(RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc))) ||
  '@' ||
  LOWER(REPLACE(name, ' ', '')) ||
  '.com' company_email
FROM accounts;

/*
3. We would also like to create an initial password, which they will change
after their first log in. The first password will be the first letter of the
primary_poc's first name (lowercase), then the last letter of their first name
(lowercase), the first letter of their last name (lowercase), the last letter
of their last name (lowercase), the number of letters in their first name, the
number of letters in their last name, and then the name of the company they are
working with, all capitalized with no spaces.
*/

SELECT
  primary_poc,
  LOWER(LEFT(primary_poc, POSITION(' ' IN primary_poc)-1)) ||
  LOWER(RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc))) ||
  '@' ||
  LOWER(REPLACE(name, ' ', '')) ||
  '.com' company_email,
  LOWER(LEFT(primary_poc, 1)) ||
  LOWER(SUBSTR(primary_poc, POSITION(' ' IN primary_poc)-1, 1)) ||
  LOWER(SUBSTR(primary_poc, POSITION(' ' IN primary_poc)+1, 1)) ||
  LOWER(SUBSTR(primary_poc, LENGTH(primary_poc))) ||
  POSITION(' ' IN primary_poc)-1 ||
  LENGTH(primary_poc) - POSITION(' ' IN primary_poc) ||
  UPPER(REPLACE(name, ' ', '')) AS password
FROM accounts;

/* CAST */

/*
1. Write a query to look at the top 10 rows to understand the columns and the
raw data in the dataset called sf_crime_data.
*/

SELECT *
FROM sf_crime_data
LIMIT 10;

/*
4. Write a query to change the date into the correct SQL date format. You will
need to use at least SUBSTR and CONCAT to perform this operation.
*/

WITH
  dates AS (
    SELECT *,
      SUBSTR(date, 1, 2) mm,
      SUBSTR(date, 4, 2) dd,
      SUBSTR(date, 7, 4) yy
    FROM sf_crime_data
)

SELECT *,
  (yy || '-' || mm || '-' || dd) date_format
FROM dates
LIMIT 10;

/*
5. Once you have created a column in the correct format, use either CAST or ::
to convert this to a date.
*/

WITH
  dates AS (
    SELECT *,
      SUBSTR(date, 1, 2) mm,
      SUBSTR(date, 4, 2) dd,
      SUBSTR(date, 7, 4) yy
    FROM sf_crime_data
)

SELECT *,
  (yy || '-' || mm || '-' || dd)::date date_format
FROM dates
LIMIT 10;

/* COALESCE */

/*
2. Use COALESCE to fill in the accounts.id column with the account.id for the
NULL value for the table in 1.
*/

SELECT
	COALESCE(o.id, a.id) filled_id,
  *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*
3. Use COALESCE to fill in the orders.account_id column with the account.id for
the NULL value for the table in 1.
*/

SELECT
	COALESCE(o.id, a.id) filled_id,
  COALESCE(o.account_id, a.id) account_id_filled,
  *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*
4. Use COALESCE to fill in each of the qty and usd columns with 0 for the table
in 1
*/

SELECT
  a.name,
  a.website,
  a.primary_poc,
  COALESCE(o.standard_qty, 0) standard_qty_filled,
  COALESCE(o.gloss_qty, 0) gloss_qty_filled,
  COALESCE(o.poster_qty, 0) poster_qty_filled,
  COALESCE(o.total, 0) total_filled,
  COALESCE(o.standard_amt_usd, 0) standard_amt_usd_filled,
  COALESCE(o.gloss_amt_usd, 0) gloss_amt_usd_filled,
  COALESCE(o.poster_amt_usd, 0) poster_amt_usd_filled,
  COALESCE(o.total_amt_usd, 0) total_amt_usd_filled
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*
5. Run the query in 1 with the WHERE removed and COUNT the number of ids
*/

SELECT COUNT(a.id) number_of_ids
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;

/*
6. Run the query in 5, but with the COALESCE function used in questions 2
through 4
*/

WITH filled AS (
  SELECT
  	COALESCE(o.id, a.id) filled_id,
    *
  FROM accounts a
  LEFT JOIN orders o
  ON a.id = o.account_id
)

SELECT COUNT(f.filled_id) number_of_ids
FROM filled f;

WITH filled AS (
  SELECT
  	COALESCE(o.id, a.id) filled_id,
    COALESCE(o.account_id, a.id) account_id_filled,
    *
  FROM accounts a
  LEFT JOIN orders o
  ON a.id = o.account_id
)

SELECT COUNT(f.filled_id) number_of_ids
FROM filled f;

WITH filled AS (
  SELECT
    a.name,
    a.website,
    a.primary_poc,
    COALESCE(o.standard_qty, 0) standard_qty_filled,
    COALESCE(o.gloss_qty, 0) gloss_qty_filled,
    COALESCE(o.poster_qty, 0) poster_qty_filled,
    COALESCE(o.total, 0) total_filled,
    COALESCE(o.standard_amt_usd, 0) standard_amt_usd_filled,
    COALESCE(o.gloss_amt_usd, 0) gloss_amt_usd_filled,
    COALESCE(o.poster_amt_usd, 0) poster_amt_usd_filled,
    COALESCE(o.total_amt_usd, 0) total_amt_usd_filled
  FROM accounts a
  LEFT JOIN orders o
  ON a.id = o.account_id
)

SELECT COUNT(f.name)
FROM filled f;
