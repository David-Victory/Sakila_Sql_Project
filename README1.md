# Sakila SQL Analysis

A collection of 35 MySQL queries written against the [Sakila sample database](https://dev.mysql.com/doc/sakila/en/), a DVD rental business with films, customers, stores, staff, rentals and payments. The queries answer practical business questions about revenue, customer behavior, inventory and staff performance.

## Skills Demonstrated

- **Joins:** inner and left joins across up to six tables, using `USING` for clean, readable syntax
- **Aggregation:** `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`
- **CTEs:** multi-step logic broken into readable stages
- **Window functions:** `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, running totals
- **Subqueries:** including correlated subqueries
- **Views:** reusable reporting layer (`film_revenue`)
- **Date handling:** `DATE_FORMAT`, `DATEDIFF` for monthly and gap analysis

## Business Questions Answered

| Area | Examples |
|---|---|
| Revenue | Revenue per store, which store earns more and by how much, running monthly revenue total |
| Customers | Top 5 customers by total paid, customers who rented from both stores, customers above average rental count |
| Customer behavior | Days between consecutive rentals (`LAG`/`LEAD`), each customer's rental history ranked by recency |
| Products | 10 most rented films, top 3 categories by rentals, films never rented, top-grossing film per store |
| Operations | Rentals handled per staff member per month, staff performance classification |

## Query Index

| # | Topic | Techniques |
|---|---|---|
| 1-6, 9, 12 | Filtering and basic counts | `WHERE`, `LIKE`, `COUNT` |
| 2, 8 | Category-level summaries | `JOIN ... USING`, `GROUP BY` |
| 3, 10, 26 | Rental history and gaps | `ROW_NUMBER`, `LAG`, `LEAD` |
| 5, 14 | Missing data checks | `LEFT JOIN ... IS NULL` |
| 7, 35 | Store revenue | CTE, `RANK` |
| 13 | Film revenue view | `CREATE VIEW` |
| 15 | Actor ranking within category | CTE, `DENSE_RANK` |
| 18, 31 | Above-average comparisons | Correlated subqueries |
| 23 | Monthly revenue trend | CTE, cumulative `SUM() OVER` |
| 32 | Top film per store | CTE, `RANK` |
| 33 | Customers active in both stores | `HAVING COUNT(DISTINCT ...)` |

## How to Run

**Requirements:** MySQL 8.0 or later (needed for CTEs and window functions) and the Sakila database.

1. Install the Sakila database by following the [official instructions](https://dev.mysql.com/doc/sakila/en/sakila-installation.html) (download `sakila-schema.sql` and `sakila-data.sql`, then run both).
2. Open `My_sql_project.sql` in MySQL Workbench or your preferred client.
3. Run the whole script, or run individual queries one at a time. The first line (`USE sakila;`) selects the database.

## Notes on Method

- **Store revenue** is attributed using the store that owns the rented copy (`payment` to `rental` to `inventory`).
- Payments with no linked rental are excluded by those joins.
- Staff performance thresholds (High/Medium/Low) are illustrative and can be tuned.

## Tools

MySQL 8.0, MySQL Workbench

## Author

*Okoro David-Victory* | [LinkedIn[](https://www.linkedin.com/in/david-victory-okoro-19b0b8414/)) | [Portfolio](https://github.com/David-Victory/)
