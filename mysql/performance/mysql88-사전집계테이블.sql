-- GROUP BY 인덱스 활용
-- 1. 비효율 인덱스 없는 상태에서 GROUP BY 수행 → 정렬 + 임시 테이블 발생
SELECT customer_id, COUNT(*) 
FROM orders 
GROUP BY customer_id;

-- 인덱스 생성
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- 2. 재실행
SELECT customer_id, COUNT(*) 
FROM orders 
GROUP BY customer_id;





-- 사전집계테이블 활용
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id;


-- 사전 집계 테이블 생성
CREATE TABLE order_summary (
    customer_id INT PRIMARY KEY,
    order_count INT
);

-- 배치 작업으로 주기적으로 집계
INSERT INTO order_summary (customer_id, order_count)
SELECT customer_id, COUNT(*)
FROM orders
GROUP BY customer_id
ON DUPLICATE KEY UPDATE order_count = VALUES(order_count);

-- 이후 조회는 훨씬 빠름
SELECT customer_id, order_count FROM order_summary WHERE order_count >= 3;



-- HAVING 최소화
-- 비효율 쿼리
explain
SELECT customer_id, COUNT(*) AS cnt
FROM orders
GROUP BY customer_id
HAVING customer_id > 800000;

-- 필터링을 WHERE에서 먼저 수행 → 연산량 줄어듦
explain
SELECT customer_id, COUNT(*) AS cnt
FROM orders
WHERE customer_id > 800000
GROUP BY customer_id;