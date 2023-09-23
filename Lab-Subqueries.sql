-- LAB | SQL Subqueries

USE sakila;

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system:

SELECT COUNT(*) AS copies_available
FROM film
JOIN inventory ON film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible';

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip"

SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (
   SELECT actor_id FROM film_actor
	WHERE film_id = 
		(SELECT film_id FROM film WHERE title = 'Alone Trip'));

-- 4.Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.

SELECT title
FROM film
WHERE film_id IN (
SELECT film_id FROM film_category
 WHERE category_id = (
   SELECT category_id FROM category 
   WHERE name = 'Family'));

/*5.Retrieve the name and email of customers from Canada using both subqueries and joins.
 To use joins, you will need to identify the relevant tables and their primary and foreign keys.*/

SELECT 
c.first_name,
c.last_name,
c.email,
co.country,
ci.city
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN (
	SELECT 
	ci.city_id,
	ci.city,
	co.country_id
	FROM city ci
	JOIN 
	country co ON ci.country_id = co.country_id
    ) AS ci ON a.city_id = ci.city_id
JOIN 
    (
	SELECT 
	co.country_id,
	co.country
	FROM country co
	WHERE co.country = 'Canada') AS co ON ci.country_id = co.country_id;
/*6. Determine which films were starred by the most prolific actor in the Sakila database.
 A prolific actor is defined as the actor who has acted in the most number of films.
 First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.*/
-- finding the profilic actor 
SELECT a.actor_id, CONCAT(a.first_name, ' ', a.last_name) AS actor_name, COUNT(fa.film_id) AS film_count
FROM actor AS a
JOIN film_actor AS fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, actor_name
ORDER BY film_count DESC
LIMIT 1;
-- Determine which films were starred by the most prolific actor in the Sakila database.
SELECT f.title AS film_title
FROM film AS f
JOIN film_actor AS fa ON f.film_id = fa.film_id
JOIN (
    SELECT a.actor_id, CONCAT(a.first_name, ' ', a.last_name) AS actor_name, COUNT(fa.film_id) AS film_count
    FROM actor AS a
    JOIN film_actor AS fa ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id, actor_name
    ORDER BY film_count DESC
    LIMIT 1
) AS most_prolific_actor
ON most_prolific_actor.actor_id = fa.actor_id;

/*7.Find the films rented by the most profitable customer in the Sakila database.
 You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments*/
-- most profitable customer 
SELECT
    c.first_name,
    c.last_name,
    p.customer_id,
    p.total_payments
FROM (
    SELECT customer_id, SUM(amount) AS total_payments
    FROM payment
    GROUP BY customer_id
    ORDER BY total_payments DESC
    LIMIT 1
) AS p
JOIN customer AS c ON p.customer_id = c.customer_id;
-- Find the films rented by the most profitable customer in the Sakila database
SELECT c.first_name, c.last_name, film.title AS film_title
FROM customer AS c
JOIN (
    SELECT customer_id, SUM(amount) AS total_payments
    FROM payment
    GROUP BY customer_id
    ORDER BY total_payments DESC
    LIMIT 1
) AS most_profitable_customer
ON c.customer_id = most_profitable_customer.customer_id
JOIN rental ON c.customer_id = rental.customer_id
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id;
 /*8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
 You can use subqueries to accomplish this.*/
SELECT customer_id, total_amount_spent
FROM (
    SELECT
        customer_id,
        SUM(amount) AS total_amount_spent
    FROM
        payment
    GROUP BY
        customer_id
) AS client_total_spent
WHERE total_amount_spent > (
    SELECT AVG(total_amount_spent)
    FROM (
        SELECT
            customer_id,
            SUM(amount) AS total_amount_spent
        FROM
            payment
        GROUP BY
            customer_id
    ) AS client_avg_spent
); 