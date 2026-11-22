Use sakila;

-- 1. Films with rental rate > 2.99
SELECT film_id, title, rental_rate
FROM film
WHERE rental_rate > 2.99;

-- 2. Number of films per category, highest to lowest
SELECT c.name AS category, COUNT(*) AS total_films
FROM category c
JOIN film_category fc USING (category_id)
GROUP BY c.category_id, c.name
ORDER BY total_films DESC;

-- 3. Rank each customer's rentals, most recent first
SELECT customer_id,
       rental_id,
       rental_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY rental_date DESC) AS rental_rank
FROM rental;

-- 4. Actors whose last name starts with W
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE 'W%';

-- 5. Customers who have never made a payment
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
LEFT JOIN payment p USING (customer_id)
WHERE p.payment_id IS NULL;

-- 6. Staff first and last names
SELECT first_name, last_name
FROM staff;

-- 7. CTE: revenue per store, then rank stores
WITH store_revenue AS (
    SELECT i.store_id, SUM(p.amount) AS total_revenue
    FROM payment p
    JOIN rental r USING (rental_id)
    JOIN inventory i USING (inventory_id)
    GROUP BY i.store_id
) SELECT store_id,total_revenue,
RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM store_revenue;

-- 8. Average rental duration per category
SELECT c.name AS category, ROUND(AVG(f.rental_duration), 2) AS avg_rental_duration
FROM film f
JOIN film_category fc USING (film_id)
JOIN category c USING (category_id)
GROUP BY c.category_id, c.name
ORDER BY avg_rental_duration DESC;

-- 9. Number of PG-13 films
SELECT COUNT(*) AS pg13_films
FROM film
WHERE rating = 'PG-13';

-- 10. Days between each customer's consecutive rentals (LAG)
SELECT customer_id,
       rental_id,
       rental_date,
       DATEDIFF(
           rental_date,
           LAG(rental_date) OVER (PARTITION BY customer_id ORDER BY rental_date)
       ) AS days_since_previous_rental
FROM rental;

-- 11. Top 5 customers by total amount paid
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_paid
FROM customer c
JOIN payment p USING (customer_id)
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_paid DESC
LIMIT 5;

-- 12. Films released in 2006
SELECT film_id, title, release_year
FROM film
WHERE release_year = 2006;

-- 13. VIEW: film_revenue
CREATE OR REPLACE VIEW film_revenue AS
SELECT f.film_id,
       f.title,
       c.name AS category,
       SUM(p.amount) AS total_revenue
FROM film f
JOIN film_category fc USING (film_id)
JOIN category c USING (category_id)
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
JOIN payment p USING (rental_id)
GROUP BY f.film_id, f.title, c.name;

-- 14. Films that have never been rented (includes films with no inventory)
SELECT f.film_id, f.title
FROM film f
LEFT JOIN inventory i USING (film_id)
LEFT JOIN rental r USING (inventory_id)
WHERE r.rental_id IS NULL
GROUP BY f.film_id, f.title;

-- 15. DENSE_RANK actors by number of films, within each category
WITH actor_category_counts AS (
    SELECT c.name AS category,
           a.actor_id,
           a.first_name,
           a.last_name,
           COUNT(*) AS film_count
    FROM actor a
    JOIN film_actor fa USING (actor_id)
    JOIN film_category fc USING (film_id)
    JOIN category c USING (category_id)
    GROUP BY c.name, a.actor_id, a.first_name, a.last_name
)
SELECT category,actor_id,first_name,last_name,film_count,
DENSE_RANK() OVER (PARTITION BY category ORDER BY film_count DESC) AS actor_rank
FROM actor_category_counts
ORDER BY category, actor_rank;

-- 16. Distinct film ratings
SELECT DISTINCT rating
FROM film;

-- 17. Customers per store
SELECT store_id, COUNT(*) AS customer_count
FROM customer
GROUP BY store_id;

-- 18. Correlated subquery: customers with more rentals than the average customer
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
WHERE (SELECT COUNT(*)
       FROM rental r
       WHERE r.customer_id = c.customer_id)
      >
      (SELECT AVG(cnt)
       FROM (SELECT COUNT(*) AS cnt
             FROM rental
             GROUP BY customer_id) t);

-- 19. Address, district and city for all customers
SELECT c.customer_id,c.first_name,c.last_name,a.address,a.district,ci.city
FROM customer c
JOIN address a USING (address_id)
JOIN city ci USING (city_id);

-- 20. 10 most rented films
SELECT f.film_id, f.title, COUNT(r.rental_id) AS rental_count
FROM film f
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
GROUP BY f.film_id, f.title
ORDER BY rental_count DESC
LIMIT 10;

-- 21. All languages
SELECT language_id, name
FROM language;

-- 21. CTE: staff rentals processed + performance classification
--    (thresholds are examples; adjust to your data)
WITH staff_rentals AS (
    SELECT s.staff_id,
           s.first_name,
           s.last_name,
           COUNT(r.rental_id) AS total_rentals
    FROM staff s
    LEFT JOIN rental r USING (staff_id)
    GROUP BY s.staff_id, s.first_name, s.last_name
)
SELECT staff_id,
       first_name,
       last_name,
       total_rentals,
       CASE
           WHEN total_rentals >= 8000 THEN 'High'
           WHEN total_rentals >= 5000 THEN 'Medium'
           ELSE 'Low'
       END AS performance
FROM staff_rentals;

-- 21 . Customers who live in the same city as their registered store
--    (address is joined twice, so the second join keeps ON)
SELECT c.customer_id, c.first_name, c.last_name, ci.city
FROM customer c
JOIN address ca USING (address_id)
JOIN city ci USING (city_id)
JOIN store s USING (store_id)
JOIN address sa ON sa.address_id = s.address_id
WHERE sa.city_id = ca.city_id;

-- 22. Films with replacement cost above $20
SELECT COUNT(*) AS films_over_20
FROM film
WHERE replacement_cost > 20;

-- 23. Running total of monthly rental revenue
WITH monthly AS (
    SELECT DATE_FORMAT(payment_date, '%Y-%m') AS month,
           SUM(amount) AS revenue
    FROM payment
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT month,
       revenue,
       SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;

-- 24. Top 3 categories by number of rentals
SELECT c.name AS category, COUNT(r.rental_id) AS rental_count
FROM category c
JOIN film_category fc USING (category_id)
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
GROUP BY c.category_id, c.name
ORDER BY rental_count DESC
LIMIT 3;

-- 25. Customers named Mary
SELECT customer_id, first_name, last_name
FROM customer
WHERE first_name like 'Mary';

-- 26. LEAD: next rental date and gap in days ##
SELECT customer_id,
       rental_id,
       rental_date,
       LEAD(rental_date) OVER (PARTITION BY customer_id ORDER BY rental_date) AS next_rental_date,
       DATEDIFF(
           LEAD(rental_date) OVER (PARTITION BY customer_id ORDER BY rental_date),
           rental_date
       ) AS gap_days
FROM rental;

-- 27. Average payment amount per store
SELECT i.store_id, ROUND(AVG(p.amount), 2) AS avg_payment
FROM payment p
JOIN rental r USING (rental_id)
JOIN inventory i USING (inventory_id)
GROUP BY i.store_id;

-- 28. Distinct customers per film (top 10)
SELECT f.film_id, f.title, COUNT(DISTINCT r.customer_id) AS distinct_customers
FROM film f
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
GROUP BY f.film_id, f.title
ORDER BY distinct_customers DESC
LIMIT 10;

-- 29. Active customers: full name and email
SELECT CONCAT(first_name, ' ', last_name) AS full_name, email
FROM customer
WHERE active = 1;

-- 30. Films per actor (top 10)
SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS film_count
FROM actor a
JOIN film_actor fa USING (actor_id)
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY film_count DESC
LIMIT 10;

-- 31. Correlated subquery: films costing more to replace than their category average
SELECT f.film_id, f.title, f.replacement_cost
FROM film f
JOIN film_category fc USING (film_id)
WHERE f.replacement_cost > (
    SELECT AVG(f2.replacement_cost)
    FROM film f2
    JOIN film_category fc2 USING (film_id)
    WHERE fc2.category_id = fc.category_id
);

-- 32. CTE + RANK: top-grossing film in each store
WITH film_store_revenue AS (
    SELECT i.store_id,
           f.film_id,
           f.title,
           SUM(p.amount) AS revenue
    FROM payment p
    JOIN rental r USING (rental_id)
    JOIN inventory i USING (inventory_id)
    JOIN film f USING (film_id)
    GROUP BY i.store_id, f.film_id, f.title
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY store_id ORDER BY revenue DESC) AS rnk
    FROM film_store_revenue
)
SELECT store_id, film_id, title, revenue
FROM ranked
WHERE rnk = 1;

-- 33. Customers who rented from both stores
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
JOIN rental r USING (customer_id)
JOIN inventory i USING (inventory_id)
WHERE i.store_id IN (1, 2)
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT i.store_id) = 2;

-- 34. Rentals handled by each staff member per month
SELECT staff_id,
       DATE_FORMAT(rental_date, '%Y-%m') AS month,
       COUNT(*) AS rentals_handled
FROM rental
GROUP BY staff_id, DATE_FORMAT(rental_date, '%Y-%m')
ORDER BY staff_id, month;

-- 35. Which store earns more, and by how much
WITH store_revenue AS (
    SELECT i.store_id, SUM(p.amount) AS revenue
    FROM payment p
    JOIN rental r USING (rental_id)
    JOIN inventory i USING (inventory_id)
    GROUP BY i.store_id
)
SELECT (SELECT store_id FROM store_revenue ORDER BY revenue DESC LIMIT 1) AS top_store,
       MAX(revenue) - MIN(revenue) AS revenue_difference
FROM store_revenue;

