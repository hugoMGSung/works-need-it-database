-- 슬로우 쿼리 로그 활성화
SET GLOBAL slow_query_log = ON;

-- 슬로우 쿼리 기록 파일 경로 확인
SHOW VARIABLES LIKE 'slow_query_log_file';

-- 실행 시간 기준 (초) 설정: 2초 이상인 쿼리만 기록
SET GLOBAL long_query_time = 2;

-- SELECT 외에도 모든 쿼리 기록할지 여부
SET GLOBAL log_queries_not_using_indexes = OFF;  -- or on


-- 함수 제거
SELECT id, customer_id FROM orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31';


CREATE TABLE orders_partitioned (
    id INT,
    customer_id INT,
    amount DECIMAL(10,2),
    order_date DATE
)
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION pmax  VALUES LESS THAN MAXVALUE
);

-- 기존 orders 테이블 이관
INSERT INTO orders_partitioned (id, customer_id, amount, order_date)
SELECT id, customer_id, amount, order_date
FROM orders;


-- 파티션별 행 수 확인
SELECT partition_name, table_rows
FROM information_schema.partitions
WHERE table_name = 'orders_partitioned';

select count(*) from orders;