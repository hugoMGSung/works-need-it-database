-- LIMIT + OFFSET 방식 
explain
SELECT *
FROM orders
ORDER BY id
LIMIT 600000, 100;

-- 마지막으로 본 주문 id가 100000이라면
explain
SELECT *
FROM orders
WHERE id > 600000
ORDER BY id
LIMIT 100;