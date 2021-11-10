/*
NULLS:-
NULLs are a datatype that specifies where no data exists in SQL.
They are often ignored in our aggregation functions
When identifying NULLs in a WHERE clause,
we write IS NULL or IS NOT NULL.
We don't use =, because NULL isn't considered a value in SQL. Rather, it is a property of the data.
NULLs frequently occur when performing a LEFT or RIGHT JOIN
NULLs can also occur from simply missing data in our database.

Aggregation Reminder
An important thing to remember: aggregators only aggregate vertically - the values of a column.
If you want to perform a calculation across rows, you would do this with simple arithmetic.

COUNT does not consider rows that have NULL values. Therefore, this can be useful for quickly identifying which rows have missing data
SUM can only be used on numeric columns. However, SUM will ignore NULL values as do the other aggregation functions
MIN and MAX are similar to COUNT in that they can be used on non-numerical columns. Depending on the column type,
MIN will return the lowest number, earliest date, or non-numerical value as early in the alphabet as possible.
MAX returns the highest number, the latest date, or the non-numerical value closest alphabetically to “Z.”
AVG returns the mean of the data
  One quick note that a median might be a more appropriate measure of center for this data,
  but finding the median happens to be a pretty difficult thing to get using SQL alone —
  so difficult that finding a median is occasionally asked as an interview question.
*/

/* find MEDIAN total_usd spent on all orders */
SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2

/*
GROUP BY can be used to aggregate data within subsets of the data
ANY column in the SELECT statement that is NOT within an aggregator MUST be in the GROUP BY clause.
The GROUP BY always goes between WHERE and ORDER BY
  WHERE filters base data
  GROUP BY aggregates base data within subsets of the data
  ORDER BY works like SORT in spreadsheet software
    You can GROUP BY multiple columns at once
    The order of column names in your GROUP BY clause doesn’t matter
    However, The order of columns listed in the ORDER BY clause does make a difference. You are ordering the columns from left to right
    As with ORDER BY, you can substitute numbers for column names in the GROUP BY clause
SQL evaluates the aggregations before the LIMIT clause
*/

/*Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event?*/
SELECT MAX(W.occurred_at) AS latest, W.channel, A.name
FROM accounts AS A
JOIN web_events AS W
ON A.id=W.account_id
GROUP BY W.channel, A.name
ORDER BY latest DESC
LIMIT 1;

/*Who was the primary contact associated with the earliest web_event?*/
SELECT MIN(W.occurred_at) AS earliest,  A.primary_poc
FROM accounts AS A
JOIN web_events AS W
ON A.id=W.account_id
GROUP BY A.primary_poc
ORDER BY earliest
LIMIT 1;

/*Determine the number of times a particular channel was used in the web_events table for each region.
Your final table should have three columns
- the region name, the channel, and the number of occurrences.
Order your table with the highest number of occurrences first.*/
SELECT r.name region_name, w.channel channel, COUNT(w.channel) total
FROM region r
JOIN sales_reps s
ON r.id=s.region_id
JOIN accounts a
ON s.id=a.sales_rep_id
JOIN web_events w
ON a.id=w.account_id
GROUP BY 2, 1 /*or 1, 2*/
ORDER BY 3 DESC /*switching changes things unlike in group by*/

/*
SELECT DISTINCT:-
DISTINCT is always used in SELECT statements, and it provides the unique rows for ALL columns written in the SELECT statement.
Therefore, you only use DISTINCT ONCE in any particular SELECT statement.

You could write:
SELECT DISTINCT column1, column2, column3
FROM table1;
which would return the unique (or DISTINCT) rows across all three columns.

You would NOT write:
SELECT DISTINCT column1, DISTINCT column2, DISTINCT column3
FROM table1;
Y
ou can think of DISTINCT the same way you might think of the statement "unique".
*/

/*
HAVING:-
HAVING is the “clean” way to filter a query that has been aggregated
Essentially, any time you want to perform a WHERE on an element of your query that was created by an aggregate, you need to use HAVING instead.
*/

/*How many accounts have more than 20 orders?*/
SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY num_orders;

/*
DATE FUNCTIONS:-
databases uses YYYY-MM-DD 00:00:00 (best format for sorting dates)
Keeping date information at such a granular data is both a blessing and a curse,
as it gives really precise information (a blessing),
but it makes grouping information together directly difficult (a curse).
due to the date being accurate to the second, grouping by dates is essentially useless
so we use DATE_TRUNC:
  DATE_TRUNC('argument',column_name) arguments here include day, week, month, year or second ...
  always GROUP BY the same DATE_TRUNC function used in the SELECT statement
DATE_PART:
  DATE_PART('argument',column_name)
  useful for pulling a specific portion of a date,
  but notice pulling month or day of the week (dow) means that you are no longer keeping the years in order.
  Rather you are grouping for certain components regardless of which year they belonged in.
more date functions at https://www.postgresql.org/docs/9.1/functions-datetime.html
*/

/*Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least.
 Do you notice any trends in the yearly sales totals?*/
 SELECT DATE_PART('year', occurred_at) ord_year,  SUM(total_amt_usd) total_spent
 FROM orders
 GROUP BY 1
 ORDER BY 2 DESC;
/*When we look at the yearly totals, you might notice that 2013 and 2017 have much smaller totals than all other years.
If we look further at the monthly data, we see that for 2013 and 2017 there is only one month of sales for each of these years (12 for 2013 and 1 for 2017).
Therefore, neither of these are evenly represented. Sales have been increasing year over year, with 2016 being the largest sales to date.
At this rate, we might expect 2017 to have the largest sales.*/


/*Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?
In order for this to be meaningful, we should remove the sales from 2013 and 2017. For the same reasons as discussed above.*/
SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01' /*inclusive of 2017-01-01 00:00:00 only. NOT the entire day*/
GROUP BY 1
ORDER BY 2 DESC;
/*The greatest sales amounts occur in December (12).*/


/*Which year did Parch & Posey have the greatest sales in terms of total number of orders?
Are all years evenly represented by the dataset?*/
SELECT DATE_PART('year', occurred_at) ord_year,  COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
/*Again, 2016 by far has the most amount of orders, but again 2013 and 2017 are not evenly represented to the other years in the dataset.*/


/*Which month did Parch & Posey have the greatest sales in terms of total number of orders? Are all months evenly represented by the dataset?*/
SELECT DATE_PART('month', occurred_at) ord_month, COUNT(*) total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;
/*December still has the most sales, but interestingly, November has the second most sales (but not the most dollar sales.
To make a fair comparison from one month to another 2017 and 2013 data were removed.*/


/*In which month of which year did Walmart spend the most on gloss paper in terms of dollars?*/
SELECT DATE_TRUNC('month', o.occurred_at) ord_date, SUM(o.gloss_amt_usd) total_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
/*May 2016 was when Walmart spent the most on gloss paper.*/

/*
CASE STATEMENTS:-
SQL's if THEN statement --> creates a new column based on a condition
CASE WHEN condition/s THEN 'value' ELSE 'value' END AS column_name
  -CASE must include the following components: WHEN, THEN, and END.
  ELSE is an optional component to catch cases that didn’t meet any of the other previous CASE conditions.
  -You can make any conditional statement using any conditional operator (similar to WHERE) between WHEN and THEN.
  This includes stringing together multiple conditional statements using AND and OR
  -You can include multiple WHEN statements, as well as an ELSE statement again,
  to deal with any unaddressed conditions.
*/

/*Write a query to display for each order, the account ID, total amount of the order,
and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or less than $3000.*/
SELECT account_id, total_amt_usd,
CASE WHEN total_amt_usd > 3000 THEN 'Large'
ELSE 'Small' END AS order_level
FROM orders;


/*Write a query to display the number of orders in each of three categories, based on the total number of items in each order.
The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.*/
SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
   WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
   ELSE 'Less than 1000' END AS order_category,
COUNT(*) AS order_count
FROM orders
GROUP BY 1;


/*We would like to understand 3 different branches of customers based on the amount associated with their purchases.
The top branch includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd.
The second branch is between 200,000 and 100,000 usd. The lowest branch is anyone under 100,000 usd.
Provide a table that includes the level associated with each account.
You should provide the account name, the total sales of all orders for the customer, and the level.
Order with the top spending customers listed first.*/
SELECT a.name, SUM(total_amt_usd) total_spent,
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
     WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
     ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY 2 DESC;


/*We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers only in 2016 and 2017.
Keep the same levels as in the previous question. Order with the top spending customers listed first.*/
SELECT a.name, SUM(total_amt_usd) total_spent,
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
     WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
     ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31'
GROUP BY 1
ORDER BY 2 DESC;


/*We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders.
Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders.
Place the top sales people first in your final table.*/
SELECT s.name, COUNT(*) num_ords,
     CASE WHEN COUNT(*) > 200 THEN 'top'
     ELSE 'not' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 2 DESC;
/*It is worth mentioning that this assumes each name is unique - which has been done a few times.
We otherwise would want to break by the name and the id of the table.*/


/*The previous didn't account for the middle, nor the dollar amount associated with the sales.
Management decides they want to see these characteristics represented as well.
We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales.
The middle group has any rep with more than 150 orders or 500000 in sales.
Create a table with the sales rep name, the total number of orders, total sales across all orders, and a column with top, middle, or low depending on this criteria.
Place the top sales people based on dollar amount of sales first in your final table.*/
SELECT s.name, COUNT(*), SUM(o.total_amt_usd) total_spent,
     CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
     WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
     ELSE 'low' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC;
