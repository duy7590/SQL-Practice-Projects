--Data Analysis Project for Retail: Sales Performance Report Using SQL
--This project provided by DQLab, here was given the dataset contains the 
--transactions report from 2009 until 2012 consist 5500 rows, which is the 
--order status field has the value ‘Order Finished’, ‘Order Returned’ and ‘Order Cancelled’.



--PREPROCESSING STEPS: Convert the sales date into shorter format
ALTER TABLE PortfolioProject..SalesRetail
Add OrderDateConverted Date

Update PortfolioProject..SalesRetail --> Set the collumn with converted saleDate
SET OrderDateConverted = CONVERT(Date,order_date)

ALTER TABLE PortfolioProject..SalesRetail
DROP COLUMN order_date



--BUSINESS QUESTIONS NEED TO BE ANSWERED
--Through the data has given, the manager of DQLab Store wants to know :
--1/ Order numbers and total sales from 2009 until 2012 which order status is finished
--2/ Total sales for each sub-category of product on 2011 and 2012
--3/ The effectiveness and efficiency of promotions carried out so far, by calculating the burn rate of the overall promotions by year
--4/ The effectiveness and efficiency of promotions carried out so far, by calculating the burn rate of the overall promotions by sub-category of product on 2012
--5/ The number of customers transactions for each year
--6/ The number of new customers for each year


--1/ ORDER NUMBERS AND TOTAL SALES FROM 2009 UNTIL 2012 WHICH ORDER STATUS IS FINISHED
-------------------------------------------------------------------------------------------
SELECT Year(OrderDateConverted), count(order_id) AS 'Number of Orders', sum(sales) AS 'Total Sales'
FROM PortfolioProject..SalesRetail
WHERE order_status LIKE 'Order Finished'
GROUP BY Year(OrderDateConverted)

--Comment: We can see, total sales of DQLab store are changed over the year. The highest 
--total sales were in 2009 and it doesn’t get higher after that. But different from the number 
--of order, it goes ride except in 2011. Although the change isn’t too significant over the years.



 
 --2/ TOTAL SALES FOR EACH SUB-CATEGORY OF PRODUCT ON 2011 AND 2012
 -------------------------------------------------------------------------------------------
SELECT product_sub_category, sum(sales) AS 'Total Sales'
FROM PortfolioProject..SalesRetail
WHERE (Year(OrderDateConverted) = 2011 OR Year(OrderDateConverted) = 2012 ) AND order_status = 'Order Finished'
GROUP BY product_sub_category
ORDER BY 2 DESC;


--note: Here we practice using SUM with Conditions and create a temporary dataset with 2 
--collums of sales 2011 and sales 2012 from where we calculate the growth of sales (%)
SELECT *,
       ROUND((sales2012-sales2011)*100/sales2012, 1) 'growth sales (%)'
FROM(
     SELECT product_sub_category,
	 		SUM(CASE WHEN YEAR(OrderDateConverted) = 2011 THEN sales END) AS sales2011,
			SUM(CASE WHEN YEAR(OrderDateConverted) = 2012 THEN sales END) AS sales2012
     FROM PortfolioProject..SalesRetail
     WHERE order_status = 'Order Finished'
     GROUP BY product_sub_category
    ) sub_category
ORDER BY 4 DESC;
--Comment: Most the growth sales are lead the increases, shown by a positive value. 
--But there are some sub-category products that got a decline in sales from 2011 to 
--2012 which shown by a negative value. Labels, Copiers & Fax and tables are the 
--categories that got a decline in sales the most.





--3/ THE EFFECTIVENESS AND EFFICIENCY OF PROMOTIONS CARRIED OUT SO FAR, BY CALCULATING 
--THE BURN RATE OF THE OVERALL PROMOTIONS BY YEAR
-------------------------------------------------------------------------------------------

--Note: Total burn rate = total discount / total sales
SELECT *, 
	ROUND((promotion_value/sales)*100,1) AS 'Burn_rate_(%)'
FROM(
	SELECT YEAR(OrderDateConverted) AS 'Year', SUM(sales) AS 'sales', SUM(discount_value) AS 'promotion_value'
	FROM PortfolioProject..SalesRetail
    WHERE order_status = 'Order Finished'
    GROUP BY YEAR(OrderDateConverted)	
	) AS sub_table
ORDER BY 1 ASC;

--Comment: The results says that burn rates are above 4.5% for each year as overall. 
--Moreover, it tends to increase every year. This indicates that the promotions have been 
--carried out haven’t been able to reduce the burn rate to a maximum of 4.5%.




--4/ THE EFFECTIVENESS AND EFFICIENCY OF PROMOTIONS CARRIED OUT SO FAR, BY CALCULATING THE 
--BURN RATE OF THE OVERALL PROMOTIONS BY SUB-CATEGORY OF PRODUCT ON 2012
-------------------------------------------------------------------------------------------


SELECT *, 
	ROUND((promotion_value/sales)*100,1) AS 'Burn_rate_(%)'
FROM(
	SELECT product_category, product_sub_category,
		SUM(sales) AS 'sales', 
		SUM(discount_value) AS 'promotion_value'
	FROM PortfolioProject..SalesRetail
    WHERE YEAR(OrderDateConverted) = 2012
    GROUP BY product_category, product_sub_category
	) AS sub_table
ORDER BY 5 ASC;


--Comment:  Promotion Effectiveness and Efficiency by Product Sub-Category
-- There are 5 sub-category of product that have the burn rate bellow 4.5 %
-- Most of them have quite poor Promotion Effectiveness and Efficiency 



--5/ THE NUMBER OF CUSTOMERS TRANSACTIONS FOR EACH YEAR
-------------------------------------------------------------------------------------------
SELECT YEAR(OrderDateConverted) AS 'years',
       COUNT(DISTINCT customer) 'number of customer'
FROM PortfolioProject..SalesRetail
WHERE order_status = 'Order Finished'
GROUP BY YEAR(OrderDateConverted) ;

--Comment: The number of customers isn’t changing significantly overall. 
--It has been stable customer base for 4 years 
--number of customers tends to be in the values ​​around 580–590.



--6/ THE NUMBER OF NEW CUSTOMERS FOR EACH YEAR
-------------------------------------------------------------------------------------------
SELECT YEAR(first_order) AS 'years', COUNT(customer) AS 'new customers'
FROM
	(
	SELECT customer, MIN(OrderDateConverted) AS first_order
	FROM PortfolioProject..SalesRetail
	WHERE order_status = 'Order Finished'
	GROUP BY customer 
	) AS sub_table
GROUP BY YEAR(first_order);

--Comment:The customer base grew significantly in first 2 year
-- However, The growth rate slowed down year after year. 
--It gets extreme in 2012 that only there 11 new customers.