# Business Questions
USE magist;
# In relation to the products:
-- * What categories of tech products does Magist have?

# TO GET THE PORTUGUESE NAMES:
SELECT DISTINCT(product_category_name)
FROM products
LEFT JOIN product_category_name_translation 
  USING (product_category_name)
WHERE product_category_name_english IN
('audio', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony', 
'security_and_services','signaling_and_security', 'fixed_telephony', 'cds_dvds_musicals', 'consoles_games');

# TO ADD TECH AS A COLUMN TO THE PRODUCTS TABLE
# ALTER TABLE products DROP COLUMN tech;

ALTER TABLE products ADD tech varchar(300) as 
(case
    WHEN product_category_name = 'audio' THEN '1'
    WHEN product_category_name = 'eletronicos' THEN '1'
    WHEN product_category_name = 'informatica_acessorios' THEN '1'
    WHEN product_category_name = 'pc_gamer' THEN '1'
    WHEN product_category_name = 'pcs' THEN '1'
    WHEN product_category_name = 'tablets_impressao_imagem' THEN '1'
    WHEN product_category_name = 'telefonia' THEN '1'
    WHEN product_category_name = 'telefonia_fixa' THEN '1'
    ELSE '0'
  END);

-- * How many products of these tech categories have been sold (within the time window of the database snapshot)? # 15981
SELECT COUNT(p.tech) as nr_tech_products_sold
FROM products as p
INNER JOIN
order_items as oi ON p.product_id = oi.product_id
INNER JOIN 
orders as o ON o.order_id = oi.order_id
WHERE p.tech = '1' AND order_status != "canceled" AND order_status != "unavailable";

# what is the nr of all sold products
# SELECT COUNT(*) AS nr_all_products_sold FROM orders
# JOIN order_items ON orders.order_id = order_items.order_id
# JOIN products ON products.product_id = order_items.product_id
# WHERE order_status != "canceled" AND order_status != "unavailable";

-- * What percentage does that represent from the overall number of products sold? 
-- =(15981*100)/112101 = 17; 
SELECT ROUND(15981 / COUNT(*) * 100 , 2) AS percent_of_sales
FROM order_items;
# 14.15%
	
-- * What’s the average price of the products being sold? 
-- all products - 120
SELECT
     AVG(price) AS average_price
FROM 
    order_items
INNER JOIN 
    orders ON order_items.order_id=orders.order_id
    WHERE order_status != "canceled" AND order_status != "unavailable"; # WHERE order_status = "delivered" 

SELECT AVG(price), p.tech 
FROM orders o
JOIN order_items oi on o.order_id=oi.order_id
JOIN products p on oi.product_id=p.product_id
WHERE order_status != "canceled" AND order_status != "unavailable"
GROUP BY p.tech
ORDER BY p.tech DESC;

-- * Are expensive tech products popular?  ADD price category as a column
# ALTER TABLE order_items DROP COLUMN price_categories;
ALTER TABLE order_items ADD price_categories varchar(300) as 
(CASE
WHEN price <= 500 THEN "cheap"  
WHEN price > 1000 THEN "expensive"
ELSE "mid-range"
END);

SELECT product_type, price_categories, count(price_categories)
FROM order_items oi 
	RIGHT JOIN products p on oi.product_id=p.product_id
	JOIN product_category_name_translation pct on p.product_category_name=pct.product_category_name
WHERE product_type = "tech product"
GROUP BY product_type, price_categories
ORDER BY product_type, count(price_categories) DESC;

SELECT COUNT(order_item_id),
	CASE
		WHEN price < 500 THEN "inexpensive"
		WHEN price < 1000 THEN "expensive"
		ELSE "mid-range"
	END AS price_category
FROM order_items
JOIN orders ON orders.order_id = order_items.order_id
JOIN products ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "eletronicos", "informatica_acessorios", "pc_gamer", "pcs", "tablets_impressao_imagem, telefonia", "telefonia_fixa")
GROUP BY price_category;

-- In relation to the sellers:
-- * How many sellers are there?  # 3095
SELECT COUNT(DISTINCT(seller_id)) FROM sellers;

-- How many Tech sellers are there? : 463
SELECT COUNT(DISTINCT(oi.seller_id)) 
FROM sellers as s 
JOIN order_items AS oi ON s.seller_id = oi.seller_id
JOIN products as p ON oi.product_id = p.product_id
WHERE p.tech = '1';

-- What percentage of overall sellers are Tech sellers?
-- (648 * 100) / 3095 = 20

-- * What is the total amount earned by all sellers and amount earned by tech sellers?
# all sellers: 
SELECT ROUND(SUM(oi.price), 2) AS total_revenue
FROM sellers as s 
JOIN order_items AS oi ON s.seller_id = oi.seller_id
JOIN products as p ON oi.product_id = p.product_id;

SELECT ROUND(SUM(oi.price), 2) AS total_revenue
FROM  order_items as oi
JOIN orders as o ON o.order_id = oi.order_id
WHERE  o.order_status NOT IN ("unavailable", "canceled");

# tech sellers
SELECT ROUND(SUM(oi.price), 2) AS tech_revenue
FROM sellers as s 
JOIN order_items AS oi ON s.seller_id = oi.seller_id
JOIN products as p ON oi.product_id = p.product_id
WHERE p.tech = '1';

-- * What is the avg monthly income of all sellers and the tech sellers?
SELECT MONTH(order_purchase_timestamp), YEAR(order_purchase_timestamp)
FROM orders o
LEFT JOIN order_items oi ON o.order_id=oi.order_id
LEFT JOIN products p ON oi.product_id=p.product_id
LEFT JOIN product_category_name_translation pct ON p.product_category_name=pct.product_category_name
WHERE order_status != "canceled" AND order_status != "unavailable"
GROUP BY YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp) DESC;

-- all sellers: '13494400.74' / 25 = 562,266.6975
-- tech sellers: '2359716.8' / 25 = 983,21.53333

-- In relation to the delivery time:
-- * What’s the average time between the order being placed and the product being delivered?
SELECT AVG(TIMESTAMPDIFF(day, order_purchase_timestamp, order_delivered_customer_date))
FROM  orders;
    
-- * How many orders are delivered on time vs orders delivered with a delay?
-- All: 96478
-- On time:  89805, 93% of all
-- Delayed:  6665 7% of all

# All
SELECT COUNT(*) AS all_delivered
FROM orders
WHERE order_status = "delivered";

# On time
SELECT COUNT(*) AS delivered_on_time
FROM orders
WHERE datediff(order_delivered_customer_date, order_estimated_delivery_date) <= 0
		AND order_status = "delivered";

# Delayed
SELECT COUNT(*) AS delivered_late
FROM orders
WHERE datediff(order_delivered_customer_date, order_estimated_delivery_date) > 0
		AND order_status = "delivered";

-- * Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT *
FROM orders
WHERE datediff(order_delivered_customer_date, order_estimated_delivery_date) > 0
		AND order_status = "delivered";

# add a new column for delivery time status
ALTER TABLE orders ADD deliv_time_status varchar(300) as 
(CASE
    WHEN datediff(order_delivered_customer_date, order_estimated_delivery_date) <= 0 THEN 'on_time'
    WHEN datediff(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 'delayed'
    ELSE '0'
  END);

# calculate avg product weight, length, height and widht based on  based on delivery time status

# all
SELECT AVG(p.product_weight_g), AVG(p.product_length_cm), AVG(p.product_height_cm), AVG(p.product_width_cm)
FROM products as p
INNER JOIN
order_items as oi ON p.product_id = oi.product_id
INNER JOIN 
orders as o ON o.order_id = oi.order_id AND p.tech = '1';

# delayed:
SELECT AVG(p.product_weight_g), AVG(p.product_length_cm), AVG(p.product_height_cm), AVG(p.product_width_cm), COUNT(*)
FROM products as p
INNER JOIN
order_items as oi ON p.product_id = oi.product_id
INNER JOIN 
orders as o ON o.order_id = oi.order_id
WHERE o.deliv_time_status = "delayed";

# on time
SELECT AVG(p.product_weight_g), AVG(p.product_length_cm), AVG(p.product_height_cm), AVG(p.product_width_cm)
FROM products as p
INNER JOIN
order_items as oi ON p.product_id = oi.product_id
INNER JOIN 
orders as o ON o.order_id = oi.order_id
WHERE o.deliv_time_status = "on_time" AND p.tech = '1';