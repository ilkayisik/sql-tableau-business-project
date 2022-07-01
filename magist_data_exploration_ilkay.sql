USE magist;
-- 1. How many orders are there in the dataset? 
# SELECT COUNT(*) FROM orders;
-- if you want to count distinct items:
SELECT COUNT(DISTINCT order_id) FROM orders;

-- Solution:
SELECT 
    COUNT(*) AS orders_count
FROM
    orders;

-- 2. Are orders actually delivered?
# SELECT DISTINCT order_status FROM orders;
SELECT order_status, COUNT(*) 
FROM orders
GROUP BY order_status;

-- Solution
SELECT 
    order_status, 
    COUNT(*) AS orders
FROM
    orders
GROUP BY order_status;


-- 3. Is Magist having user growth? check for the number of orders grouped by year and month. 
-- Tip: you can use the functions YEAR() and MONTH() to separate the year and the month of the order_purchase_timestamp.
# only order by year: YES THERE IS GROWTH GIVEN THAT THE NUMBER OF ORDERS INCREASED EACH YEAR
SELECT 
	YEAR(order_purchase_timestamp) as year, 
	COUNT(customer_id)
FROM orders
GROUP BY year
ORDER BY year;

# Order by month and year: 
SELECT 
	YEAR(order_purchase_timestamp) as year, 
	MONTH(order_purchase_timestamp) as month, 
	COUNT(customer_id)
FROM orders
GROUP BY year, month
ORDER BY year, month;

-- Solution:
SELECT 
    YEAR(order_purchase_timestamp) AS year_,
    MONTH(order_purchase_timestamp) AS month_,
    COUNT(customer_id)
FROM
    orders
GROUP BY year_ , month_
ORDER BY year_ , month_;

-- 4. How many products are there in the products table? (Make sure that there are no duplicate products.)
# both of these commands return the same result given that product_id is unique
SELECT COUNT(product_id) FROM products; # 32951
SELECT COUNT(DISTINCT product_id) FROM products; # 32951


-- 5. Which are the categories with most products?  # HERE THINK ABOUT COMBINING THE TABLE WITH TRANSLATIONS
SELECT product_category_name, COUNT(DISTINCT product_id)
FROM products
GROUP BY  product_category_name
ORDER BY COUNT(product_id) DESC
LIMIT 10;

-- 6. How many of those products were present in actual transactions? 
-- The products table is a “reference” of all the available products. 
-- Have all these products been involved in orders? Check out the order_items table to find out!
SELECT COUNT(DISTINCT product_id) AS n_products FROM order_items; # 32951


-- 7. What’s the price for the most expensive and cheapest products? Sometimes, having a basing range of prices is informative. 
-- Looking for the maximum and minimum values is also a good way to detect extreme outliers).

SELECT 
    MIN(price) AS cheapest, 
    MAX(price) AS most_expensive
FROM 
	order_items;

-- 8. What are the highest and lowest payment values? Some orders contain multiple products. 
-- What’s the highest someone has paid for an order? Look at the order_payments table and try to find it out.
SELECT 
	MAX(payment_value) as highest,
    MIN(payment_value) as lowest
FROM
	order_payments;

