/* 쿼리 작성 방식 */
-- 비효율
SELECT * 
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date BETWEEN '2023-01-01' AND '2023-01-31';

create index idx_customers_name on customers(name);

-- 효율
SELECT c.name, o.product, o.amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date BETWEEN '2023-01-01' AND '2023-01-31';


-- 함수사용 제한
explain
SELECT product, amount
FROM orders
WHERE YEAR(order_date) = 2023 AND MONTH(order_date) = 1;

create index idx_orderso_dates on orders(order_date);

explain
SELECT product, amount
FROM orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-01-31';


/* OR 대신 UNION 또는 IN */
-- 1. 비효율?
SELECT *
FROM orders
WHERE product = 'Product_01' OR product = 'Product_99';

-- 2. 효율
SELECT *
FROM orders
WHERE product IN ('Product_01', 'Product_99');

-- 3. 이게 효율?
SELECT * FROM orders WHERE product = 'Product_01'
union
SELECT * FROM orders WHERE product = 'Product_99';

CREATE INDEX idx_product ON orders(product);


