/* question 1 Create a query that lists each movie, the family friendly film category
it is classified in, and the number of times it has been rented out. */
WITH t1 AS(
        SELECT f.title film_title, c.name category,r.inventory_id
        FROM film f
        JOIN film_category fc
        ON f.film_id=fc.film_id
        JOIN category c
        ON c.category_id=fc.category_id
        JOIN inventory i
        ON f.film_id=i.inventory_id
        JOIN rental r
        ON r.inventory_id=i.inventory_id
        WHERE c.name='Animation' OR c.name='Children' OR c.name='Classics'
        OR c.name='Comedy' OR c.name='Family' OR c.name= 'Music')

SELECT  DISTINCT(film_title), category,
        COUNT(inventory_id) OVER(PARTITION BY film_title) AS rented_total
FROM t1
ORDER BY 2, 3 DESC;



/*question 2- Can you provide a table with the movie titles and divide them into 4 levels
(first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%)
of the rental duration for movies across all categories?
Make sure to also indicate the category that these family-friendly movies fall into.*/
WITH t1 AS (
  SELECT f.title film_title, c.name category_name,f.rental_duration rental_duration
  FROM film f
  JOIN film_category fc
  ON f.film_id=fc.film_id
  JOIN category c
  ON c.category_id=fc.category_id
  WHERE c.name='Animation' OR c.name='Children' OR c.name='Classics'
  OR c.name='Comedy' OR c.name='Family' OR c.name= 'Music')

SELECT DISTINCT(film_title), category_name,rental_duration,
       NTILE(4) OVER(ORDER BY rental_duration) AS standard_quartile
FROM t1
ORDER BY 4;



/*query 3 What are the most rented categories of films*/
SELECT c.name category_name,COUNT(r.inventory_id) rental_count
FROM film f
JOIN film_category fc
ON f.film_id=fc.film_id
JOIN category c
ON c.category_id=fc.category_id
JOIN inventory i
ON f.film_id=i.inventory_id
JOIN rental r
ON r.inventory_id=i.inventory_id
GROUP BY 1
ORDER BY 2 DESC;



/* query 4 - what are the full names of the most worked actors
in termd of total films acted in*/
SELECT a.first_name || ' ' || a.last_name AS full_name,
       COUNT(f.film_id) AS total_titles
FROM actor a
JOIN film_actor f
ON a.actor_id=f.actor_id
GROUP BY 1
ORDER BY 2 DESC;
