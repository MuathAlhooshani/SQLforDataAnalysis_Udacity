/*  A primary key exists in every table, and it is a column that has a unique value for every row.
A foreign key is a column in one table that is a primary key in a different table.
the primary key of a cetain table has a unique value for every row.
the forien key in a certain table can appear in many rows (not unique)
this allows for one-to-one and one-to-many relationships

why no many-to-many relationships?
https://stackoverflow.com/questions/7339143/why-no-many-to-many-relationships  */


/*INNER JOIN == JOIN:-
when joining tables it is common to give aliases to tables
and aliases for  the columns selected to have the resulting table reflect a more readable name.
However, If you have two or more columns in your SELECT that have the same name after the table name such as accounts.name and sales_reps.name
you will need to alias them. Otherwise it will only show one of the columns.
example below:-*/
Select A.name AcountName, S.name AS SalesRepName
FROM accounta AS A
JOIN sales_reps AS S

/*Provide a table for all web_events associated with account name of Walmart. There should be three columns.
Be sure to include the primary_poc, time of the event, and the channel for each event.
Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.*/
SELECT A.primary_poc, W.occurred_at AS time_of_event, W.channel
FROM web_events AS W
JOIN accounts AS A
ON A.id = W.account_id
WHERE A.name = "Walmart"

/*Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total)
 for the order. Your final table should have 3 columns: region name, account name, and unit price.
 A few accounts have 0 for total,
 so I divided by (total + 0.01) to assure not dividing by zero.*/
 SELECT R.name AS region_name, A.name AS account_name,
        O.total_amt_usd/(O.total+0.000000000000001) AS unit_price
 FROM region AS R
 JOIN sales_reps AS S
 ON R.id=S.region_id
 JOIN accounts AS A
 ON S.id=A.sales_rep_id
 JOIN orders AS O
 ON A.id=O.account_id

/*LEFT AND RIGHT JOINS:-
 venn diagrams to visualize LEFT and RIGHT joins---> left circle is FROM, right circle is JOIN
 then we can get ---> LEFT JOIN, RIGHT JOIN == LEFT OUTER JOIN, RIGHT OUTER JOIN
 note:- a LEFT JOIN and RIGHT JOIN do the same thing if we change the tables that are in the FROM and JOIN statement
 each of these new JOIN statements pulls all the same rows as an INNER JOIN,
 but they also potentially pull some additional rows
 if there is not matching information in the JOINed table, then you will have columns with empty cells.
 These empty cells introduce a new data type called NULL
 https://classroom.udacity.com/courses/ud198/lessons/8f23fc69-7c88-4a94-97a4-d5f6ef51cf7b/concepts/d57c222e-1ac5-43d4-8685-e3365f200735#

OUTER JOIN == FULL OUTER JOIN:-.
This will return the inner join result set, as well as any unmatched rows from either of the two tables being joined.
this returns rows that do not match one another from the two tables.
The use cases for a full outer join are very rare.
https://stackoverflow.com/questions/2094793/when-is-a-good-situation-to-use-a-full-outer-join

JOINS and FILTERING:-
in LEFT JOINS after the ON statement--> add AND statement to filter the JOIN table (right venn circle)
adding a WHERE clause instead will remove all NULL rows making it similar to INNER JOIN and not LEFT JOIN
in INNER JOINS ---> this AND filter to the ON clause of will produce the same result as keeping it in the WHERE clause
*/

/*Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for the Midwest region.
Your final table should include three columns: the region name, the sales rep name, and the account name.
Sort the accounts alphabetically (A-Z) according to account name.*/
SELECT R.name AS region, S.name AS sales_rep, A.name AS account
FROM region AS R
JOIN sales_reps AS S
ON R.id=S.region_id
JOIN accounts AS A
ON S.id=A.sales_rep_id
WHERE R.name='Midwest';

/*Provide a table that provides the region for each sales_rep along with their associated accounts.
This time only for accounts where the sales rep has a last name starting with K and in the Midwest region.
Your final table should include three columns: the region name, the sales rep name, and the account name.
 Sort the accounts alphabetically (A-Z) according to account name.*/
 SELECT R.name AS region, S.name AS sales_rep, A.name AS account
 FROM region AS R
 JOIN sales_reps AS S
 ON R.id=S.region_id
 JOIN accounts AS A
 ON S.id=A.sales_rep_id
 WHERE S.name LIKE '% K%' AND R.name='Midwest'
 ORDER BY A.name;

 /*What are the different channels used by account id 1001?*/
 SELECT DISTINCT W.channel, A.name
 FROM accounts  AS A
 JOIN web_events AS W
 ON A.id=W.account_id
 WHERE A.id=1001;
