create database if not exists Store01;
use Store01;

-- Tables
create table categories(
	category_id int auto_increment primary key,
	category_name varchar(50)
);

create table products (
	product_id int auto_increment primary key,
	product_name varchar(50),
	product_category int,
	product_price float,
	product_stock int,
	foreign key (product_category) references categories(category_id)
);

create table customers (
	customer_id int auto_increment primary key,
	customer_name varchar(100),
	customer_email varchar(100)
);

create table orders(
	order_id int auto_increment primary key,
	order_date datetime,
	customer_id int,
	foreign key (customer_id) references customers(customer_id)
);

create table order_items(
	id int auto_increment primary key,
	order_id int,
	product_id int,
	quantity int,
	price_at_purchase float,
	foreign key (order_id) references orders(order_id),
	foreign key (product_id) references products(product_id),
	check (quantity > 0 and price_at_purchase > 0)
);

-- Inserts
INSERT INTO categories (category_name) VALUES
('Electronics'),
('Books');

INSERT INTO products (product_name, product_category, product_price, product_stock) VALUES
('Wireless Mouse', 1, 25.99, 100),
('Mechanical Keyboard', 1, 79.99, 50),
('HD Monitor', 1, 149.99, 30),
('Sci-fi Novel', 2, 12.50, 200),
('History Book', 2, 15.75, 150);

INSERT INTO customers (customer_name, customer_email) VALUES
('Alice Johnson', 'alice.johnson@example.com'),
('Bob Smith', 'bob.smith@example.com'),
('Carol Davis', 'carol.davis@example.com'),
('Will Joel', 'w.joel@example.com');

INSERT INTO orders (order_date, customer_id) VALUES
('2025-06-01 10:15:00', 1),
('2025-06-01 11:00:00', 2),
('2025-06-01 12:30:00', 3),
('2025-06-02 09:00:00', 1),
('2025-06-02 10:45:00', 2),
('2025-06-02 14:20:00', 3),
('2025-06-03 08:15:00', 1),
('2025-06-03 09:50:00', 2),
('2025-06-03 11:30:00', 3),
('2025-06-04 10:00:00', 1),
('2025-06-04 11:10:00', 2),
('2025-06-04 13:40:00', 3),
('2025-06-05 09:25:00', 1),
('2025-06-05 12:00:00', 2),
('2025-06-05 15:30:00', 3);

INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES
(1, 1, 2, 25.99),
(1, 4, 1, 12.50),
(2, 2, 1, 79.99),
(2, 5, 2, 15.75),
(3, 3, 1, 149.99),
(3, 4, 2, 12.50),
(4, 1, 3, 25.99),
(4, 5, 1, 15.75),
(5, 2, 2, 79.99),
(5, 3, 1, 149.99),
(6, 4, 3, 12.50),
(6, 5, 2, 15.75),
(7, 1, 1, 25.99),
(7, 2, 1, 79.99),
(7, 5, 1, 15.75),
(8, 3, 2, 149.99),
(8, 4, 1, 12.50),
(9, 5, 2, 15.75),
(9, 4, 2, 12.50),
(10, 2, 1, 79.99),
(10, 1, 2, 25.99),
(11, 3, 1, 149.99),
(11, 5, 1, 15.75),
(12, 4, 1, 12.50),
(12, 1, 1, 25.99),
(12, 2, 1, 79.99),
(13, 1, 2, 25.99),
(13, 3, 1, 149.99),
(14, 4, 3, 12.50),
(14, 5, 1, 15.75),
(15, 2, 2, 79.99),
(15, 5, 2, 15.75);

-- 1. List all orders with customer names and total amounts
with totals as (
	select order_id, round(sum(price_at_purchase), 2) as total_price from order_items group by order_id
)
select 
	o.order_id, 
	c.customer_name, 
	t.total_price
from orders o
join customers c on o.customer_id = c.customer_id
join totals t on t.order_id = o.order_id
order by o.order_id;

-- 2. Find the most popular product by total quantity sold
select 
	p.product_name , 
	sum(oi.quantity) as total_quantity 
from order_items oi 
join products p on p.product_id = oi.product_id
group by oi.product_id
order by total_quantity desc
limit 1;


-- 3. Show current stock left for each product
select 
	product_name, 
	product_stock
from products;

-- 4. List customers who haven’t placed any orders
select c.customer_id from customers c 
except
select o.customer_id from orders o;
-- A different version with name included
select c.customer_id, c.customer_name
from customers c
left join orders o on c.customer_id = o.customer_id
where o.customer_id is null;

-- Roles and permissions
create role 'store_manager', 'sales_clerk', 'analyst';
grant all privileges on Store01.* to 'store_manager';
grant SELECT on Store01.products to 'sales_clerk';
grant SELECT, INSERT on Store01.orders to 'sales_clerk';
grant SELECT, INSERT on Store01.order_items to 'sales_clerk';
grant SELECT on Store01.* to 'analyst';

-- Trigger
create trigger reduce_stock
after insert
on order_items
for each row
begin
	update products
	set product_stock = product_stock - new.quantity
	where product_id = new.product_id;
end
