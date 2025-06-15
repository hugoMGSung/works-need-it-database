-- orders.customer_id에 인덱스가 없다면 Full Table Scan 발생
explain
select *
  from customers c
  join orders o on c.id = o.customer_id
 where o.order_date between '2023-01-01' and '2023-01-31';

-- 멀티컬럼 인덱스 생성
create index idx_orders_customer
    on orders(customer_id);

create index idx_orders_orderdate_customer
    on orders(order_date, customer_id);

-- 재 조회
explain
select *
  from customers c
  join orders o on c.id = o.customer_id
 where o.order_date between '2023-01-01' and '2023-01-31';


/* 커버링 인덱스 */
SELECT customer_id, product, amount
FROM orders
WHERE customer_id = 123456;

-- 커버링 인덱스 생성
-- 모든 SELECT 컬럼이 인덱스에 포함됨 (커버링 인덱스)
CREATE INDEX idx_covering ON orders(customer_id, product, amount);

explain
SELECT customer_id, product, amount
FROM orders
WHERE customer_id = 123456;


-- 사용하지 않는 인덱스가 너무 많으면 INSERT/UPDATE 성능 저하
-- 예) product, order_date 각각 따로 인덱스만 있고 쿼리에서 안 씀
CREATE INDEX idx_unused1 ON orders(product);
CREATE INDEX idx_unused2 ON orders(order_date);


-- 사용 빈도 낮은 인덱스 제거
DROP INDEX idx_unused1 ON orders;
DROP INDEX idx_unused2 ON orders;