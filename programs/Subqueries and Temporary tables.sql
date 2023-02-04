/*
SQL code for exercises of Udacity course
*/

/* SQL Subqueries & Temporary Tables */

/*
On which day-channel pair did the most events occur. (Mark all that are true)
*/

SELECT
  DATE_TRUNC('day',w.occurred_at) date_day,
  w.channel,
  COUNT(w.*) num_of_events
FROM web_events w
GROUP BY DATE_TRUNC('day',w.occurred_at), w.channel
ORDER BY num_of_events DESC;

/*
Match each channel to its corresponding average number of events per day.
*/

SELECT
  channel
  AVG(num_of_events) mean_events
FROM (
  SELECT
    DATE_TRUNC('day',w.occurred_at) date_day,
    w.channel,
    COUNT(w.*) num_of_events
  FROM web_events w
  GROUP BY DATE_TRUNC('day',w.occurred_at), w.channel
  ORDER BY num_of_events DESC
) sub
GROUP BY channel
ORDER BY mean_events DESC;

/*
What was the month/year combo for the first order placed?
*/

SELECT
  MIN(DATE_TRUNC('month',occurred_at))
FROM orders;

/*
Match each value to the corresponding description.
*/

/*
The average amount of standard paper sold on the first month that any order was
placed in the orders table (in terms of quantity).
*/

SELECT
  AVG(standard_qty) standard_sold
  AVG(gloss_qty) gloss_sold
  AVG(poster_qty) poster_sold
  SUM(total_amt_usd) total_spent
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
  (
    SELECT
      MIN(DATE_TRUNC('month',occurred_at))
    FROM orders
  );

/*
The average amount of gloss paper sold on the first month that any order was
placed in the orders table (in terms of quantity).
*/

SELECT
  AVG(standard_qty) standard_sold,
  AVG(gloss_qty) gloss_sold,
  AVG(poster_qty) poster_sold,
  SUM(total_amt_usd) total_spent
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
  (
    SELECT
      MIN(DATE_TRUNC('month',occurred_at))
    FROM orders
  );

/*
The average amount of poster paper sold on the first month that any order was
placed in the orders table (in terms of quantity).
*/

SELECT
  AVG(standard_qty) standard_sold,
  AVG(gloss_qty) gloss_sold,
  AVG(poster_qty) poster_sold,
  SUM(total_amt_usd) total_spent
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
  (
    SELECT
      MIN(DATE_TRUNC('month',occurred_at))
    FROM orders
  );

/*
The total amount spent on all orders on the first month that any order was
placed in the orders table (in terms of usd).
*/

SELECT
  AVG(standard_qty) standard_sold,
  AVG(gloss_qty) gloss_sold,
  AVG(poster_qty) poster_sold,
  SUM(total_amt_usd) total_spent
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
  (
    SELECT
      MIN(DATE_TRUNC('month',occurred_at))
    FROM orders
  );

/*
1. Provide the name of the sales_rep in each region with the largest amount of
total_amt_usd sales.
*/

SELECT
  sub3.sales_rep,
  sub3.region,
  sub3.total_amt_sales
FROM (
  SELECT
    region,
    MAX(total_amt_sales) max_amt_sales
  FROM (
    SELECT
      r.name region,
      s.name sales_rep,
      SUM(o.total_amt_usd) total_amt_sales
    FROM accounts a
    JOIN sales_reps s
      ON s.id = a.sales_rep_id
    JOIN region r
      ON r.id = s.region_id
    JOIN orders o
      ON o.account_id = a.id
    GROUP BY 1, 2
  ) sub
  GROUP BY 1
) sub2
JOIN (
  SELECT
    r.name region,
    s.name sales_rep,
    SUM(o.total_amt_usd) total_amt_sales
  FROM accounts a
  JOIN sales_reps s
    ON s.id = a.sales_rep_id
  JOIN region r
    ON r.id = s.region_id
  JOIN orders o
    ON o.account_id = a.id
  GROUP BY 1, 2
) sub3
  ON
    sub3.region = sub2.region
    AND sub2.max_amt_sales = sub3.total_amt_sales
ORDER BY 3 DESC;

/*
2. For the region with the largest (sum) of sales total_amt_usd, how many total
(count) orders were placed?
*/

SELECT
  r2.name,
  COUNT(o2.id) total_orders
FROM orders o2
JOIN accounts a2
  ON a2.id = o2.account_id
JOIN sales_reps s2
  ON s2.id = a2.sales_rep_id
JOIN region r2
  ON r2.id = s2.region_id
WHERE r2.name = (
  SELECT
    r.name
  FROM orders o
  JOIN accounts a
    ON a.id = o.account_id
  JOIN sales_reps s
    ON s.id = a.sales_rep_id
  JOIN region r
    ON r.id = s.region_id
  GROUP BY r.name
  ORDER BY SUM(o.total_amt_usd) DESC
  LIMIT 1
)
GROUP BY r2.name;

/*
3. How many accounts had more total purchases than the account name which has
bought the most standard_qty paper throughout their lifetime as a customer?
*/

SELECT
  COUNT(*)
FROM (
  SELECT
    a2.name
  FROM accounts a2
  JOIN orders o2
    ON o2.account_id = a2.id
  GROUP BY a2.name
  HAVING SUM(o2.total) > (
    SELECT
      SUM(o.total) total_purchases_most
    FROM accounts a
    JOIN orders o
      ON o.account_id = a.id
    GROUP BY a.name
    ORDER BY SUM(standard_qty) DESC
    LIMIT 1 )
) sub;

/*
4. For the customer that spent the most (in total over their lifetime as a
customer) total_amt_usd, how many web_events did they have for each channel?
*/

SELECT
  w.channel,
  COUNT(w.*)
FROM web_events w
JOIN accounts a2
  ON a2.id = w.account_id
JOIN (
  SELECT
    a.name most_spent_customer
  FROM accounts a
  JOIN orders o
    ON o.account_id = a.id
  GROUP BY a.name
  ORDER BY SUM(total_amt_usd) DESC
  LIMIT 1
) sub
  ON sub.most_spent_customer = a2.name
GROUP BY 1
ORDER BY 2 DESC;

/*
5. What is the lifetime average amount spent in terms of total_amt_usd for the
top 10 total spending accounts?
*/

SELECT
  AVG(sub.total_spent)
FROM (
  SELECT
    SUM(total_amt_usd) total_spent
  FROM orders o
  GROUP BY o.account_id
  ORDER BY total_spent DESC
  LIMIT 10
) sub;

/*
6. What is the lifetime average amount spent in terms of total_amt_usd,
including only the companies that spent more per order, on average, than the
average of all orders.
*/

SELECT
  AVG(lifetime_average_spent) average
FROM (
  SELECT
    a.name,
    AVG(o.total_amt_usd) lifetime_average_spent
  FROM orders o
  JOIN accounts a
    ON a.id = o.account_id
  GROUP BY 1
  HAVING AVG(o.total_amt_usd) > (
    SELECT
      AVG(total_amt_usd)
    FROM orders
  )
  ORDER BY 2 DESC
) sub;

/*
You need to find the average number of events for each channel per day.
*/
WITH events AS (
  SELECT
    DATE_TRUNC('day',w.occurred_at) date_day,
    w.channel,
    COUNT(w.*) events_per_day
  FROM web_events w
  GROUP BY 1, 2
  ORDER BY 1 DESC
)

SELECT
  channel,
  AVG(events_per_day) mean_events
FROM events
GROUP BY 1
ORDER BY 2 DESC;

/*
WITH
*/

/*
1. Provide the name of the sales_rep in each region with the largest amount of
total_amt_usd sales.
*/

WITH
  region_reps_max AS (
    SELECT
      r.name region,
      s.name sales_rep,
      SUM(o.total_amt_usd) total_amt_sales
    FROM accounts a
    JOIN sales_reps s
      ON s.id = a.sales_rep_id
    JOIN region r
      ON r.id = s.region_id
    JOIN orders o
      ON o.account_id = a.id
    GROUP BY 1, 2
  ),

  region_max AS (
    SELECT
      region,
      MAX(total_amt_sales) max_amt_sales
    FROM region_reps_max
      GROUP BY 1
  )

SELECT
  rrm.sales_rep,
  rrm.region,
  rrm.total_amt_sales
FROM region_max rm
JOIN region_reps_max rrm
  ON
    rrm.region = rm.region
    AND rm.max_amt_sales = rrm.total_amt_sales
ORDER BY 3 DESC;

/*
2. For the region with the largest sales total_amt_usd, how many total orders
were placed?
*/

WITH region_largest_sales AS (
  SELECT
    r.name
  FROM orders o
  JOIN accounts a
    ON a.id = o.account_id
  JOIN sales_reps s
    ON s.id = a.sales_rep_id
  JOIN region r
    ON r.id = s.region_id
  GROUP BY r.name
  ORDER BY SUM(o.total_amt_usd) DESC
  LIMIT 1
)

SELECT
  r2.name,
  COUNT(o2.id) total_orders
FROM orders o2
JOIN accounts a2
  ON a2.id = o2.account_id
JOIN sales_reps s2
  ON s2.id = a2.sales_rep_id
JOIN region r2
  ON r2.id = s2.region_id
JOIN region_largest_sales rls
  ON rls.name = r2.name
GROUP BY r2.name;

/*
3. How many accounts had more total purchases than the account name which has
bought the most standard_qty paper throughout their lifetime as a customer?
*/

WITH
  total_usd_most AS (
    SELECT
      SUM(o.total) total_purchases_most
    FROM accounts a
    JOIN orders o
      ON o.account_id = a.id
    GROUP BY a.name
    ORDER BY SUM(o.standar_qty) DESC
    LIMIT 1
  ),

  accounts_and_sums AS (
    SELECT
      a2.name,
      SUM(o2.total) total_purchases
    FROM accounts a2
    JOIN orders o2
      ON o2.account_id = a2.id
    GROUP BY a2.name
  )

SELECT
  COUNT(*)
FROM accounts_and_sums a
JOIN total_usd_most t
  ON a.total_purchases > t.total_purchases_most;

/*
4. For the customer that spent the most (in total over their lifetime as a
customer) total_amt_usd, how many web_events did they have for each channel?
*/

WITH most_spent_customer AS (
  SELECT
    a.name most_spent_customer
  FROM accounts a
  JOIN orders o
    ON o.account_id = a.id
  GROUP BY a.name
  ORDER BY SUM(total_amt_usd) DESC
  LIMIT 1
)

SELECT
  w.channel,
  COUNT(w.*)
FROM web_events w
JOIN accounts a2
  ON a2.id = w.account_id
JOIN most_spent_customer m
  ON m.most_spent_customer = a2.name
GROUP BY 1
ORDER BY 2 DESC;

/*
5. What is the lifetime average amount spent in terms of total_amt_usd for the
top 10 total spending accounts?
*/

WITH top_10_total_spent AS (
  SELECT
    SUM(total_amt_usd) total_spent
  FROM orders o
  GROUP BY o.account_id
  ORDER BY total_spent DESC
  LIMIT 10
)

SELECT
  AVG(total_spent)
FROM top_10_total_spent;

/*
6. What is the lifetime average amount spent in terms of total_amt_usd,
including only the companies that spent more per order, on average, than the
average of all orders.
*/

WITH
  average_spent AS (
  SELECT
    AVG(total_amt_usd) avg_spent
  FROM orders
  ),

  above_average_total_spent AS (
    SELECT
      a.name,
      AVG(o.total_amt_usd) lifetime_average_spent
    FROM orders o
    JOIN accounts a
      ON a.id = o.account_id
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT avg_spent FROM average_spent)
    ORDER BY 2 DESC
    )

SELECT
  AVG(lifetime_average_spent) average
FROM above_average_total_spent;
