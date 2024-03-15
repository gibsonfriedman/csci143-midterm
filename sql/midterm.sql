/* PROBLEM 1:
 *
 * The Office of Foreign Assets Control (OFAC) is the portion of the US government that enforces international sanctions.
 * OFAC is conducting an investigation of the Pagila company to see if you are complying with sanctions against North Korea.
 * Current sanctions limit the amount of money that can be transferred into or out of North Korea to $5000 per year.
 * (You don't have to read the official sanctions documents, but they're available online at <https://home.treasury.gov/policy-issues/financial-sanctions/sanctions-programs-and-country-information/north-korea-sanctions>.)
 * You have been assigned to assist the OFAC auditors.
 *
 * Write a SQL query that:
 * Computes the total revenue from customers in North Korea.
 *
 * NOTE:
 * All payments in the pagila database occurred in 2022,
 * so there is no need to do a breakdown of revenue per year.
 */

SELECT sum(amount) FROM payment
JOIN customer USING(customer_id)
JOIN address USING(address_id)
JOIN city USING(city_id)
JOIN country USING(country_id)
WHERE country = 'North Korea';





/* PROBLEM 2:
 *
 * Management wants to hire a family-friendly actor to do a commercial,
 * and so they want to know which family-friendly actors generate the most revenue.
 *
 * Write a SQL query that:
 * Lists the first and last names of all actors who have appeared in movies in the "Family" category,
 * but that have never appeared in movies in the "Horror" category.
 * For each actor, you should also list the total amount that customers have paid to rent films that the actor has been in.
 * Order the results so that actors generating the most revenue are at the top.
 */

SELECT a.first_name, a.last_name, SUM(p.amount) AS total_revenue
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family'
AND a.actor_id NOT IN (
    SELECT fa.actor_id
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    WHERE c.name = 'Horror'
)
GROUP BY a.actor_id
ORDER BY total_revenue DESC;





/* PROBLEM 3:
 *
 * You love the acting in AGENT TRUMAN, but you hate the actor RUSSELL BACALL.
 *
 * Write a SQL query that lists all of the actors who starred in AGENT TRUMAN
 * but have never co-starred with RUSSEL BACALL in any movie.
 */

SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.title = 'AGENT TRUMAN'
AND NOT EXISTS (
    SELECT 1
    FROM film_actor fa2
    JOIN film f2 ON fa2.film_id = f2.film_id
    JOIN actor a2 ON fa2.actor_id = a2.actor_id
    WHERE a2.last_name = 'BACALL'
    AND a2.first_name = 'RUSSELL'
    AND EXISTS (
        SELECT 1
        FROM film_actor fa3
        WHERE fa3.actor_id = a.actor_id
        AND fa3.film_id = f2.film_id
    )
)
ORDER BY a.first_name ASC, a.last_name ASC;





/* PROBLEM 4:
 *
 * You want to watch a movie tonight.
 * But you're superstitious,
 * and don't want anything to do with the letter 'F'.
 * List the titles of all movies that:
 * 1) do not have the letter 'F' in their title,
 * 2) have no actors with the letter 'F' in their names (first or last),
 * 3) have never been rented by a customer with the letter 'F' in their names (first or last).
 *
 * NOTE:
 * Your results should not contain any duplicate titles.
 */

SELECT DISTINCT f.title
FROM film f
WHERE f.title NOT ILIKE '%f%'
AND NOT EXISTS (
    SELECT 1
    FROM film_actor fa
    JOIN actor a ON fa.actor_id = a.actor_id
    WHERE fa.film_id = f.film_id
    AND (a.first_name ILIKE '%f%' OR a.last_name ILIKE '%f%')
)
AND NOT EXISTS (
    SELECT 1
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN customer c ON r.customer_id = c.customer_id
    WHERE i.film_id = f.film_id
    AND (c.first_name ILIKE '%f%' OR c.last_name ILIKE '%f%')
);




