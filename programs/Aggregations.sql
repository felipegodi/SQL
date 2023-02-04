/*
SQL code for exercises of Udacity course
*/

/*
AGGREGATIONS
*/

/*
1. Find the total amount of poster_qty paper ordered in the orders table.
*/

SELECT
  SUM(o.poster_qty) poster_qty
FROM orders o;

/*
2. Find the total amount of standard_qty paper ordered in the orders table.
*/

SELECT
  SUM(o.standard_qty) standard_qty
FROM orders o;

/*
3. Find the total dollar amount of sales using the total_amt_usd in the orders
table.
*/

SELECT
  SUM(o.total_amt_usd) total_amt_usd
FROM orders o;

/*
4. Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for
each order in the orders table. This should give a dollar amount for each order
in the table.
*/

SELECT
  o.standard_amt_usd + o.gloss_amt_usd total_standard_gloss
FROM orders o;

/*
5. Find the standard_amt_usd per unit of standard_qty paper. Your solution
should use both an aggregation and a mathematical operator.
*/

SELECT
  SUM(o.standard_amt_usd)/SUM(o.standard_qty) standard_price_per_unit
FROM orders o;

/*
1. When was the earliest order ever placed? You only need to return the date.
*/

SELECT
  MIN(o.occurred_at) earliest_order
FROM orders o;

/*
2. Try performing the same query as in question 1 without using an aggregation
function.
*/

SELECT
  o.occurred_at earliest_order
FROM orders o
ORDER BY o.occurred_at
LIMIT 1;

/*
3. When did the most recent (latest) web_event occur?
*/

SELECT
  MAX(w.occurred_at) latest_web_order
FROM web_events w;

/*
4. Try to perform the result of the previous query without using an aggregation
function.
*/

SELECT
  w.occurred_at latest_web_order
FROM web_events w
ORDER BY w.occurred_at DESC
LIMIT 1;

/*
5. Find the mean (AVERAGE) amount spent per order on each paper type, as well as
the mean amount of each paper type purchased per order. Your final answer should
have 6 values - one for each paper type for the average number of sales, as well
as the average amount.
*/

SELECT
  AVG(o.standard_amt_usd) standard_avg_spent_per_order,
  AVG(o.gloss_amt_usd) gloss_avg_spent_per_order,
  AVG(o.poster_amt_usd) poster_avg_spent_per_order,
  AVG(o.standard_qty) standard_avg_qty_per_order,
  AVG(o.gloss_qty) gloss_avg_qty_per_order,
  AVG(o.poster_qty) poster_avg_qty_per_order
FROM orders o;

/*
6. Via the video, you might be interested in how to calculate the MEDIAN. Though
this is more advanced than what we have covered so far try finding - what is the
MEDIAN total_usd spent on all orders?
*/

SELECT
  AVG(total_amt_usd)
FROM (
  SELECT ROW_NUMBER() OVER(ORDER BY total_amt_usd), *
  FROM orders
) o
WHERE o.row_number = 3457 OR o.row_number = 3456;

/*
1. Which account (by name) placed the earliest order? Your solution should have
the account name and the date of the order.
*/

SELECT
  a.name,
  o.occurred_at
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
ORDER BY o.occurred_at
LIMIT 1;

/*
2. Find the total sales in usd for each account. You should include two columns
- the total sales for each company's orders in usd and the company name.
*/

SELECT
  a.name,
  SUM(o.total_amt_usd) total_sales
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
GROUP BY a.name
ORDER BY a.name;

/*
3. Via what channel did the most recent (latest) web_event occur, which account
was associated with this web_event? Your query should return only three values
- the date, channel, and account name.
*/

SELECT
  a.name,
  w.occurred_at,
  w.channel
FROM accounts a
JOIN web_events w
  ON w.account_id = a.id
ORDER BY w.occurred_at DESC
LIMIT 1;

/*
4. Find the total number of times each type of channel from the web_events was
used. Your final table should have two columns - the channel and the number of
times the channel was used.
*/

SELECT
  w.channel,
  COUNT(*)
FROM web_events w
GROUP BY w.channel;

/*
5. Who was the primary contact associated with the earliest web_event?
*/

SELECT
  a.primary_poc,
  w.occurred_at
FROM accounts a
JOIN web_events w
  ON w.account_id = a.id
ORDER BY w.occurred_at
LIMIT 1;

/*
6. What was the smallest order placed by each account in terms of total usd.
Provide only two columns - the account name and the total usd. Order from
smallest dollar amounts to largest.
*/

SELECT
  a.name,
  MIN(o.total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
GROUP BY a.name
ORDER BY MIN(o.total_amt_usd);

/*
7. Find the number of sales reps in each region. Your final table should have
two columns - the region and the number of sales_reps. Order from fewest reps
to most reps.
*/

SELECT
  COUNT(*) sales_reps,
  r.name region
FROM sales_reps s
JOIN region r
  ON s.region_id = r.id
GROUP BY r.name
ORDER BY COUNT(s.name);

/*
1. For each account, determine the average amount of each type of paper they
purchased across their orders. Your result should have four columns - one for
the account name and one for the average quantity purchased for each of the
paper types for each account.
*/

SELECT
  a.name,
  AVG(o.standard_qty) standard_avg,
  AVG(o.gloss_qty) gloss_avg,
  AVG(o.poster_qty) poster_avg
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
GROUP BY a.name
ORDER BY a.name;

/*
2. For each account, determine the average amount spent per order on each paper
type. Your result should have four columns - one for the account name and one
for the average amount spent on each paper type.
*/

SELECT
  a.name,
  AVG(o.standard_amt_usd) standard_avg_spent,
  AVG(o.gloss_amt_usd) gloss_avg_spent,
  AVG(o.poster_amt_usd) poster_avg_spent
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
GROUP BY a.name
ORDER BY a.name;

/*
3. Determine the number of times a particular channel was used in the
web_events table for each sales rep. Your final table should have three columns
- the name of the sales rep, the channel, and the number of occurrences. Order
your table with the highest number of occurrences first.
*/

SELECT
  s.name,
  w.channel,
  COUNT(w.channel) times_channel_used
FROM sales_reps s
JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN web_events w
  ON a.id = w.account_id
GROUP BY s.name, w.channel
ORDER BY times_channel_used DESC;

/*
4. Determine the number of times a particular channel was used in the web_events
table for each region. Your final table should have three columns - the region
name, the channel, and the number of occurrences. Order your table with the
highest number of occurrences first.
*/

SELECT
  r.name,
  w.channel,
  COUNT(w.channel) times_channel_used
FROM sales_reps s
JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN web_events w
  ON a.id = w.account_id
JOIN region r
  ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY times_channel_used DESC;

/*
DISTINCT
*/

/*
1. Use DISTINCT to test if there are any accounts associated with more than
one region.
*/

SELECT DISTINCT
  a.name account,
  r.name region
FROM accounts a
JOIN sales_reps s
  ON s.id = a.sales_rep_id
JOIN region r
  ON r.id = s.region_id
ORDER BY a.name;

/*
2. Have any sales reps worked on more than one account?
*/

SELECT
  s.name,
  COUNT(a.sales_rep_id) num_of_accounts
FROM accounts a
JOIN sales_reps s
  ON a.sales_rep_id = s.id
GROUP BY s.name
HAVING COUNT(a.sales_rep_id) > 1
ORDER BY num_of_accounts DESC;


/*
1. How many of the sales reps have more than 5 accounts that they manage?
*/

SELECT COUNT(*)
FROM (
  SELECT s.name, COUNT(a.sales_rep_id) num_of_accounts
  FROM accounts a
  JOIN sales_reps s
    ON a.sales_rep_id = s.id
  GROUP BY s.name
  ORDER BY num_of_accounts DESC
) t
WHERE num_of_accounts > 5;

/*
2. How many accounts have more than 20 orders?
*/

SELECT COUNT(*)
FROM (
  SELECT a.name, COUNT(*)
  FROM orders o
  JOIN accounts a
    ON a.id = o.account_id
  GROUP BY a.name
  HAVING COUNT(*) > 20
) t;

/*
3. Which account has the most orders?
*/

SELECT
  a.name,
  COUNT(*) num_of_orders
FROM orders o
JOIN accounts a
  ON a.id = o.account_id
GROUP BY a.name
HAVING COUNT(*) > 20
ORDER BY num_of_orders DESC
LIMIT 1;

/*
4. Which accounts spent more than 30,000 usd total across all orders?
*/

SELECT
  a.name,
  SUM(total_amt_usd) total_spent
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
GROUP BY a.name
HAVING SUM(total_amt_usd) > 30000;

/*
5. Which accounts spent less than 1,000 usd total across all orders?
*/

SELECT
  a.name,
  SUM(total_amt_usd) total_spent
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
GROUP BY a.name
HAVING SUM(total_amt_usd) < 1000;

/*
6. Which account has spent the most with us?
*/

SELECT
  a.name,
  SUM(total_amt_usd) total_spent
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_spent DESC
LIMIT 1;

/*
7. Which account has spent the least with us?
*/

SELECT
  a.name,
  SUM(total_amt_usd) total_spent
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_spent
LIMIT 1;

/*
8. Which accounts used facebook as a channel to contact customers more than
6 times?
*/

SELECT a.name
FROM accounts a
JOIN web_events w
  ON w.account_id = a.id
WHERE w.channel = 'facebook'
GROUP BY a.name
HAVING COUNT(w.channel) > 6;

/*
9. Which account used facebook most as a channel?
*/

SELECT
  a.name,
  COUNT(w.channel) used_facebook
FROM accounts a
JOIN web_events w
  ON w.account_id = a.id
WHERE w.channel = 'facebook'
GROUP BY a.name
HAVING COUNT(w.channel) > 6
ORDER BY used_facebook DESC
LIMIT 1;

/*
10. Which channel was most frequently used by most accounts?
*/

SELECT
  a.name,
  w.channel,
  COUNT(*) times_used_channel
FROM accounts a
JOIN web_events w
  ON w.account_id = a.id
GROUP BY a.name, w.channel
ORDER BY times_used_channel DESC, a.name;

/*
Working with Dates
*/

/*
1. Find the sales in terms of total dollars for all orders in each year,
ordered from greatest to least. Do you notice any trends in the yearly
sales totals?
*/

SELECT
  DATE_PART('year',occurred_at) yr,
  SUM(total_amt_usd) total_amount
FROM orders
GROUP BY DATE_PART('year',occurred_at)
ORDER BY total_amount DESC;


/*
2. Which month did Parch & Posey have the greatest sales in terms of total
dollars? Are all months evenly represented by the dataset?
*/

SELECT
  DATE_TRUNC('month',occurred_at) mon,
  SUM(total_amt_usd) total_amount
FROM orders o
GROUP BY DATE_TRUNC('month',occurred_at)
ORDER BY total_amount DESC
LIMIT 1;

/*
3. Which year did Parch & Posey have the greatest sales in terms of total
number of orders? Are all years evenly represented by the dataset?
*/

SELECT
  DATE_PART('year',occurred_at) yr,
  SUM(total) total_qty
FROM orders o
GROUP BY DATE_PART('year',occurred_at)
ORDER BY total_qty
LIMIT 1;


/*
4. Which month did Parch & Posey have the greatest sales in terms of total
number of orders? Are all months evenly represented by the dataset?
*/

SELECT
  DATE_TRUNC('month',occurred_at) mon,
  SUM(total) total_qty
FROM orders
GROUP BY DATE_TRUNC('month',occurred_at)
ORDER BY total_qty DESC
LIMIT 1;

/*
5. In which month of which year did Walmart spend the most on gloss paper in
terms of dollars?
*/

SELECT
  DATE_TRUNC('month',o.occurred_at) mon,
  SUM(o.gloss_amt_usd) gloss_spent, a.name
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY DATE_TRUNC('month',o.occurred_at), a.name
ORDER BY gloss_spent DESC
LIMIT 1;

/*
CASE
*/

/*
1. Write a query to display for each order, the account ID, total amount of
the order, and the level of the order - ‘Large’ or ’Small’ - depending on if
the order is $3000 or more, or smaller than $3000.
*/

SELECT
  o.account_id,
  o.total_amt_usd,
  CASE
    WHEN o.total_amt_usd < 3000 THEN 'Small'
    WHEN o.total_amt_usd >= 3000 THEN 'Large'
    ELSE 'NA'
  END level_of_order
FROM orders o;

/*
2. Write a query to display the number of orders in each of three categories,
based on the total number of items in each order. The three categories are:
'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
*/

SELECT
  o.account_id,
  o.total_amt_usd,
  CASE
    WHEN o.total_amt_usd >= 2000 THEN 'At least 2000'
    WHEN o.total_amt_usd < 2000 AND o.total_amt_usd > 1000 THEN 'Between 1000 and 2000'
    WHEN o.total_amt_usd < 1000 THEN 'Less than 1000'
    ELSE 'NA'
  END number_of_orders
FROM orders o;

/*
3. We would like to understand 3 different levels of customers based on the
amount associated with their purchases. The top level includes anyone with a
Lifetime Value (total sales of all orders) greater than 200,000 usd. The second
level is between 200,000 and 100,000 usd. The lowest level is anyone under
100,000 usd. Provide a table that includes the level associated with each
account. You should provide the account name, the total sales of all orders
for the customer, and the level. Order with the top spending customers listed
first.
*/

SELECT
  a.name,
  SUM(o.total_amt_usd) total_sales,
  CASE
    WHEN SUM(o.total_amt_usd) > 200000 THEN 'greater than 200,000'
    WHEN SUM(o.total_amt_usd) <= 200000 AND SUM(o.total_amt_usd) >= 100000 THEN '200,000 and 100,000'
    WHEN SUM(o.total_amt_usd) < 100000 THEN 'under 100,000'
    ELSE 'NA'
  END total_sales_level
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_sales DESC;

/*
4. We would now like to perform a similar calculation to the first, but we want
to obtain the total amount spent by customers only in 2016 and 2017. Keep the
same levels as in the previous question. Order with the top spending customers
listed first.
*/

SELECT
  a.name,
  SUM(o.total_amt_usd) total_sales,
  CASE
    WHEN SUM(o.total_amt_usd) > 200000 THEN 'greater than 200,000'
    WHEN SUM(o.total_amt_usd) <= 200000 AND SUM(o.total_amt_usd) >= 100000 THEN '200,000 and 100,000'
    WHEN SUM(o.total_amt_usd) < 100000 THEN 'under 100,000'
    ELSE 'NA'
  END total_sales_level
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
  AND o.occurred_at >= '2015-01-01'
  AND o.occurred_at < '2017-01-01'
GROUP BY a.name
ORDER BY total_sales DESC;

/*
5. We would like to identify top performing sales reps, which are sales reps
associated with more than 200 orders. Create a table with the sales rep name,
the total number of orders, and a column with top or not depending on if they
have more than 200 orders. Place the top sales people first in your final table.
*/

SELECT
  s.name,
  COUNT(o.*) total_orders_per_rep,
  CASE
    WHEN COUNT(o.*) > 200 THEN 'top'
    ELSE 'not'
  END top
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
JOIN sales_reps s
  ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY total_orders_per_rep DESC;

/*
6.The previous didn't account for the middle, nor the dollar amount associated
with the sales. Management decides they want to see these characteristics
represented as well. We would like to identify top performing sales reps,
which are sales reps associated with more than 200 orders or more than 750000
in total sales. The middle group has any rep with more than 150 orders or
500000 in sales. Create a table with the sales rep name, the total number of
orders, total sales across all orders, and a column with top, middle, or low
depending on this criteria. Place the top sales people based on dollar amount
of sales first in your final table. You might see a few upset sales people by
this criteria!
*/

SELECT
  s.name,
  COUNT(o.*) total_orders_per_rep,
  SUM(o.total_amt_usd) total_sales_per_rep,
  CASE
    WHEN COUNT(o.*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
    WHEN COUNT(o.*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
    ELSE 'low'
  END category
FROM accounts a
JOIN orders o
  ON o.account_id = a.id
JOIN sales_reps s
  ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY total_sales_per_rep DESC;
