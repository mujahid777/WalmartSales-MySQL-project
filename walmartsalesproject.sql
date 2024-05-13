-- Create the database if it does not exist
CREATE DATABASE IF NOT EXISTS WalmartSales;
USE WalmartSales;

-- Create the Sales table if it does not exist
CREATE TABLE IF NOT EXISTS Sales(
	Invoice_ID VARCHAR(30) NOT NULL, 
	Branch VARCHAR(5) NOT NULL, 
	City VARCHAR(30) NOT NULL, 
	Customer_type VARCHAR(30) NOT NULL, 
	Gender VARCHAR(6) NOT NULL, 
	Product_line VARCHAR(100) NOT NULL, 
	Unit_price DECIMAL(10, 2) NOT NULL, 
	Quantity INT NOT NULL, 
	Tax DECIMAL(6, 4) NOT NULL, 
	Total DECIMAL(12, 4) NOT NULL, 
	Date DATE NOT NULL, 
	Time TIME NOT NULL, -- Changed from DATETIME to TIME for storing time
	Payment_Method VARCHAR(15) NOT NULL, 
	cogs DECIMAL(10, 2) NOT NULL, 
	gross_margin_pct DECIMAL(11, 9) NOT NULL, 
	gross_income DECIMAL(12, 4) NOT NULL, 
	Rating DECIMAL(2, 1) NOT NULL
);

-- Disable strict SQL mode for the current session
SET SESSION sql_mode = '';

-- Load data from a CSV file into the Sales table
LOAD DATA INFILE 'E:\\WalmartSalesData.csv'
INTO TABLE Sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Select all records from the Sales table to verify the data load
SELECT * FROM Sales;

-- Add the time_of_day column

SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;    

ALTER TABLE Sales ADD COLUMN Time_of_day varchar(20);


-- For this to work turn off safe mode for update
-- Edit > Preferences > SQL Edito > scroll down and toggle safe mode
-- Reconnect to MySQL: Query > Reconnect to server

UPDATE sales
SET time_of_day = (CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END);
       
-- Add day_name column

SELECT
      date,
      DAYNAME(date)
from sales;      
SELECT * FROM Sales;

ALTER TABLE Sales ADD COLUMN day_name varchar(12);

UPDATE Sales
SET day_name = DAYNAME(date);

-- Add month_name column

SELECT
      date,
      MONTHNAME(date)
from sales; 

ALTER TABLE Sales ADD COLUMN month_name varchar(12);

UPDATE Sales
SET month_name = MONTHNAME(date);

SELECT * FROM Sales;

----------------------------------------- Generic ---------------------------------------------------

-- How many unique cities does the data have?

SELECT 
      DISTINCT city
from sales;      

-- In which city is each branch?

SELECT 
	DISTINCT city,
    branch
FROM Sales;

---------------------------------------------- Product -----------------------------------------------

-- How many unique product lines does the data have?

SELECT 
      COUNT(DISTINCT product_line)
FROM Sales; 

-- What is the most selling product line    

SELECT 
      SUM(quantity) AS qty,
      product_line
FROM Sales  
GROUP BY product_line
ORDER BY qty DESC;    

-- What is the total revenue by month

SELECT
      sum(total) as total_revenue,
      month_name as month
FROM Sales      
GROUP BY month
ORDER BY total_revenue DESC;      

-- What month had the largest COGS?

SELECT
	month_name AS month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month_name 
ORDER BY cogs;

-- What product line had the largest revenue?

SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?

SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue;

-- What product line had the largest TAX?
SELECT
	product_line,
	AVG(tax) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT
      AVG(quantity) as avg_qnty
FROM Sales;    

SELECT
      product_line,
      case
           when AVG(quantity) > 5.5100 then "Good"
           else "Bad"
      end as remark   
from Sales     
group by product_line; 
        
-- Which branch sold more products than average product sold?

SELECT 
    branch,
    SUM(quantity) AS qty
FROM Sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) AS avg_quantity FROM Sales);
      
-- What is the most common product line by gender

SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line

SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


------------------------------------------- Customers -------------------------------------------------


-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT 
      DISTINCT payment_method
FROM Sales;    

-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter

-- Which time of the day do customers give most ratings per branch?
SELECT
    time_of_day,
    branch,
    AVG(rating) AS avg_rating
FROM sales
WHERE branch IN ("A", "B", "C")
GROUP BY time_of_day, branch
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.

-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?

-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
    branch,
	COUNT(day_name) total_sales
FROM sales
WHERE branch in ("A","B","C")
GROUP BY day_name, branch
ORDER BY total_sales DESC;

--------------------------------------------------- Sales ------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;


-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;