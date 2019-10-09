-- Use sakila
USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT UPPER(CONCAT(first_name,' ',last_name)) AS 'Actor Name'
FROM actor; 


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name='Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT * FROM actor;
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT actor_id, last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- 		so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_update;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) as 'Last_Name_Count'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) as 'Last_Name_Count'
FROM actor
GROUP BY last_name
HAVING COUNT(*) >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor
SET first_name = 'HARPO'
WHERE last_name = 'WILLIAMS' AND first_name = 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- 		In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE last_name = 'WILLIAMS' AND first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- 		Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT s.first_name, s.last_name, a.address
FROM staff AS s INNER JOIN address AS a
ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT S.first_name, S.last_name, SUM(P.amount) as 'Total Amount'
From staff AS S INNER JOIN payment AS P
ON (S.staff_id = P.staff_id) AND P.payment_date LIKE '2005-08-%'
GROUP BY first_name, last_name;
-- !!!!Are tehre only supposed to be two names in staff?

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT F.title, COUNT(A.actor_id) as 'Actor Count'
FROM film_actor AS A INNER JOIN film as F
ON A.film_id = F.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT F.title, COUNT(F.title) as 'Copies Available'
FROM film AS F INNER JOIN inventory AS I
ON F.film_id = I.film_id
WHERE title = 'Hunchback Impossible';
-- !!! WHat is this getting this solution from???!! NO FILM ID 439

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT C.first_name, C.last_name, SUM(P.amount) as 'Total Paid by Each Customer'
FROM payment AS P INNER JOIN customer AS C
ON P.customer_id = C.customer_id
GROUP BY first_name, last_name
ORDER BY last_name; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- 		As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- 		Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE language_id IN
(
		SELECT language_id
		FROM language 
		WHERE name = 'English' AND (title LIKE 'K%' or title LIKE 'Q%')
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
		(
		SELECT actor_id
		FROM film_actor
		WHERE film_id IN
		(
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip' ));
	
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.


SELECT first_name, last_name, email, country
FROM customer as C
JOIN address as A
ON (C.address_id = A.address_id)
JOIN city as T
ON (T.city_id = A.city_id)
JOIN country as Y
ON (Y.country_id = T.country_id)
WHERE (Y.country = 'Canada');
-- CLEANUP THIS CODE

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT title 
FROM film 
WHERE film_id IN 
	(
    SELECT film_id 
	FROM film_category 
    WHERE category_id IN 
		(
		SELECT category_id 
        FROM category 
        WHERE name='Family'
        )
    );

-- 7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(rental_id) as 'Rental Count'
FROM rental as R
JOIN inventory as I
ON (R.inventory_id = I.inventory_id)
JOIN film as F
ON (I.film_id = F.film_id)
GROUP BY F.title
ORDER BY COUNT(rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT S.store_id, SUM(amount)
FROM store AS S
INNER JOIN staff AS F
ON S.store_id = F.store_id
INNER JOIN payment AS P
ON P.staff_id = F.staff_id
GROUP BY S.store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT S.store_id, C.city, Y.country
FROM store as S
INNER JOIN address AS A
ON S.address_id = A.address_id
INNER JOIN city AS C
ON C.city_id = A.city_id
INNER JOIN country AS Y
ON Y.country_id = C.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT name, SUM(amount)
FROM category AS C
INNER JOIN film_category AS Fc
ON C.category_id = Fc.category_id
INNER JOIN inventory AS I
ON Fc.film_id = I.film_id
INNER JOIN rental as R
ON I.inventory_id = R.inventory_id
INNER JOIN payment AS P
ON R.rental_id = P.rental_id
GROUP BY name
ORDER BY SUM(amount) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- 		Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_genre AS
SELECT name, SUM(amount)
FROM category AS C
INNER JOIN film_category AS Fc
ON C.category_id = Fc.category_id
INNER JOIN inventory AS I
ON Fc.film_id = I.film_id
INNER JOIN rental as R
ON I.inventory_id = R.inventory_id
INNER JOIN payment AS P
ON R.rental_id = P.rental_id
GROUP BY name
ORDER BY SUM(amount) DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_genre;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_genre;