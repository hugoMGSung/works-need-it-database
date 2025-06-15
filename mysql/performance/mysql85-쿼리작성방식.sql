/* DISTINCT, GROUP BY 최소화 */
-- 1. 비효율 쿼리
explain
SELECT DISTINCT customer_id
FROM orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-01-31';

-- 2. 효율 쿼리
explain
SELECT customer_id
FROM orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-01-31'
GROUP BY customer_id;