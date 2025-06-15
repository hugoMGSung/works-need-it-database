/* 예제 데이터 */
drop table orders;
drop table customers;

create table customers (
    id INT auto_increment primary key,
    name VARCHAR(100) not null
);

create table orders (
    id INT auto_increment primary key,
    customer_id INT not null,
    product VARCHAR(100),
    amount DECIMAL(10, 2),
    order_date DATE,
    foreign key (customer_id) references customers(id)
);

-- 더미데이터
-- 100만 명 고객 생성 (Customer_0000001 ~ Customer_1000000)
set session cte_max_recursion_depth = 1000000;

insert into customers (name)
  with recursive cte as 
  (
	select 1 as n
     union all 
    select n + 1 from cte where n < 1000000
  )
select CONCAT('Customer_', LPAD(n, 7, '0')) 
  from cte;

-- 300만 건 주문 생성 (각 고객당 3건씩)
set session cte_max_recursion_depth = 3000000;

insert into orders (customer_id, product, amount, order_date)
select
    FLOOR((n - 1) / 3) + 1 as customer_id,
    CONCAT('Product_', MOD(n, 100)) as product,
    ROUND(RAND() * 1000, 2) as amount,
    DATE_ADD('2023-01-01', interval MOD(n, 365) day)
from (
    with recursive cte as (
        select 1 as n
         union all
        select n + 1 from cte where n < 3000000
    )
    select n from cte
) as numbers;

--
select count(*) from customers;

select count(*) from orders;

SHOW INDEX FROM orders;