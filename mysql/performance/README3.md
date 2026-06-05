# MySQL 성능최적화 3 - 고급 실전편

> 대상 : MySQL 기본 인덱스, EXPLAIN 학습 완료자
> 목표 : 실제 서비스 수준의 튜닝 사례 학습

---

# 1. 함수 사용으로 인한 인덱스 무력화

## 주문 100만 건 생성

- orders 테이블에 100만 건 생성 후 테스트
```sql
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ordered_at DATETIME NOT NULL,
    user_id INT NOT NULL,
    amount INT NOT NULL
);

-- 재귀 깊이 증가
SET SESSION cte_max_recursion_depth = 1000000;

-- 100만 건 생성
INSERT INTO orders (ordered_at, user_id, amount)
WITH RECURSIVE cte(n) AS
(
    SELECT 1
    UNION ALL
    SELECT n + 1
      FROM cte
     WHERE n < 1000000
)
SELECT
    TIMESTAMP(
        DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY)
        + INTERVAL FLOOR(RAND() * 86400) SECOND
    ) AS ordered_at,

    FLOOR(1 + RAND() * 100000) AS user_id,

    FLOOR(1000 + RAND() * 99000) AS amount
FROM cte;
```

```sql
SELECT COUNT(*)
FROM orders;
```

### 나쁜 예

```sql
EXPLAIN
SELECT *
FROM orders
WHERE YEAR(ordered_at) = 2026;
```

결과

```text
type : ALL
key  : NULL
```

### 인덱스 생성

```sql
CREATE INDEX idx_orders_ordered_at
ON orders(ordered_at);
```

### 여전히 느림

```sql
EXPLAIN
SELECT *
FROM orders
WHERE YEAR(ordered_at) = 2026;
```

YEAR() 함수 때문에 인덱스 사용 불가

### 좋은 예

```sql
EXPLAIN
SELECT *
FROM orders
WHERE ordered_at >= '2026-01-01'
  AND ordered_at < '2027-01-01';
```

결과

```text
type : range
key  : idx_orders_ordered_at
```

---

# 2. HAVING 절 튜닝

### 테이블 생성

```sql
DROP TABLE IF EXISTS scores;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    age INT
);

CREATE TABLE scores (
    score_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    year INT,
    semester INT,
    score INT,
    FOREIGN KEY(student_id)
        REFERENCES students(student_id)
);
```

### 100만건 학생/성적 데이터 생성

```sql
SET SESSION cte_max_recursion_depth = 1000000;

INSERT INTO students(name, age)
WITH RECURSIVE cte(n) AS
(
    SELECT 1
    UNION ALL
    SELECT n + 1
    FROM cte
    WHERE n < 1000000
)
SELECT
    CONCAT('Student', LPAD(n,7,'0')),
    FLOOR(18 + RAND() * 10)
FROM cte;

INSERT INTO scores
(
    student_id,
    year,
    semester,
    score
)
WITH RECURSIVE cte(n) AS
(
    SELECT 1
    UNION ALL
    SELECT n + 1
    FROM cte
    WHERE n < 1000000
)
SELECT
    FLOOR(1 + RAND() * 1000000),
    2024 + FLOOR(RAND() * 3),
    FLOOR(1 + RAND() * 2),
    FLOOR(1 + RAND() * 100)
FROM cte;
```

### 나쁜 예

```sql
SELECT st.student_id,
       AVG(sc.score)
FROM students st
JOIN scores sc
  ON st.student_id = sc.student_id
GROUP BY st.student_id, sc.year, sc.semester
HAVING AVG(sc.score)=100
   AND sc.year=2026
   AND sc.semester=1;
```

실행시간 : 약 40초 이상

### 개선

```sql
SELECT st.student_id,
       AVG(sc.score)
FROM students st
JOIN scores sc
  ON st.student_id = sc.student_id
WHERE sc.year=2026
  AND sc.semester=1
GROUP BY st.student_id, sc.year, sc.semester
HAVING AVG(sc.score)=100;
```

실행시간 : 약 1초대

---

# 3. Covering Index

테이블 접근 없이 인덱스만 읽기

```sql
CREATE INDEX idx_user_name_age
ON users(name, age);
```

### 실행

```sql
EXPLAIN
SELECT name, age
FROM users
WHERE name='홍길동';
```

결과

```text
Extra : Using index
```

---

# 4. Composite Index 순서

### 인덱스

```sql
CREATE INDEX idx_year_semester_student
ON scores(year, semester, student_id);
```

### 좋은 쿼리

```sql
SELECT *
FROM scores
WHERE year=2026
  AND semester=1;
```

### 나쁜 쿼리

```sql
SELECT *
FROM scores
WHERE semester=1;
```

복합인덱스의 좌측 컬럼 규칙 확인

---

# 5. Keyset Pagination

### OFFSET 방식

```sql
SELECT *
FROM posts
ORDER BY id DESC
LIMIT 20 OFFSET 900000;
```

### Keyset 방식

```sql
SELECT *
FROM posts
WHERE id < 100000
ORDER BY id DESC
LIMIT 20;
```

대용량 게시판 필수

---

# 6. Histogram 실습

데이터 분포

```text
서울 95%
부산 3%
대전 2%
```

### 생성

```sql
ANALYZE TABLE customers
UPDATE HISTOGRAM ON city;
```

### 확인

```sql
SELECT *
FROM information_schema.COLUMN_STATISTICS;
```

옵티마이저의 통계 정확도 향상

---

# 7. Invisible Index

### 인덱스 생성

```sql
CREATE INDEX idx_city
ON customers(city);
```

### 숨기기

```sql
ALTER TABLE customers
ALTER INDEX idx_city INVISIBLE;
```

### 복구

```sql
ALTER TABLE customers
ALTER INDEX idx_city VISIBLE;
```

운영 중 인덱스 제거 효과 테스트 가능

---

# 8. Clustered Index

```sql
CREATE TABLE members
(
    member_id INT PRIMARY KEY,
    name VARCHAR(100)
);
```

InnoDB는 PK 순서로 저장

PK 조회가 가장 빠름

---

# 9. JOIN 튜닝

### 나쁜 예

```sql
SELECT *
FROM orders o
JOIN users u
  ON o.user_id = u.id;
```

### 인덱스

```sql
CREATE INDEX idx_orders_userid
ON orders(user_id);
```

### 확인

```sql
EXPLAIN
SELECT *
FROM orders o
JOIN users u
  ON o.user_id = u.id;
```

```text
type : ref
```

---

# 10. 좋아요 TOP1000 게시글 조회

### 일반 방식

```sql
SELECT p.id,
       COUNT(l.id) AS like_count
FROM posts p
JOIN likes l
  ON p.id=l.post_id
GROUP BY p.id
ORDER BY like_count DESC
LIMIT 1000;
```

### 개선 방식

```sql
SELECT p.*, x.like_count
FROM posts p
JOIN (
    SELECT post_id,
           COUNT(*) AS like_count
    FROM likes
    GROUP BY post_id
    ORDER BY like_count DESC
    LIMIT 1000
) x
ON p.id=x.post_id;
```

대용량 집계 시 효과적

---

# 11. Deadlock 분석

```sql
SHOW ENGINE INNODB STATUS;
```

확인 항목

- Latest Detected Deadlock
- Waiting Transaction
- Locked Record

---

# 12. Performance Schema

가장 느린 SQL

```sql
SELECT *
FROM performance_schema.events_statements_summary_by_digest
ORDER BY AVG_TIMER_WAIT DESC
LIMIT 10;
```

가장 많이 실행된 SQL

```sql
SELECT *
FROM performance_schema.events_statements_summary_by_digest
ORDER BY COUNT_STAR DESC
LIMIT 10;
```

---

# 실무 체크리스트

- EXPLAIN 확인
- type = ALL 제거
- Covering Index 검토
- 복합인덱스 순서 확인
- 함수 사용 제거
- OFFSET 지양
- Slow Query Log 활성화
- Buffer Pool 점검
- Deadlock 모니터링


## 참조
- [x] 함수 사용으로 인한 인덱스 무력화 (현재 주문 예제)
- [x] HAVING → WHERE 튜닝 (현재 성적 예제)
- [x] Covering Index 실습
- [ ] Composite Index 컬럼 순서 실습
- [ ] Keyset Pagination 실습
- [ ] Histogram 실습
- [ ] Invisible Index 실습
- [ ] JOIN 튜닝 실습
- [ ] 좋아요 TOP1000 게시글 실습
- [ ] 파티셔닝(Partitioning) 실습
- [ ] Materialized Summary Table 실습
- [ ] Buffer Pool 성능 비교 실습
