UPDATE coffee_shop 
SET 
    transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

alter table coffee_shop
modify column transaction_date date;

describe coffee_shop;

UPDATE coffee_shop 
SET 
    transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

alter table coffee_shop
modify column transaction_time time;

-- Calculate the TOTAL SALES for each respective month

SELECT 
    MONTHNAME(transaction_date)
FROM
    coffee_shop;

alter table coffee_shop add column Month_Name varchar(255);


UPDATE coffee_shop 
SET 
    Month_Name = MONTHNAME(transaction_date);

SELECT 
    (ROUND(SUM(transaction_qty * unit_price), 2)) AS 'Total Sales'
FROM
    coffee_shop
WHERE
    month_name = 'May';

-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
with monthly_sales as (
select Month(transaction_date) as "Month_Number", c.Month_Name, round
(sum(transaction_qty * unit_price),2) as "total_sales"
 from coffee_shop c
 where month_name in ("April", "May")
  group by Month(transaction_date), c.Month_Name
 ),
 Previous_Month_Sales as (
 select m.Month_Name, m.total_sales, lag(m.total_sales,1,m.total_sales) over(order by m.Month_Number) as 
 "previous_month_sale"
 from monthly_sales m
)
select pre.month_name,pre.total_sales, round((pre.total_sales - pre.previous_month_sale) * 100 / pre.previous_month_sale,2) as "MoM_Growth"

  from Previous_Month_Sales pre;
  -- Calculate the total number of orders for each respective month.
SELECT 
    COUNT(*)
FROM
    coffee_shop
WHERE
    Month_Name = 'March';
-- TOTAL Orders KPI - MOM DIFFERENCE AND MOM GROWTH

with monthly_orders as (
select month(transaction_date) as "Month_Number", c.month_name, count(c.transaction_id) as "Total_Orders"
from coffee_shop c
where month_name in ("April", "May")
group by c.month_name, month(transaction_date)
),
previous_month_orders as (
select mo.month_name, mo.total_orders, lag(mo.total_orders,1,mo.total_orders) 
over(order by mo.month_number) as "pre_month_orders"
 from monthly_orders mo
)
select pmo.month_name, pmo.total_orders, round((pmo.total_orders - pmo.pre_month_orders) * 100 / pmo.pre_month_orders,2) as  "Mom_Orders" from previous_month_orders pmo;

-- Calculate the total quantity for each respective month.

SELECT 
    SUM(transaction_qty) 'Total_Sold_Quantity'
FROM
    coffee_shop
WHERE
    month_name = 'May'; -- May Month

--  TOTAL Quantity KPI - MOM DIFFERENCE AND MOM GROWTH

with monthly_quantity as (
select month(transaction_date) as "Month_Number", c.month_name, sum(c.transaction_qty) as "Total_Quantity"
from coffee_shop c
where month_name in ("April", "May")
group by c.month_name, month(transaction_date)
),
previous_month_quantity as (
select mo.month_name, mo.total_quantity, lag(mo.total_quantity,1,mo.total_quantity) 
over(order by mo.month_number) as "pre_month_quantity"
 from monthly_quantity mo
)
select pmo.month_name, pmo.total_quantity, round((pmo.total_quantity - pmo.pre_month_quantity) * 100 / pmo.pre_month_quantity,2) as  "Mom_Quantity" from previous_month_quantity pmo;

-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS

SELECT 
    ROUND(SUM(unit_price * transaction_qty), 2) AS 'total_sales',
    SUM(transaction_qty) AS 'total_quantity_sold',
    COUNT(transaction_id) AS 'total_orders'
FROM
    coffee_shop
WHERE
    (transaction_date) = '2023-05-18'

-- Segmet Sales data into weekdays and weekends to analyize perfomance variation
-- Sun - 1
-- Mon - 2
-- .
-- .
-- Sat = 7

SELECT 
    CASE
        WHEN DAYOFWEEK(transaction_date) IN (1 , 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000,
                    2),
            ' ',
            'k') AS 'totak_sales'
FROM
    coffee_shop
WHERE
    Month_Name = 'May'
GROUP BY CASE
    WHEN DAYOFWEEK(transaction_date) IN (1 , 7) THEN 'Weekends'
    ELSE 'Weekdays'
END
-- Calulate the sales of store location with respective month
select store_location, concat(round(sum(unit_price * transaction_qty)/1000,2)," ", "k") as 
"Tot_St_Lc_Sales" from coffee_shop
where month_name = "January"
group by store_location
order by Tot_St_Lc_Sales desc;

--  Average sales for selected month
SELECT 
    CONCAT(ROUND(AVG(total_sales) / 1000, 2),
            ' ',
            'k') AS 'Avg_Sales'
FROM
    (SELECT 
        SUM(unit_price * transaction_qty) AS 'total_sales'
    FROM
        coffee_shop
    WHERE
        month_name = 'May'
    GROUP BY transaction_date) AS daily_sale
-- Calculate total sales with respective month

select day(c.transaction_date) as "Day", concat(round(sum(c.unit_price * c.transaction_qty),2), " " ,"k")  as  "total_daily_sales" from coffee_shop c
where c.month_name = "January"
group by  day(c.transaction_date)
order by day(c.transaction_date);

-- Total Product Category Sales with respective of month.

SELECT 
    c.product_category,
    CONCAT(ROUND(SUM(c.unit_price * c.transaction_qty), 2),
            ' ',
            'k') AS 'Total_Product_Sales'
FROM
    coffee_shop c
WHERE
    month_name = 'June'
GROUP BY c.product_category
ORDER BY SUM(c.unit_price * c.transaction_qty) DESC
 -- calculate the top 10 product sales
 
SELECT 
    c.product_type,
    CONCAT(ROUND(SUM(c.unit_price * c.transaction_qty), 2),
            ' ',
            'k') AS 'total_sales'
FROM
    coffee_shop c
WHERE
    c.Month_Name = 'March'
        AND c.product_category = 'Tea'
GROUP BY c.product_type
ORDER BY SUM(c.unit_price * c.transaction_qty) DESC
LIMIT 10
 
 
 -- Calculate the sales pattern by days and hours
 
SELECT 
    CONCAT(ROUND(SUM(c.unit_price * c.transaction_qty), 2),
            ' ',
            'k') AS 'total_sales',
    SUM(c.transaction_qty) AS 'total_quantity'
FROM
    coffee_shop c
WHERE
    c.Month_Name = 'April'
        AND DAYOFWEEK(c.transaction_date) = 3
        AND HOUR(c.transaction_time) = 13
 
 -- calculate the total_sales by per hour
 
SELECT 
    HOUR(transaction_time),
    CONCAT(ROUND(SUM(c.unit_price * c.transaction_qty), 2),
            ' ',
            'k') AS 'total_sales'
FROM
    coffee_shop c
WHERE
    c.Month_Name = 'May'
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time)
 -- Calculate the total sales from Monday to Sunday with month.
 
SELECT 
    CASE
        WHEN DAYOFWEEK(c.transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(c.transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(c.transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(c.transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(c.transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(c.transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS 'Week_Name',
    CONCAT(ROUND(SUM(c.unit_price * c.transaction_qty), 2),
            ' ',
            'k') AS 'total_sales'
FROM
    coffee_shop c
WHERE
    c.Month_Name = 'April'
GROUP BY CASE
    WHEN DAYOFWEEK(c.transaction_date) = 2 THEN 'Monday'
    WHEN DAYOFWEEK(c.transaction_date) = 3 THEN 'Tuesday'
    WHEN DAYOFWEEK(c.transaction_date) = 4 THEN 'Wednesday'
    WHEN DAYOFWEEK(c.transaction_date) = 5 THEN 'Thursday'
    WHEN DAYOFWEEK(c.transaction_date) = 6 THEN 'Friday'
    WHEN DAYOFWEEK(c.transaction_date) = 7 THEN 'Saturday'
    ELSE 'Sunday'
END

 
 





