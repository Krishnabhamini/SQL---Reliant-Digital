/*

-----------------------------------------------------------------------------------------------------------------------------------
                                               Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------

                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
use orders;

select * from online_customer;
-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]
   select 
    concat(
        case 
            when customer_gender = 'M' then 'MR'
            when customer_gender = 'F' then 'MS'
            else ''
        end, ' ', UPPER(customer_fname), ' ', UPPER(customer_lname)
    ) AS full_name,
    customer_email AS customer_email_id,
    customer_creation_date,
    CASE
        WHEN EXTRACT(YEAR FROM customer_creation_date) < 2005 THEN 'CATEGORY A'
        WHEN EXTRACT(YEAR FROM customer_creation_date) >= 2005 AND EXTRACT(YEAR FROM customer_creation_date) < 2011 THEN 'CATEGORY B'
        WHEN EXTRACT(YEAR FROM customer_creation_date) >= 2011 THEN 'CATEGORY C'
    END AS customer_category
FROM 
    online_customer;

-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 
    
select * from product;
select * from order_items;
select o.product_id, p.product_desc, p.product_quantity_avail, p.product_price, (p.product_quantity_avail*p.product_price) as inventory_values,
	case 
		when product_price > 20000 then product_price - (product_price*0.2)
        when product_price > 10000 then product_price - (product_price*0.15)
        when product_price <= 10000 then product_price - (product_price * 0.1)
	end as new_price
from order_items o
join product p 
on p.product_id = o.product_id;

-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]
    select * from product_class;
    select * from product;
   
    SELECT 
    pc.product_class_code,
    pc.product_class_desc AS product_class_description,
    COUNT(p.product_id) AS product_count,
    SUM(p.product_quantity_avail * p.product_price) AS inventory_value
FROM 
    product_class pc
JOIN 
    product p ON pc.product_class_code = p.product_class_code
GROUP BY 
    pc.product_class_code, pc.product_class_desc
HAVING 
    SUM(p.product_quantity_avail * p.product_price) > 100000
ORDER BY 
    inventory_value DESC;


-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
select * from online_customer;
select * from address;
select * from order_header;
select count(order_id), ORDER_STATUS from order_header
group by ORDER_STATUS;
select oc.customer_id, concat(customer_fname, ' ', customer_lname) as full_name, oc.customer_email, oc.customer_phone, a.country
from online_customer oc
join address a 
on oc.address_id = a.address_id
join order_header oh
on oc.customer_id = oh.customer_id
where order_status in ('Cancelled'); 
        
-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
   select * from shipper; 
   select s.shipper_name, a.city, count(oc.customer_id) as number_of_customers_catered_by_shipper, 
   count(oh.order_id) AS number_of_consignments
   from shipper s
   join order_header oh
   on s.SHIPPER_ID = oh.SHIPPER_ID
   join online_customer oc
   on oh.CUSTOMER_ID = oc.CUSTOMER_ID
   join address a
   on oc.ADDRESS_ID = a.ADDRESS_ID
   where
    s.shipper_name = 'DHL' and order_status = 'Shipped'
GROUP BY 
    s.shipper_name, a.city
    order by a.city asc;
   
   -- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
select * from order_items;
select oc.customer_id, concat(oc.customer_fname, ' ', oc.customer_lname) as full_name, sum(oi.product_quantity) as total_quantity,
sum((oi.product_quantity * p.product_price)) as total_value 
from online_customer oc
join order_header oh
on oc.customer_id = oh.customer_id
join order_items oi
on oh.order_id = oi.order_id
join product p 
on oi.product_id = p.product_id
where oh.payment_mode in ('Cash') and oc.customer_lname like 'g%'
group by oc.customer_id, oc.customer_fname, oc.customer_lname;
select payment_mode from order_header
where payment_mode in ('Cash'); 
select customer_lname from online_customer
where customer_lname like 'g%';
    
-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
   select * from carton; 
   select * from product;

WITH CartonDetails AS (
    SELECT LEN * WIDTH * HEIGHT AS CARTON_VOLUME
    FROM carton
    WHERE CARTON_ID = 10
),
OrderVolumes AS (
    SELECT
        oi.ORDER_ID,
        SUM(p.LEN * p.WIDTH * p.HEIGHT * oi.PRODUCT_QUANTITY) AS ORDER_VOLUME
    FROM order_items oi
    JOIN product p ON oi.PRODUCT_ID = p.PRODUCT_ID
    GROUP BY oi.ORDER_ID
)
SELECT
    ov.ORDER_ID,
    ov.ORDER_VOLUME
FROM OrderVolumes ov
JOIN CartonDetails cd ON ov.ORDER_VOLUME <= cd.CARTON_VOLUME
ORDER BY ov.ORDER_VOLUME DESC
limit 1;

-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)
SELECT p.PRODUCT_ID,
       p.PRODUCT_DESC,
       p.PRODUCT_QUANTITY_AVAIL,
       COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) AS QUANTITY_SOLD,
       CASE 
           WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') THEN
               CASE
                   WHEN COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                   WHEN p.PRODUCT_QUANTITY_AVAIL < 0.1 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                   WHEN p.PRODUCT_QUANTITY_AVAIL < 0.5 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                   ELSE 'SUFFICIENT INVENTORY'
               END
           WHEN pc.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
               CASE
                   WHEN COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                   WHEN p.PRODUCT_QUANTITY_AVAIL < 0.2 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                   WHEN p.PRODUCT_QUANTITY_AVAIL < 0.6 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                   ELSE 'SUFFICIENT INVENTORY'
               END
           ELSE
               CASE
                   WHEN COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                   WHEN p.PRODUCT_QUANTITY_AVAIL < 0.3 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                   WHEN p.PRODUCT_QUANTITY_AVAIL < 0.7 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                   ELSE 'SUFFICIENT INVENTORY'
               END
       END AS INVENTORY_STATUS
FROM product p
JOIN product_class pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
LEFT JOIN order_items oi ON p.PRODUCT_ID = oi.PRODUCT_ID
GROUP BY p.PRODUCT_ID, p.PRODUCT_DESC, p.PRODUCT_QUANTITY_AVAIL, pc.PRODUCT_CLASS_DESC;

    
-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
select * from order_items;
select * from product;
select * from order_header;    

SELECT p.PRODUCT_ID,
       p.PRODUCT_DESC,
       SUM(oi.PRODUCT_QUANTITY) AS TOT_QTY
FROM order_items oi
JOIN order_items oi2 ON oi.ORDER_ID = oi2.ORDER_ID AND oi2.PRODUCT_ID = 201
JOIN product p ON oi.PRODUCT_ID = p.PRODUCT_ID
JOIN order_header oh ON oi.ORDER_ID = oh.ORDER_ID
JOIN online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN address a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE oi.PRODUCT_ID <> 201
  AND a.CITY NOT IN ('Bangalore', 'New Delhi')
GROUP BY p.PRODUCT_ID, p.PRODUCT_DESC
ORDER BY TOT_QTY DESC;


-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVEN AND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]
SELECT oh.ORDER_ID,
       oc.CUSTOMER_ID,
       CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS CUSTOMER_FULLNAME,
       SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM order_header oh
JOIN order_items oi ON oh.ORDER_ID = oi.ORDER_ID
JOIN online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN address a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE oh.ORDER_ID % 2 = 0
  AND a.PINCODE NOT LIKE '5%'
GROUP BY oh.ORDER_ID, oc.CUSTOMER_ID, oc.CUSTOMER_FNAME, oc.CUSTOMER_LNAME
ORDER BY oh.ORDER_ID;

