USE magist;
-- ------------------------ DATA EXPLORATION QUESTIONS ------------------------ --
-- 1. How many orders are there in the dataset?
SELECT
    COUNT(*) AS nr_orders
FROM
    orders;
-- if you want to count distinct items:
SELECT
	COUNT(DISTINCT order_id) AS orders_count
FROM
	orders;

-- 2. Are orders actually delivered?
SELECT
    order_status, COUNT(order_status) AS number_of_orders
FROM
    orders
GROUP BY order_status;

-- Trends in the userbase
-- 3. Is Magist having user growth? check for the number of orders grouped by year and month.
-- YES THERE IS GROWTH GIVEN THAT THE NUMBER OF ORDERS INCREASED EACH YEAR
SELECT 
	YEAR(order_purchase_timestamp) AS Year,
    MONTH(order_purchase_timestamp) AS Month,
    COUNT(*) AS number_of_orders
FROM orders
GROUP BY Year, Month
ORDER BY Year, Month;

# only order by year
SELECT 
	YEAR(order_purchase_timestamp) AS year,
    COUNT(*) AS nr_orders_per_year
FROM orders
GROUP BY year
ORDER BY year;

-- 4. How many products are there in the products table?
-- (Make sure that there are no duplicate products.) # 32951
SELECT 
	COUNT(DISTINCT(product_id)) AS nr_of_products
FROM products;

-- 5. Which are the categories with most products?
SELECT 
	product_category_name_english as product_category,
    COUNT(DISTINCT(product_id)) AS nr_of_products
FROM 
	products 
JOIN product_category_name_translation as transl 
	ON products.product_category_name = transl.product_category_name
GROUP BY products.product_category_name
ORDER BY nr_of_products DESC;

-- 6. How many of those products were present in actual transactions?
-- The products table is a “reference” of all the available products.
-- Have all these products been involved in orders?
# 32951
SELECT
	COUNT(DISTINCT product_id) AS n_products
FROM
	order_items;

-- 7. What’s the price for the most expensive and cheapest products? 
-- Looking for the maximum and minimum values
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