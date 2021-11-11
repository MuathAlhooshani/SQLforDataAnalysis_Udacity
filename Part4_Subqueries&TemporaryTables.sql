/*
Subqueries and Temporary Tables:-
Whenever we need to use existing tables to create a new table that we then want to query again,
this is an indication that we will need to use some sort of subquery

Formating:-
As a general rule the outer query should have all its commands (SELECT, FROM, GROUP BY..) on the same indentation level
e.g.

*/
SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2
      ORDER BY 3 DESC) sub
GROUP BY day, channel, events
ORDER BY 2 DESC;
/*name the subquery after closing parentheses.
However, do  not include an alias when you write a subquery in a conditional statement.
his is because the subquery is treated as an individual value (or set of values in the IN case) rather than as a table.*/


/*Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.*/

/*first summation of total_amt_usd sold grouped by the sales_rep and the region se we have a table that we can use later to get the MAX total_amt_usd*/
SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1,2
ORDER BY 3 DESC;
/*then we pull the MAX(total_amt) from the table above for each region)*/
SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1;
/*now we need to find the sales_rep that matches that highest total per region. since we have 2 tables that match the region name and the specific total amt usd
we can JOIN these two tables, ON the region AND total amt usd to find the name of the sales rep that made that largest amt of total sales usd for each region*/
SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;


/*How many accounts had more total purchases than
the account name which has bought the most standard_qty paper throughout their lifetime as a customer?*/
/*first account name most standard_qty paper*/
SELECT A.name AS account, SUM(O.standard_qty) AS total_standard
FROM orders AS O
JOIN accounts AS A
ON A.id=O.account_id
GROUP BY 1
ORDER BY 2 DESC;

SELECT account AS most_StdQty_account
FROM (SELECT A.name AS account, SUM(O.standard_qty) AS total_standard
      FROM orders AS O
      JOIN accounts AS A
      ON A.id=O.account_id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 1;) t1
/*How many accounts had more total purchases than the account derived from the query above*/
SELECT A.name AS name, SUM(O.total) AS total_purchased
FROM orders AS O
JOIN accounts AS A
ON A.id=O.account_id
GROUP BY 1
HAVING SUM(O.total) > (SELECT total_standard FROM
  (SELECT A.name AS account, SUM(O.standard_qty) AS total_standard
      FROM orders AS O
      JOIN accounts AS A
      ON A.id=O.account_id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 1) t1)


/*What is the lifetime average amount spent in terms of total_amt_usd,
including only the companies that spent more per order, on average, than the average of all orders.*/
/*first, overall average.*/
SELECT AVG(O.total_amt_usd) overall_avg
FROM orders AS O
/*companies that spent more per order, on average, than the average of all orders*/
SELECT A.name AS account, AVG(O.total_amt_usd) Average_spent
FROM orders AS O
JOIN accounts AS A
ON A.id=O.account_id
GROUP BY 1
HAVING AVG(O.total_amt_usd) > (SELECT AVG(O.total_amt_usd) overall_avg
                               FROM orders AS O)
/*finally the average of the above averages*/
SELECT AVG(Average_spent) AS THE_avg
FROM (SELECT A.name AS account, AVG(O.total_amt_usd) Average_spent
      FROM orders AS O
      JOIN accounts AS A
      ON A.id=O.account_id
      GROUP BY 1
      HAVING AVG(O.total_amt_usd) > (SELECT AVG(O.total_amt_usd) overall_avg
                                     FROM orders AS O)) t1

/*
WITH STATEMENT:-
on of the problems with subqueries is that it makes the query difficult to read.
Moreover, if the inner query takes a significant amount of time, then experimenting with the outer query will be tedious

Therefore, we ameliorate this by using the WITH statement which is often called a Common Table Expression or CTE.
example given below:-
*/
/* Question: You need to find the average number of events for each channel per day.

SOLUTION:*/

SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;
/*Let's try this again using a WITH statement.
Notice, you can pull the inner query:*/

SELECT DATE_TRUNC('day',occurred_at) AS day,
       channel, COUNT(*) as events
FROM web_events
GROUP BY 1,2

/*This is the part we put in the WITH statement. Notice, we are aliasing the table as events below:*/

WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day,
                        channel, COUNT(*) as events
          FROM web_events
          GROUP BY 1,2)

/*Now, we can use this newly created events table as if it is any other table in our database:*/

WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day,
                        channel, COUNT(*) as events
          FROM web_events
          GROUP BY 1,2)

SELECT channel, AVG(events) AS average_events
FROM events
GROUP BY channel
ORDER BY 2 DESC;

/*For the above example, we don't need anymore than the one additional table,
but imagine we needed to create a second table to pull from. We can create an additional table to pull from in the following way:*/

WITH table1 AS (
          SELECT *
          FROM web_events), /*comma*/

     table2 AS (
          SELECT *
          FROM accounts)

SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;
