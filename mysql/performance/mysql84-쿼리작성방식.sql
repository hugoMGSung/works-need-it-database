/* NOT IN*/
truncate table orders;

-- 고객 ID 1~900000명에게만 3건씩 주문 생성
SET SESSION cte_max_recursion_depth = 2700000;

INSERT INTO orders (customer_id, product, amount, order_date)
SELECT
    FLOOR((n - 1) / 3) + 1 AS customer_id,  -- 1~900000 ID만 해당
    CONCAT('Product_', MOD(n, 100)) AS product,
    ROUND(RAND() * 1000, 2) AS amount,
    DATE_ADD('2023-01-01', INTERVAL MOD(n, 365) DAY)
FROM (
    WITH RECURSIVE cte AS (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1 FROM cte WHERE n < 2700000  -- 90만 명 × 3건
    )
    SELECT n FROM cte
) AS numbers;

-- 10만 명 정도가 주문이 없는 고객으로 간주됨
explain
SELECT * FROM customers
WHERE id NOT IN (SELECT customer_id FROM orders);

-- 또는
explain
SELECT * FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.id
);

-- 또는
explain
SELECT c.*
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.customer_id IS NULL;