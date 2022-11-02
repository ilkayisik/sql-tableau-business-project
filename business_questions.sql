
-- ------------------------ BUSINESS QUESTIONS ------------------------ --

-- 1. What categories of tech products does Magist have?
SELECT product_category_name_english
FROM product_category_name_translation;

-- Created list of categories considered as "tech_categories": 
-- ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", 
--  "telephony", "fixed_telephony")
SELECT product_category_name_english AS tech_categories
FROM product_category_name_translation
WHERE product_category_name_english 
	IN ("audio", "electronics", 
		"computers_accessories", 
		"pc_gamer", "computers", 
		"tablets_printing_image", 
		"telephony", "fixed_telephony");


-- 2. HOW MANY OF THESE TECH PRODUCTS HAVE BEEN SOLD (WITHIN THE TIME WINDOW OF THE DATABASE SNAPSHOT)?
# 11371 tech products sold within 25 months
                            
SELECT product_category_name_english AS product_category,
    COUNT(order_items.order_id) AS sales
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
JOIN products ON order_items.product_id = products.product_id
JOIN product_category_name_translation as transl
	ON products.product_category_name = transl.product_category_name
WHERE product_category_name_english 
	IN ("audio", "electronics", 
		"computers_accessories", 
		"pc_gamer", "computers", 
		"tablets_printing_image", 
		"telephony", "fixed_telephony")
GROUP BY product_category_name_english
ORDER BY sales DESC;
                            
# WHAT PERCENT DOES THAT REPRESENT FROM THE OVERALL NUMBER OF PRODUCTS SOLD?
SELECT 
    COUNT(order_items.order_id) AS tech_products_sold,
    total_products_sold,
    ROUND(((COUNT(*)) / total_products_sold) * 100, 2) AS percentage_of_total
FROM 
(SELECT
		COUNT(order_id) AS total_products_sold
	FROM order_items
    ) AS total_products_sold,
    orders
JOIN order_items 
	ON orders.order_id = order_items.order_id
JOIN products
	ON order_items.product_id = products.product_id
JOIN product_category_name_translation AS transl
	ON products.product_category_name = transl.product_category_name
WHERE product_category_name_english 
	IN ("audio", "electronics", 
		"computers_accessories", 
		"pc_gamer", "computers", 
		"tablets_printing_image", 
		"telephony", "fixed_telephony");
        
-- 3. * What’s the average price of the products being sold?
-- all products - 120

SELECT
     ROUND(AVG(price),2) AS average_price
FROM
    order_items
INNER JOIN
    orders ON order_items.order_id = orders.order_id
    WHERE order_status != "canceled" AND order_status != "unavailable"; # WHERE order_status = "delivered";

-- Avg tech products: 123, Eniac avg = 540
SELECT
	MIN(price), MAX(price), ROUND(AVG(price), 2)
FROM
	order_items
JOIN
    products ON order_items.product_id = products.product_id
WHERE product_category_name IN ("audio", "eletronicos", "informatica_acessorios",
								"pc_gamer", "pcs", "tablets_impressao_imagem",
                                "telefonia", "telefonia_fixa");

-- 4. * Are expensive tech products popular?: NOT REALLY
SELECT
	COUNT(order_item_id), #product_category_name,
CASE
	WHEN price < 500 THEN "cheap"
	WHEN price < 1000 THEN "expensive"
	ELSE "mid-range"
	END AS price_category
FROM
	order_items
JOIN
    orders ON orders.order_id = order_items.order_id
JOIN
    products ON order_items.product_id = products.product_id
WHERE
	products.product_category_name IN ("audio", "eletronicos", "informatica_acessorios",
									   "pc_gamer", "pcs", "tablets_impressao_imagem",
									   "telefonia", "telefonia_fixa")
GROUP BY
	price_category; #,product_category_name


-- 5. * How many moths of data are included in the Magist Database?: # 25 months
SELECT
	TIMESTAMPDIFF(MONTH, MIN(DATE(order_purchase_timestamp)), MAX(DATE(order_purchase_timestamp))) AS number_of_months
FROM
	orders;

# Business Questions in relation to the sellers:
-- 5. * How many sellers are there?  # 3095
SELECT
	COUNT(DISTINCT(seller_id))
FROM
	sellers;

-- 6. * How many Tech sellers are there? : 463
SELECT
	COUNT(DISTINCT sellers.seller_id)
FROM
	sellers
JOIN
    order_items ON sellers.seller_id = order_items.seller_id
JOIN
    products ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "eletronicos", "informatica_acessorios",
									    "pc_gamer", "pcs", "tablets_impressao_imagem",
									    "telefonia", "telefonia_fixa");
# What percent are tech sellers?
SELECT
	ROUND(400 / COUNT(DISTINCT seller_id), 2) AS percent_of_tech_sellers
FROM
	sellers;

-- 7. * What is the total amount earned by all sellers and amount earned by tech sellers?
# all sellers:  13494400
SELECT
	ROUND(SUM(oi.price), 2) AS total_revenue
FROM
	sellers as s
JOIN
	order_items AS oi ON s.seller_id = oi.seller_id
JOIN
	products as p ON oi.product_id = p.product_id
JOIN
	orders as o ON oi.order_id = o.order_id
AND order_status != "canceled" AND order_status != "unavailable";

# TECH SELLERS: 1724035
SELECT
	ROUND(SUM(price),2) AS total_tech_revenue
FROM
	orders as o
JOIN
	order_items as oi ON o.order_id = oi.order_id
JOIN
	products as p ON oi.product_id = p.product_id
WHERE order_status != "canceled" AND order_status != "unavailable" AND p.product_category_name IN ("audio", "eletronicos", "informatica_acessorios",
																									"pc_gamer", "pcs", "tablets_impressao_imagem",
                                                                                                    "telefonia", "telefonia_fixa");

-- 8. * What is the avg monthly income of all sellers and the tech sellers?
-- all sellers: 13494400 / 25 = 539.776
-- tech sellers: 1724035 / 25 = 68.961

# In relation to the delivery time:

-- 9. * How many orders are delivered on time vs orders delivered with a delay?
-- All: 96478
SELECT
	COUNT(*) AS all_delivered
FROM
	orders
WHERE
	order_status = "delivered";

-- On time:  89805, 93% of all
SELECT
	COUNT(*) AS delivered_on_time
FROM
	orders
WHERE
	datediff(order_delivered_customer_date, order_estimated_delivery_date) <= 0 AND order_status = "delivered";

-- Delayed:  6665 7% of all
SELECT
	COUNT(*) AS delivered_late
FROM
	orders
WHERE
	datediff(order_delivered_customer_date, order_estimated_delivery_date) > 0 AND order_status = "delivered";

-- 10. * Is there any pattern for delayed orders, e.g. big products being delayed more often? : No pattern based on weight
SELECT
	*
FROM
	orders
WHERE datediff(order_delivered_customer_date, order_estimated_delivery_date) > 0 AND order_status = "delivered";

# add a new column for delivery time status
ALTER TABLE orders ADD deliv_time_status varchar(300) as
(CASE
    WHEN datediff(order_delivered_customer_date, order_estimated_delivery_date) <= 0 THEN 'on_time'
    WHEN datediff(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 'delayed'
    ELSE '0'
  END);

  # calculate avg product weight, length, height and widht based on delivery time status for all products
SELECT
	AVG(p.product_weight_g), AVG(p.product_length_cm), AVG(p.product_height_cm), AVG(p.product_width_cm)
FROM
	products as p
INNER JOIN
	order_items as oi ON p.product_id = oi.product_id
INNER JOIN
	orders as o ON o.order_id = oi.order_id
WHERE order_status != "canceled" AND order_status != "unavailable"
AND p.product_category_name IN ("audio", "eletronicos", "informatica_acessorios",
								"pc_gamer", "pcs", "tablets_impressao_imagem",
								"telefonia", "telefonia_fixa");

# delayed
SELECT
	AVG(p.product_weight_g), AVG(p.product_length_cm), AVG(p.product_height_cm), AVG(p.product_width_cm)
FROM
	products as p
INNER JOIN
	order_items as oi ON p.product_id = oi.product_id
INNER JOIN
	orders as o ON o.order_id = oi.order_id
WHERE order_status != "canceled" AND order_status != "unavailable"
AND p.product_category_name IN ("audio", "eletronicos", "informatica_acessorios",
								"pc_gamer", "pcs", "tablets_impressao_imagem",
								"telefonia", "telefonia_fixa")
AND o.deliv_time_status = "delayed";

# on time
SELECT
	AVG(p.product_weight_g), AVG(p.product_length_cm), AVG(p.product_height_cm), AVG(p.product_width_cm)
FROM
	products as p
INNER JOIN
	order_items as oi ON p.product_id = oi.product_id
INNER JOIN
	orders as o ON o.order_id = oi.order_id
WHERE order_status != "canceled" AND order_status != "unavailable"
AND p.product_category_name IN ("audio", "eletronicos", "informatica_acessorios",
								"pc_gamer", "pcs", "tablets_impressao_imagem",
								"telefonia", "telefonia_fixa")
AND o.deliv_time_status = "on_time";
