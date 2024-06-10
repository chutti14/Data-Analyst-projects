Use Olist_store_DB;

Select * from olist_sellers_dataset;  		-- 3095 rows
Select * from olist_customers_dataset;  	-- 99441 rows
Select * from olist_products_dataset; 		-- 32951 rows
Select * from product_category_name;  		-- 71 rows
Select * from olist_orders_dataset;  	 	-- 99441 rows
Select * from olist_order_items_dataset;  	-- 112650 rows
Select * from olist_order_reviews_dataset; 	-- 99224 rows 
Select * from olist_order_payments_dataset; -- 103886 rows
Select * from olist_geolocation_dataset; 	-- 1000163 rows


## KPI 1 : Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics

SELECT 	kpi1.day_end, 
		ROUND((kpi1.total_pmt/(Select SUM(payment_value) From olist_order_payments_dataset))*100,2) as payment_value
FROM 
(Select ord.day_end, SUM(pmt.payment_value) as total_pmt From olist_order_payments_Dataset as pmt 
JOIN
(Select Distinct(order_id), 
		CASE WHEN weekday(order_purchase_timestamp) in (5,6) then "Weekend" ELSE "Weekday" END as Day_end 
From olist_orders_dataset) as ord ON ord.order_id = pmt.order_id 
GROUP BY ord.day_end) as kpi1;


## KPI 2 : Number of Orders with review score 5 and payment type as credit card.

SELECT p.payment_type, count(p.order_id) as Total_orders 
FROM olist_order_payments_dataset p 
JOIN olist_order_reviews_dataset r ON p.order_id = r.order_id  
WHERE r.review_score = 5 AND p.payment_type = 'credit_card';


## KPI 3 : Average number of days taken for order_delivered_customer_date for pet_shop

SELECT 	prod.product_category_name, 
		round(avg(datediff(ord.order_delivered_customer_date, ord.order_purchase_timestamp))) as Avg_delivery_days 
FROM olist_orders_dataset ord
JOIN olist_order_items_dataset orditem ON orditem.order_id = ord.order_id
JOIN olist_products_dataset prod ON prod.product_id = orditem.product_id
WHERE prod.product_category_name = "pet_shop";


## KPI 4 : Average price and payment values from customers of sao paulo city

WITH orderItem_Avg As (
	SELECT round(AVG(i.price)) as avg_price
	FROM olist_order_items_dataset i
	JOIN olist_orders_dataset o ON  i.order_id = o.order_id
	JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
	WHERE c.customer_city = 'sao paulo'
)
SELECT (Select avg_price from orderItem_Avg) as Average_price, round(AVG(p.payment_value)) as Average_payment_value
FROM olist_order_payments_dataset p 
JOIN olist_orders_dataset ord ON p.order_id = ord.order_id
JOIN olist_customers_dataset cust ON ord.customer_id = cust.customer_id
WHERE cust.customer_city = 'sao paulo';


## KPI 5 : 
## Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

SELECT 	rew.review_score, 
		round(avg(datediff(ord.order_delivered_customer_date,ord.order_purchase_timestamp)),0) as Avg_Shipping_Days
FROM olist_orders_dataset ord  
JOIN olist_order_reviews_dataset rew ON rew.order_id = ord.order_id
GROUP BY rew.review_score 
ORDER BY rew.review_score;
