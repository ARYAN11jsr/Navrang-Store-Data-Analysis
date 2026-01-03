--CREATE DATABASE NAVRANGSTORE
select * from Navrang_sales;


--Q1. How many orders are there in total?
SELECT COUNT(ORDER_ID) AS TOTAL_ORDERS
FROM NAVRANG_SALES ;


--Q2. What is the total revenue ?
SELECT SUM(AMOUNT) AS TOTAL_AMOUNT
FROM NAVRANG_SALES ;

--Q3. How many distinct customers have placed orders?
SELECT COUNT(DISTINCT(CUST_ID)) AS TOTAL_CUSTOMERS 
FROM NAVRANG_SALES ;

--Q4. How many orders are placed by each gender?
SELECT GENDER , COUNT(*) AS TOTAL_ORDERS
FROM NAVRANG_SALES
GROUP BY GENDER ;

--Q5. What is the total revenue from each gender?
SELECT GENDER , SUM(AMOUNT) AS TOTAL_AMOUNT
FROM NAVRANG_SALES
GROUP BY GENDER ;

--Q6. What is the average age of customers within each age group?
SELECT AGE_GROUP , ROUND(AVG(AGE),0) AS AVG_AGE FROM NAVRANG_SALES
GROUP BY AGE_GROUP ;

--Q7. How many orders come from each sales channel, sorted from highest to lowest?
SELECT Echannel , count(ORDER_ID) as TOTAL_ORDERS  FROM NAVRANG_SALES
GROUP BY Echannel
ORDER BY TOTAL_ORDERS DESC ;

--Q8. Which 5 cities generated the highest total revenue?
SELECT TOP(5)SHIP_CITY, SUM(AMOUNT) AS TOTAL_AMOUNT  
FROM NAVRANG_SALES
GROUP BY SHIP_CITY
ORDER BY TOTAL_AMOUNT DESC ;

--Q9. What is the total quantity sold for each product category?
SELECT CATEGORY, SUM(QTY) AS TOTAL_QUANTITY  FROM NAVRANG_SALES
GROUP BY CATEGORY
ORDER BY TOTAL_QUANTITY DESC ;

--Q10. What is the average order value?
SELECT ROUND(AVG(AMOUNT),2) AS AVERAGE_ORDER_VALUE
 FROM NAVRANG_SALES ;

--Q11. How many orders are not delivered (any status other than 'Delivered')?
SELECT COUNT(*) AS NON_DELIVERED_ORDERS 
FROM Navrang_sales 
WHERE Status != 'Delivered';

--Q12. What is the total revenue from B2B orders vs non-B2B (B2C) orders?
SELECT SUM(AMOUNT) AS TOTAL_REVENUE,B2B 
FROM Navrang_sales
GROUP BY B2B ;

--Q13. For women customers only, what is the revenue by product category?
SELECT Category, SUM(AMOUNT) AS TOTAL_REVENUE  
FROM Navrang_sales
WHERE Gender = 'WOMEN'
GROUP BY Category
ORDER BY TOTAL_REVENUE DESC;

--Q14. How many orders were placed by senior customers through Amazon?
SELECT COUNT(*) AS SENIOR_AMAZON_ORDERS FROM Navrang_sales
WHERE Echannel  = 'Amazon'
AND Age_Group = 'Senior';

--Q15. What is the total revenue for each month?
SELECT MONTH, SUM(AMOUNT) AS TOTAL_REVENUE FROM Navrang_sales
GROUP BY MONTH
ORDER BY TOTAL_REVENUE DESC;

--Q16. What are the  Top 3 categories on Myntra by revenue.
SELECT TOP(3)  category,
 SUM(amount) AS total_revenue
FROM navrang_sales
WHERE Echannel = 'Myntra'
GROUP BY category
ORDER BY total_revenue DESC
;

--Q17. Which cities have generated more than 50,000 in total revenue?
SELECT ship_city, SUM(AMOUNT) AS TOTAL_REVENUE FROM Navrang_sales
GROUP BY ship_city 
HAVING SUM(AMOUNT) > 50000
ORDER BY TOTAL_REVENUE DESC ;

--Q18. What is the average quantity per order for each category?
SELECT Category,ROUND(AVG(QTY),0) AS AVG_QUANTITY
FROM Navrang_sales
GROUP BY Category 
ORDER BY AVG_QUANTITY DESC ;

--Q19. List all orders whose amount is greater than the overall average order amount.
SELECT ORDER_ID ,CUST_ID,Amount
FROM Navrang_sales
WHERE Amount > (SELECT AVG(AMOUNT) FROM Navrang_sales) ;

--Q20. What percentage of total orders comes from each channel?
SELECT Echannel,
COUNT(*) AS TOTAL_ORDERS,
ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM navrang_sales),2) AS PERCENTAGE_OF_ORDERS
FROM navrang_sales
GROUP BY Echannel
ORDER BY PERCENTAGE_OF_ORDERS DESC;

--Q21. Among kurtas category products, which size is ordered the most?
SELECT SIZE,COUNT(*) as TOTAL_ORDERS
FROM Navrang_sales
WHERE Category ='Kurta'
GROUP BY Size
ORDER BY TOTAL_ORDERS DESC ;

--Q22. What are maximum and minimum customer ages in the dataset?
SELECT MAX(AGE) AS OLDEST_AGE,
MIN(AGE) AS YOUNGEST_AGE
FROM Navrang_sales;

--Q23. For each state how many unique postal codes are there ?
SELECT ship_state,
COUNT(DISTINCT(ship_postal_code)) AS UNIQUE_PINCODES
FROM Navrang_sales
GROUP BY ship_state
ORDER BY UNIQUE_PINCODES DESC;

--Q24.How many orders were placed each month?
SELECT Month(DATE) as MONTH_NUMBER,Month,
COUNT(ORDER_ID) AS TOTAL_ORDERS 
FROM Navrang_sales
GROUP BY Month(DATE),Month
ORDER BY Month(DATE) ASC ;

--Q25.Which category has the highest total revenue?
SELECT TOP(1) Category,
SUM(AMOUNT) AS TOTAL_REVENUE
FROM Navrang_sales
GROUP BY Category
ORDER BY TOTAL_REVENUE DESC;

--Q26.Calculate the cumulative (running) revenue over months.
WITH monthly_revenue AS (
    SELECT 
        YEAR(date)  AS year,
        MONTH(date) AS month_num,
        DATENAME(MONTH, date) AS month_name,
        SUM(amount) AS revenue
    FROM navrang_sales
    GROUP BY YEAR(date), MONTH(date), DATENAME(MONTH, date)
)
SELECT year,
       month_name,
       revenue,
       SUM(revenue) OVER (
           ORDER BY year, month_num
       ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY year, month_num;

--Q27. Rank product categories based on total revenue generated.
WITH category_revenue AS (
    SELECT category,
           SUM(amount) AS total_revenue
    FROM navrang_sales
    GROUP BY category
)
SELECT category,
       total_revenue,
       RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM category_revenue;

--Q28.For each customer, find their highest-value order.
WITH ranked_orders AS (
    SELECT cust_id,
           order_id,
           amount,
           ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY amount DESC) AS rn
    FROM navrang_sales
)
SELECT cust_id,order_id, amount
FROM ranked_orders
WHERE rn = 1;

--Q29. Calculate month-over-month revenue change.
WITH monthly_revenue AS (
    SELECT 
        YEAR(date)  AS year,
        MONTH(date) AS month_num,
        DATENAME(MONTH, date) AS month_name,
        SUM(amount) AS revenue
    FROM navrang_sales
    GROUP BY YEAR(date), MONTH(date), DATENAME(MONTH, date)
)
SELECT year,month_name,revenue,
revenue - LAG(revenue) OVER ( ORDER BY year, month_num) AS mom_change
FROM monthly_revenue
ORDER BY year, month_num;

--Q30. What percentage of total revenue is contributed by each sales channel?
WITH channel_revenue AS (
    SELECT Echannel,
           SUM(amount) AS revenue
    FROM navrang_sales
    GROUP BY Echannel
)
SELECT Echannel,revenue,
ROUND( 100.0 * revenue / SUM(revenue) OVER (),2) AS revenue_percentage
FROM channel_revenue
ORDER BY revenue_percentage DESC;

--Q31.Identify customers who placed more than one order and arrange them in descending order.
WITH customer_orders AS (
    SELECT cust_id,
           COUNT(*) OVER (PARTITION BY cust_id) AS order_count
    FROM navrang_sales
)
SELECT DISTINCT cust_id,order_count
FROM customer_orders
WHERE order_count > 1
ORDER BY order_count DESC;

--Q32.Rank the States and Union Territories by revenue.
WITH state_revenue AS (
    SELECT ship_state,
           SUM(amount) AS revenue
    FROM navrang_sales
    GROUP BY ship_state
)
SELECT ship_state,revenue,
RANK() OVER (ORDER BY revenue DESC) AS state_rank
FROM state_revenue;

--Q33. Compare the Average order value of both genders.
SELECT
GENDER,AVG(AMOUNT) AS GENDER_AOV 
FROM Navrang_sales
GROUP BY Gender ;



