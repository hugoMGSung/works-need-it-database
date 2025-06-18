/* 실행계획분석 */
-- 테이블 생성
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product VARCHAR(100),
    amount DECIMAL(10,2),
    order_date DATE
);

-- CTE 재귀 깊이 설정
SET SESSION cte_max_recursion_depth = 1000000;

-- INSERT: 총 1,000,000건 생성
INSERT INTO orders (customer_id, product, amount, order_date)
SELECT
    FLOOR((n - 1) / 3) + 1 AS customer_id,                     -- 고객 ID: 1~약 333,333명
    CONCAT('Product_', MOD(n, 100)) AS product,               -- 상품명: Product_0 ~ Product_99
    ROUND(RAND() * 1000, 2) AS amount,                        -- 금액: 0.00 ~ 1000.00 랜덤
    DATE_ADD('2023-01-01', INTERVAL MOD(n, 365) DAY)          -- 날짜: 2023년 내
FROM (
    WITH RECURSIVE cte AS (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1 FROM cte WHERE n < 1000000
    )
    SELECT n FROM cte
) AS numbers;

-- 1. 비효율 쿼리
explain
SELECT customer_id, COUNT(*) 
FROM orders
GROUP BY customer_id
ORDER BY COUNT(*) DESC;


-- 인덱스 추가 (group by, order by 대상 컬럼)
CREATE INDEX idx_customer_group ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- 2. 정렬 제거
explain
SELECT customer_id, COUNT(*) 
FROM orders
WHERE customer_id IS NOT NULL
GROUP BY customer_id;


-- TYPE이 ALL이면 경계
-- 1. 비효율
SELECT id, customer_id
FROM orders
WHERE YEAR(order_date) = 2023;

-- 인덱스 생성
SHOW INDEX FROM orders;
CREATE INDEX idx_order_date ON orders(order_date);

ANALYZE TABLE orders;

-- 함수 제거
SELECT id, customer_id FROM orders FORCE INDEX (idx_order_date)
WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31';

-- 하루만 범위로 설정
SELECT id, customer_id
FROM orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-01-01';


