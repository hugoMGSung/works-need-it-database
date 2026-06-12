# MySQL 성능최적화 4 - SQL Rewrite 고급편

## SQL Rewrite로 쿼리 튜닝하기

목표

> **인덱스를 추가하지 않고, SQL 문법을 바꿔서 실행계획과 속도 차이를 확인

### 0. 실습 준비

#### 0-1. 데이터베이스 생성

```sql
DROP DATABASE IF EXISTS sql_rewrite_tuning;
CREATE DATABASE sql_rewrite_tuning;
USE sql_rewrite_tuning;
```

### 1. 테이블 생성

```sql
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS blacklist;
DROP TABLE IF EXISTS daily_order_stats;

CREATE TABLE customers (
    customer_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    email VARCHAR(100),
    grade VARCHAR(20),
    created_at DATETIME,
    INDEX idx_email(email),
    INDEX idx_grade(grade)
);

CREATE TABLE products (
    product_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category VARCHAR(30),
    price INT,
    INDEX idx_category(category)
);

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    status VARCHAR(20),
    total_amount INT,
    order_date DATETIME,
    memo TEXT,
    INDEX idx_customer_id(customer_id),
    INDEX idx_product_id(product_id),
    INDEX idx_status(status),
    INDEX idx_order_date(order_date),
    INDEX idx_customer_order(customer_id, order_date),
    INDEX idx_status_order(status, order_date)
);

CREATE TABLE order_items (
    item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT,
    price INT,
    INDEX idx_order_id(order_id),
    INDEX idx_product_id(product_id)
);

CREATE TABLE blacklist (
    blacklist_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT,
    reason VARCHAR(100),
    INDEX idx_blacklist_customer(customer_id)
);

CREATE TABLE daily_order_stats (
    stat_date DATE PRIMARY KEY,
    done_count BIGINT,
    cancel_count BIGINT,
    total_count BIGINT
);
```

### 2. 1000만건 테스트 데이터 생성

#### 2-1. 숫자 테이블 생성

```sql
DROP TABLE IF EXISTS numbers;

CREATE TABLE numbers (
    n INT PRIMARY KEY
);

SET SESSION cte_max_recursion_depth = 10000;

INSERT INTO numbers(n)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 10000
)
SELECT n FROM seq;
```

---

#### 2-2. 고객 100만 건 생성

```sql
INSERT INTO customers(name, email, grade, created_at)
SELECT
    CONCAT('고객_', a.n),
    CONCAT('user', a.n, '@test.com'),
    CASE
        WHEN a.n % 10 = 0 THEN 'VIP'
        WHEN a.n % 3 = 0 THEN 'GOLD'
        ELSE 'NORMAL'
    END,
    DATE_ADD('2023-01-01', INTERVAL (a.n % 1000) DAY)
FROM numbers a
WHERE a.n <= 1000000;
```

이렇게 만드면 1만건만 생성됨. 아래와 같이 생성할 것

```sql
TRUNCATE TABLE customers;

INSERT INTO customers(name, email, grade, created_at)
SELECT
    CONCAT('고객_', ((a.n - 1) * 100 + b.n)),
    CONCAT('user', ((a.n - 1) * 100 + b.n), '@test.com'),
    CASE
        WHEN ((a.n - 1) * 100 + b.n) % 10 = 0 THEN 'VIP'
        WHEN ((a.n - 1) * 100 + b.n) % 3 = 0 THEN 'GOLD'
        ELSE 'NORMAL'
    END,
    DATE_ADD('2023-01-01', INTERVAL (((a.n - 1) * 100 + b.n) % 1000) DAY)
FROM numbers a
JOIN numbers b
WHERE a.n <= 10000
  AND b.n <= 100;
```
---

#### 2-3. 상품 1만 건 생성

```sql
INSERT INTO products(product_name, category, price)
SELECT
    CONCAT('상품_', n),
    CASE
        WHEN n % 5 = 0 THEN '전자제품'
        WHEN n % 5 = 1 THEN '도서'
        WHEN n % 5 = 2 THEN '의류'
        WHEN n % 5 = 3 THEN '식품'
        ELSE '생활용품'
    END,
    1000 + (n % 100000)
FROM numbers
WHERE n <= 10000;
```

---

#### 2-4. 주문 1000만 건 생성

- TODO

```sql
INSERT INTO orders(customer_id, product_id, status, total_amount, order_date, memo)
SELECT
    ((a.n - 1) * 1000 + b.n) % 1000000 + 1 AS customer_id,
    ((a.n - 1) * 1000 + b.n) % 10000 + 1 AS product_id,
    CASE
        WHEN ((a.n - 1) * 1000 + b.n) % 10 = 0 THEN 'CANCEL'
        WHEN ((a.n - 1) * 1000 + b.n) % 3 = 0 THEN 'READY'
        ELSE 'DONE'
    END AS status,
    1000 + (((a.n - 1) * 1000 + b.n) % 500000) AS total_amount,
    DATE_ADD('2024-01-01', INTERVAL (((a.n - 1) * 1000 + b.n) % 730) DAY) AS order_date,
    CONCAT('주문 메모입니다. 주문번호: ', ((a.n - 1) * 1000 + b.n))
FROM numbers a
JOIN numbers b
WHERE a.n <= 10000
  AND b.n <= 1000;
```

---

#### 2-5. 블랙리스트 5만 건 생성

```sql
INSERT INTO blacklist(customer_id, reason)
SELECT
    n * 20,
    '비정상 주문 패턴'
FROM numbers
WHERE n <= 50000;
```