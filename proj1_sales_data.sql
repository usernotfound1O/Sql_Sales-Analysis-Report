show databases;
create database walmartsales;
show databases;
use walmartsales;

drop table walmart;

create table walmart(
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(10, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(30) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(10, 4),
    rating FLOAT(2, 1)
);

-- 1>Data Wrangling or Data Cleaning:
-- (could not be retrieved as we have inserted the datatype "NOT NULL" beside every column_name possible)

select * from walmart;

-- 2>Feature Engineering:
-- (i)add new column 'time_of_day' to give insight of sales in the Morning, Afternoon and Evening

select time,
(case
when `time` between "00:00:00" and "12:00:00" then "Morning"
when `time` between "12:01:00" and "16:00:00" then "Afternoon"
else "Evening"
end) as time_of_date
from walmart;

alter table walmart add column time_of_day VARCHAR(30);

update walmart
set time_of_day =(
case
when `time` between "00:00:00" and "12:00:00" then "Morning"
when `time` between "12:01:00" and "16:00:00" then "Afternoon"
else "Evening"
end);

-- (ii)Add column 'day_name' that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri)

select date,
DAYNAME(date)
from walmart;

alter table walmart add column day_name VARCHAR(30);

update walmart
set day_name = DAYNAME(date);

-- (iii)Add column 'month_name' that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar)

select date,
MONTHNAME(date)
from walmart;

alter table walmart add column month_name VARCHAR(30);

update walmart
set month_name = MONTHNAME(date);

##Business Questions
-- (A)Generic Question:
-- i>How many unique cities does the data have?

select distinct city from walmart;

-- ii>In which city is each branch?

select distinct city, branch
from walmart;

-- (B)Product:
-- 1. How many unique product lines does the data have?

 select distinct product_line from walmart;
 
 
 -- 2. What is the most common payment method?
 
 select distinct payment,
 count(payment) as numbers
 from walmart
 group by payment;
 
 -- 3. What is the most selling product line?
 
select sum(quantity) as qty, product_line
from walmart
group by product_line
order by qty desc;
 
 -- 4. What is the total revenue by month?
 
select month_name as month,
sum(total) as total_revenue
from walmart
group by month_name
order by total_revenue;

-- 5. What month had the largest COGS?
 
select month_name as month,
sum(cogs) as total_cogs
from walmart
group by month_name
order by total_cogs;

-- 6. What product line had the largest revenue?
 
select distinct product_line as productline,
sum(total) as revenue
from walmart
group by product_line
order by revenue desc;

 -- 7. What is the city with the largest revenue?
 
select distinct city as unique_city,
sum(total) as revenue
from walmart
group by unique_city
order by revenue desc;
 
-- 8. What product line had the largest VAT?

select distinct product_line,
avg(tax_pct) as vat
from walmart
group by product_line
order by vat desc;

 -- 9. Fetch each product line and add a column to those product line showing "Good", "Bad".
 -- Good if its greater than average sales
 
select avg(quantity) as avg_qnty
from walmart;

select product_line,
(case
when avg(quantity) > (select avg(quantity) from walmart) then "Good"
else "Bad"
end) as remark
from walmart
group by product_line;
 
 -- 10. Which branch sold more products than average product sold?
 
select branch, 
sum(quantity) as qnty
from walmart
group by branch
having sum(quantity) > (select avg(quantity) from walmart);

-- 11. What is the most common product line by gender?

select gender, product_line,
count(gender) as total_cnt
from walmart
group by product_line, gender
order by total_cnt desc;

-- 12. What is the average rating of each product line?

select avg(rating) as avg_rating, product_line
from walmart
group by product_line
order by avg_rating desc;
 
 
 -- (C)Sales:
 -- i) Number of sales made in each time of the day per weekday?
 
select time_of_day,
count(*) as total_sales
from walmart
where day_name = "Monday"     -- we have to put the name of the day where we want to find the sales ( lets say "Monday")
group by time_of_day
order by total_sales desc;
 
-- ii) Which of the customer types brings the most revenue?

select customer_type,
sum(total) as total_rev
from walmart
group by customer_type
order by total_rev;

-- iii) Which city has the largest tax percent/ VAT (Value Added Tax)?

select distinct city,
avg(tax_pct) as vat
from walmart
group by city 
order by vat desc;

-- iv) Which customer type pays the most in VAT?

select customer_type,
avg(tax_pct) as vat
from walmart
group by customer_type
order by vat desc;

-- (D)Customer:
-- 1> How many unique customer types does the data have?

select distinct customer_type from walmart;

-- 2> How many unique payment methods does the data have?

select distinct payment from walmart;

-- 3> What is the most common customer type?

select customer_type,
count(*) as ct
from walmart
group by customer_type
order by ct desc;

-- 4> Which customer type buys the most?
## practically the same question with different approach

select customer_type,
count(*)
from walmart
group by customer_type;
 
 -- 5> What is the gender of most of the customers?
 
select gender,
count(*) as cnt
from walmart
group by gender
order by cnt desc;
 
 -- 6> What is the gender distribution per branch?
 
select gender,
count(*) as cnt
from walmart
where branch = "A"        -- here we have to give the reqd branch whose gender we want to find out
group by gender
order by cnt desc;
 
 -- 7> Which time of the day do customers give most ratings?
 
 select time_of_day,
 round(avg(rating),3) as most_ratings
 from walmart
 group by time_of_day
 order by most_ratings desc;
 
 -- 8> Which time of the day do customers give most ratings per branch?
 
 select time_of_day,
 round(avg(rating),3) as most_ratings
 from walmart
 where branch = "B"                       -- here we have to give the reqd branch whose ratings we want to find out
 group by time_of_day
 order by most_ratings desc;
 
 -- 9> Which day of the week has the best avg ratings?
 
select day_name,
avg(rating) as avg_rating
from walmart
group by day_name 
order by avg_rating desc;
 
 -- 10> Which day of the week has the best average ratings per branch?
 
select day_name,
avg(rating) as avg_rating
from walmart
where branch = "C"
group by day_name 
order by avg_rating desc;

 
 
 
 
 
 
 
