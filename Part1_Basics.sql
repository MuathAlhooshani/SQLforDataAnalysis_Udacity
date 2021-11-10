/* SELECT --> chooses columns to output
FROM --> chooses the table where selected columns come from
WHERE --> filters the base data
ORDER BY --> chooses what column the output will be ordered by
             -default is ascending otherwise add DESC
             -you can choose more than 1 column to order by sequentially
LIMIT --> chooses how many rows to output
*/
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC

SELECT id, account_id, total_amt_usd;
FROM orders
ORDER BY total_amt_usd DESC, account_id;

SELECT *
FROM orders
WHERE gloss_amt_usd>=1000
LIMIT 5;

SELECT *
FROM orders
WHERE total_amt_usd<500
LIMIT 10;

/*The WHERE statement can also be used with non-numeric data.
We can use the = and != operators here.
You need to be sure to use double quotes
(just be careful if you have quotes in the original text)
with the text data, not double quotes.
Commonly when we are using WHERE with non-numeric data fields,
we use the LIKE, NOT, or IN*/
SELECT name, website, primary_poc
FROM accounts
WHERE name ='Exxon Mobil company';

/*Creating a new column that is a combination of existing columns is known as a derived column
(or "calculated" or "computed" column).
Usually you want to give a name, or "alias," to your new column using the AS keyword.
This derived column, and its alias, are generally only temporary,
existing just for the duration of your query.
The next time you run a query and access this table, the new column will not be there.*/
SELECT id, account_id, standard_amt_usd/standard_qty AS std_unit_price
FROM orders
LIMIT 10;

SELECT id, account_id, (poster_amt_usd/total_amt_usd)*100 AS poster_revenue_percent
FROM orders
LIMIT 10;

/*-LIKE This allows you to perform operations similar to using WHERE and =,
but for cases when you might not know exactly what you are looking for.
-IN This allows you to perform operations similar to using WHERE and =,
but for more than one condition.
-NOT This is used with IN and LIKE to select all of the rows NOT LIKE or NOT IN a certain condition.
-AND & BETWEEN These allow you to combine operations where all combined conditions must be true.
-OR This allows you to combine operations where at least one of the combined conditions must be true.
*/
/*The LIKE operator is frequently used with %.
The % tells us that we might want any number of characters leading up to a particular set of characters
or following a certain set of characters, as we saw with the google syntax above
"%google%" means (double quotes because its text)
any number charachters in before "google" + it contains "goggle" +
it has any number of charachters after "google"
*/
SELECT *
FROM accounts
WHERE name LIKE 'C%'

SELECT *
FROM accounts
WHERE name LIKE '%one%'

SELECT *
FROM accounts
WHERE name LIKE '%s'
/* IN --> used to filter base data in with WHERE
          just like = but allows more than 1 filter
          useful for working with both numeric and text columns
          e.g. WHERE column IN ("text1","text2", ...)
          same as OR but cleaner syntax
*/
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstorm')

SELECT *
FROM orders
WHERE total IN (0,524)
/*The NOT operator is an extremely useful operator for working with the previous two operators we introduced: IN and LIKE.
By specifying NOT LIKE or NOT IN,
we can grab all of the rows that do not meet a particular criteria.*/

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstorm')

SELECT *
FROM accounts
WHERE name NOT LIKE 'C%'

/*The AND operator
used within a WHERE statement to consider more than one logical clause at a time
This operator works with all of the operations we have seen so far including arithmetic operators (+, *, -, /).
LIKE, IN, and NOT logic can also be linked together using the AND operator.
--the BETWEEN operator in SQL is inclusive--
WHERE column BETWEEN 6 AND 10 = WHERE column >= 6 AND column <= 10

The OR operator
This operator works with all of the operations we have seen so far including arithmetic operators (+, *, -, /),
LIKE, IN, NOT, AND, and BETWEEN logic can all be linked together using the OR operator.

note: When combining multiple of these operations,
we frequently might need to use parentheses e.g.(xxx OR xxx OR xxx) AND xxx
*/


/*Find all the company names that start with a 'C' or 'W',
and the primary contact contains 'ana' or 'Ana', but it doesn't contain 'eana'.*/
SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
           AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
           AND primary_poc NOT LIKE '%eana%');
