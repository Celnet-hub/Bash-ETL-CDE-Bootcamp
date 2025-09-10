-- Description: Contains SQL queries to answer business questions from Ayoola.
-- =============================================================================

/*
QUESTION 1:
Find a list of order IDs where either gloss_qty or poster_qty is greater than 4000. 
Only include the id field in the resulting table.
*/
SELECT id
FROM orders
-- Filters the orders to include only those where the quantity of gloss paper
-- OR the quantity of poster paper is more than 4000 units.
WHERE gloss_qty > 4000 OR poster_qty > 4000;


/*
QUESTION 2:
Write a query that returns a list of orders where the standard_qty is zero 
and either the gloss_qty or poster_qty is over 1000.
*/
SELECT *
FROM orders
-- Filters for orders that meet two criteria:
--   The quantity of standard paper must be exactly zero.
--   EITHER the gloss quantity OR the poster quantity must exceed 1000.
--   The parentheses ensure the OR condition is evaluated first before the AND.
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);


/*
QUESTION 3:
Find all the company names that start with a 'C' or 'W', and where the 
primary contact contains 'ana' or 'Ana', but does not contain 'eana'.
*/
SELECT name, primary_poc
FROM accounts
-- This WHERE clause combines three conditions:
-- 1. The company name must start with either 'C' or 'W'.
WHERE (name LIKE 'C%' OR name LIKE 'W%')
  -- 2. The primary contact's name must contain 'ana' in a case-insensitive manner.
  --    ILIKE is a PostgreSQL extension for case-insensitive LIKE.
  AND primary_poc ILIKE '%ana%'
  -- 3. The primary contact's name must not contain the substring 'eana'.
  AND primary_poc NOT LIKE '%eana%';

  
/*
QUESTION 4:
Provide a table that shows the region for each sales rep along with their 
associated accounts. Your final table should include three columns: the 
region name, the sales rep name, and the account name. Sort the accounts 
alphabetically (A-Z) by account name.
*/

-- Select and alias the columns for the final report for clarity.
SELECT r.name AS region_name,
       s.name AS sales_rep_name,
       a.name AS account_name
-- Start with the region table, as it is the highest-level entity in this query.
FROM region AS r
-- Join region to sales_reps on their shared ID to link each rep to their region.
JOIN sales_reps AS s
  ON r.id = s.region_id
-- Join the result to accounts on the sales_rep_id to link each account to its sales rep.
JOIN accounts AS a
  ON s.id = a.sales_rep_id
-- Sort the entire result set alphabetically by the account's name.
ORDER BY a.name;

