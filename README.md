# Danny's Diner

## Introduction

Danny's Diner is a cozy restaurant specializing in Japanese cuisine, including sushi, curry, and ramen. Since its opening in 2021, Danny has been collecting basic data on customer transactions. However, he needs assistance in utilizing this data to enhance customer experience and optimize business operations.

## Problem Statement

Danny seeks answers to several questions regarding customer behavior and preferences. He wants to understand customer spending patterns, visit frequency, favorite menu items, and the potential expansion of the loyalty program. Additionally, he requires basic datasets for easy data inspection without SQL queries.

Danny has shared with you 3 key datasets for this case study:

sales

menu

members

You can inspect the entity relationship diagram and example data below.

![Danny's Dinner](https://github.com/Azar963/Case-Study-1---Danny-s-Diner/assets/101073959/112bedbd-16d0-4e27-bafc-75d4ebf87bd5)


## Case Study Questions

#### 1. Total Amount Spent: 
Calculate the total amount spent by each customer.
#### 2. Customer Visit Frequency:
Determine the number of days each customer visited the restaurant.
#### 3. First Purchase Item: 
Identify the first item purchased from the menu by each customer.
#### 4. Most Purchased Item: 
Find the most purchased item and its total count.
#### 5. Most Popular Item: 
Determine the most popular item for each customer.
#### 6. First Purchase after Joining: 
Identify the first item purchased by customers after joining the loyalty program.
#### 7. Last Purchase before Joining: 
Determine the item purchased just before customers joined the loyalty program.
#### 8. Pre-Membership Transactions: 
Calculate the total items and amount spent for each member before joining.
#### 9. Points Calculation: 
Calculate the loyalty points earned by each customer.
#### 10. Loyalty Program Points: 
Calculate the points earned by customers A and B at the end of January.

## SQL Queries

### -- 1. Total Amount Spent

    SELECT 
        s.customer_id, 
        SUM(m.price) AS total_amount_spent
    FROM 
        sales s
    JOIN 
        menu m ON s.product_id = m.product_id
    GROUP BY 
        s.customer_id;

### -- 2. Customer Visit Frequency

    SELECT 
        customer_id, 
        COUNT(DISTINCT order_date) AS visit_frequency
    FROM 
        sales
    GROUP BY 
        customer_id
    ORDER BY 
        visit_frequency DESC;

### -- 3. First Purchase Item

    SELECT 
        x.customer_id, 
        x.product_name
    FROM 
        (SELECT 
             customer_id, 
             product_name, 
             ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rank
         FROM 
             sales 
         JOIN 
             menu ON sales.product_id = menu.product_id) x
    WHERE 
        x.rank = 1;

### -- 4. Most Purchased Item

    SELECT 
        m.product_name AS most_purchased_item, 
        SUM(s.product_id) AS total_purchases
    FROM 
        sales s
    JOIN 
        menu m ON m.product_id = s.product_id
    GROUP BY 
        product_name
    ORDER BY 
        total_purchases DESC
    LIMIT 1;

### -- 5. Most Popular Item for Each Customer

    SELECT 
        x.customer_id, 
        x.product_name AS most_popular_item,
        x.total_purchases
    FROM 
        (SELECT 
             customer_id, 
             product_name, 
             COUNT(*) AS total_purchases,
             ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rank
         FROM 
             sales
         JOIN 
             menu ON sales.product_id = menu.product_id
         GROUP BY 
             customer_id, 
             product_name) x
    WHERE 
        x.rank = 1;

### -- 6. First Item Purchased after Joining

    SELECT 
        x.customer_id, 
        x.product_name, 
        x.order_date
    FROM 
        (SELECT 
             s.customer_id, 
             m.product_name, 
             s.order_date,
             RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS purchase_rank
         FROM 
             sales s
         JOIN 
             menu m ON s.product_id = m.product_id
         JOIN 
             members mem ON s.customer_id = mem.customer_id
         WHERE 
             s.order_date >= mem.join_date) x
    WHERE 
        x.purchase_rank = 1;

### -- 7. Item Purchased just Before Joining

    SELECT 
        x.customer_id, 
        x.product_name, 
        x.order_date
    FROM 
        (SELECT 
             s.customer_id, 
             m.product_name, 
             s.order_date,
             RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS purchase_rank
         FROM 
             sales s
         JOIN 
             menu m ON s.product_id = m.product_id
         JOIN 
             members mem ON s.customer_id = mem.customer_id
         WHERE 
             s.order_date < mem.join_date) x
    WHERE 
        x.purchase_rank = 1;

### -- 8. Total Items and Amount Spent Before Joining

    SELECT 
        s.customer_id, 
        COUNT(*) AS total_items, 
        SUM(m.price) AS total_amount
    FROM 
        sales s
    JOIN 
        menu m ON s.product_id = m.product_id
    JOIN 
        members mem ON s.customer_id = mem.customer_id
    WHERE 
        s.order_date < mem.join_date
    GROUP BY 
        s.customer_id;

### -- 9. Loyalty Points Calculation

    SELECT 
        s.customer_id,
        SUM(CASE
               WHEN m.product_name = 'sushi' THEN 2 * m.price
               ELSE m.price
           END) AS total_amount,
        SUM(CASE
               WHEN m.product_name = 'sushi' THEN 20 * m.price
               ELSE 10 * m.price
           END) AS total_points
    FROM 
        sales s
    JOIN 
        menu m ON s.product_id = m.product_id
    GROUP BY 
        s.customer_id;

### -- 10. Loyalty Program Points Calculation

    SELECT 
        x.customer_id,
        SUM(CASE
               WHEN s.order_date <= mem.join_date + INTERVAL '7 days' THEN 20 * m.price
               ELSE 10 * m.price
           END) AS total_points
    FROM 
        sales s
    JOIN 
        menu m ON s.product_id = m.product_id
    JOIN 
        members mem ON s.customer_id = mem.customer_id
    WHERE 
        s.order_date <= '2021-01-31'
    GROUP BY 
        s.customer_id, 
        mem.join_date;


## Conclusion

By analyzing the provided datasets and utilizing SQL queries, Danny can gain valuable insights into customer behavior and preferences. These insights will enable him to tailor his offerings and loyalty program to better serve his customers and drive business growth.


