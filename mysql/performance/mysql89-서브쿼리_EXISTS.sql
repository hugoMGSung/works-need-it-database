/* 서브쿼리 & EXISTS 최적화 */
-- IN → EXISTS로 변경
-- 1. 비효율 IN
SELECT * FROM customers
WHERE id IN (SELECT customer_id FROM orders)
  and name like '%0089';

-- 2. 효율 EXISTS
SELECT * FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.id
)
	and name like '%0089';

-- 별 도움안됨. 서브쿼리 크기가 크면


-- 상관 서브쿼리 지양
-- 1. 비효율 상관쿼리
SELECT c.id, c.name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) AS order_count
FROM customers c
where c.name like '%89';

-- 2. 최적화
SELECT c.id, c.name, COUNT(o.id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
where c.name like '%89'
GROUP BY c.id;


-- 서브쿼리 대신 JOIN 사용
-- 1. 비효율
SELECT * FROM customers
WHERE id NOT IN (SELECT customer_id FROM orders);

-- 2. 최적화
SELECT c.*
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.customer_id IS NULL;

-- 3. 실제 최적화된 쿼리
SELECT *
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.id
);
