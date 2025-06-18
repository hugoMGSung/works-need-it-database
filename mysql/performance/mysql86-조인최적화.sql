/* 조인최적화 */
-- 조인 순서 조절
-- 큰 orders를 먼저 읽고, 그 후에 customers를 조인
SELECT c.name, o.product
FROM orders o
JOIN customers c ON o.customer_id = c.id;

-- 작은 customers를 먼저 읽고, orders를 조인
SELECT c.name, o.product
FROM customers c
JOIN orders o ON c.id = o.customer_id;

-- STRAIGHT_JOIN - 무조건 customers를 읽고 orders를 조인
-- 옵티마이저가 가끔 순서를 판단
SELECT STRAIGHT_JOIN c.name, o.product
FROM customers c
JOIN orders o ON c.id = o.customer_id;


-- 필요한 컬럼만 JOIN
-- SELECT *로 모든 컬럼 조회 (불필요한 I/O)
SELECT *
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date BETWEEN '2023-01-01' AND '2023-01-31';

-- 필요한 컬럼만 명시
SELECT c.name, o.product, o.amount, o.order_date
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date BETWEEN '2023-01-01' AND '2023-01-31';

-- JOIN 인덱스 필수
-- orders.customer_id에 인덱스가 없을 경우 → Full Table Scan
SELECT c.name, o.product
FROM customers c
JOIN orders o ON c.id = o.customer_id;

-- customer_id에 인덱스 생성
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- 이후 조인
explain
SELECT c.name, o.product
FROM customers c
JOIN orders o ON c.id = o.customer_id;


-- JOIN수 줄이기
-- 같은 테이블 중복 조인 (의미 없이 orders를 두 번 조인)
SELECT c.name, o1.product, o2.amount
FROM customers c
JOIN orders o1 ON c.id = o1.customer_id
JOIN orders o2 ON c.id = o2.customer_id
WHERE o1.order_date = '2023-01-01' AND o2.order_date = '2023-01-02';

-- 서브쿼리로 분리하여 불필요한 조인 제거
SELECT c.name, o.product, o.amount
FROM customers c
JOIN (
    SELECT * FROM orders
    WHERE order_date IN ('2023-01-01', '2023-01-02')
) o ON c.id = o.customer_id;


SELECT c.name, o.product, o.amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date in ('2023-01-01', '2023-01-02');