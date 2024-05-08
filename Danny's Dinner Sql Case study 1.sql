CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


select * from sales;
select * from menu;
select * from members;
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

select s.customer_id, sum(m.price)
from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id;

-- 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) as days
from sales
group by customer_id
order by days desc;

-- 3. What was the first item from the menu purchased by each customer?

select * 
from (
	select customer_id, product_name, row_number() over (partition by customer_id order by order_date) as rank
	from sales 
	join menu on sales.product_id = menu.product_id) x
where rank = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name as most_purchased_item, 
  sum(s.product_id) as total_purchases
from sales s
join menu m on m.product_id = s.product_id
group by product_name
order by total_purchases desc
limit 1;

-- 5. Which item was the most popular for each customer?

select * 
from (
	select customer_id, product_name,count(*) as total_purchases,
		row_number() over(partition by customer_id order by count(*) desc) as rank
	from sales
	join menu on sales.product_id = menu.product_id
	group by customer_id, product_name) x
where rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?

select * 
from (
	select s.customer_id, m.product_name, s.order_date,
		rank() over(partition by s.customer_id order by s.order_date) as purchase_rank
	from sales s
	join menu m on s.product_id = m.product_id
	join members mem on s.customer_id = mem.customer_id
	where s.order_date >= mem.join_date) x
where purchase_rank = 1;

-- 7. Which item was purchased just before the customer became a member?

select * 
from (
	select s.customer_id, m.product_name, s.order_date,
		rank() over(partition by s.customer_id order by s.order_date desc) as purchase_rank
	from sales s
	join menu m on s.product_id = m.product_id
	join members mem on s.customer_id = mem.customer_id
	where s.order_date < mem.join_date) x
where purchase_rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

select * 
from (
	select s.customer_id, count(*) as total_items, sum(m.price) as total_amount
	from sales s
	join menu m on s.product_id = m.product_id
	join members mem on s.customer_id = mem.customer_id
	where s.order_date < mem.join_date
	group by s.customer_id);

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select *
from (
	select s.customer_id,
		sum(case
		   when m.product_name = 'sushi' then 2 * m.price
		   else m.price
		   end) as total_amount,
		sum(case
		   when m.product_name = 'sushi' then 20 * m.price
		   else 10 * m.price
		   end) as total_points
	from sales s
	join menu m on s.product_id = m.product_id
	group by s.customer_id);

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select *
from (
	select s.customer_id,
		sum(case
		   when s.order_date <= mem.join_date + interval '7 days' then 20 * m.price
		   else 10 * m.price
		   end
		   ) as total_points
	from sales s
	join menu m on s.product_id = m.product_id
	join members mem on s.customer_id = mem.customer_id
	where s.order_date <= '2021-01-31'
	group by s.customer_id, mem.join_date) x
where customer_id in ('A', 'B');