# MySQL 성능최적화 3 - 고급편

> 대상 : MySQL 기본 문법, 인덱스, EXPLAIN을 학습한 개발자
> 
> 실습환경 : MySQL 8.0 이상

---

# 1. 옵티마이저(Optimizer) 이해하기

MySQL은 SQL을 실행하기 전에 가장 효율적인 실행 계획(Execution Plan)을 선택한다.

이를 담당하는 것이 옵티마이저(Optimizer)다.

예를 들어 아래 두 개의 인덱스가 있다고 가정하자.

```
CREATE INDEX idx_name
ON users(name);

CREATE INDEX idx_age
ON users(age);
```

쿼리

```
SELECT *
FROM users
WHERE age = 30;
```

옵티마이저는 다음을 판단한다.

- 어떤 인덱스를 사용할 것인가?
- 인덱스를 사용할 것인가?
- 풀스캔이 더 빠른가?

---

## 실행계획 확인

```
EXPLAIN
SELECT *
FROM users
WHERE age = 30;
```

결과

```
type : ref
key  : idx_age
rows : 125
```

### 주요 컬럼

|컬럼|설명|
|---|---|
|type|접근 방식|
|key|사용된 인덱스|
|rows|예상 읽기 행 수|
|Extra|추가 작업|

---

## 좋은 type 순위

```
system
const
eq_ref
ref
range
index
ALL
```

ALL 이 나오면 대부분 풀스캔이다.

---

# 2. Cardinality 와 Selectivity

고급 튜닝의 핵심 개념이다.

---

## Cardinality

고유값 개수

예)

```
성별
남
여
```

Cardinality = 2

---

```
회원ID
1
2
3
4
...
1000000
```

Cardinality = 1000000

---

## Selectivity

선택도

```
선택도 =
조회건수 / 전체건수
```

---

예)

```
SELECT *
FROM users
WHERE gender='M';
```

전체

```
1,000,000건
```

조회

```
500,000건
```

선택도

```
50%
```

낮음

---

반면

```
SELECT *
FROM users
WHERE user_id=100;
```

선택도

```
0.0001%
```

매우 높음

---

## 결론

인덱스는 선택도가 높을수록 효과적이다.

좋음

```
주민번호
회원ID
이메일
주문번호
```

나쁨

```
성별
국가코드
Y/N
```

---

# 3. Histogram 통계

옵티마이저가 잘못된 실행계획을 선택하는 경우가 있다.

예)

```
서울 95%
부산 3%
대전 2%
```

옵티마이저는

```
서울 = 33%
부산 = 33%
대전 = 33%
```

로 오해할 수 있다.

---

## 히스토그램 생성

```
ANALYZE TABLE customers
UPDATE HISTOGRAM
ON city;
```

---

삭제

```
ANALYZE TABLE customers
DROP HISTOGRAM ON city;
```

---

확인

```
SELECT *
FROM information_schema.COLUMN_STATISTICS;
```

---

# 4. Invisible Index

운영서버에서 인덱스를 제거하기 전에 효과를 확인하는 기능

---

현재

```
CREATE INDEX idx_name
ON users(name);
```

---

숨기기

```
ALTER TABLE users
ALTER INDEX idx_name INVISIBLE;
```

---

이제 옵티마이저는

```
idx_name
```

이 없는 것처럼 동작한다.

---

복구

```
ALTER TABLE users
ALTER INDEX idx_name VISIBLE;
```

---

## 실무 활용

인덱스 제거 전

```
성능 영향 확인
```

가능

---

# 5. 함수 사용으로 인한 인덱스 무력화

많은 개발자가 하는 실수

---

나쁜 예

```
SELECT *
FROM orders
WHERE YEAR(order_date)=2026;
```

인덱스 사용 불가

---

좋은 예

```
SELECT *
FROM orders
WHERE order_date >= '2026-01-01'
AND order_date < '2027-01-01';
```

인덱스 사용 가능

---

## 또 다른 예

나쁜 예

```
WHERE DATE(created_at)='2026-06-04'
```

좋은 예

```
WHERE created_at >= '2026-06-04'
AND created_at < '2026-06-05'
```

---

# 6. Functional Index

MySQL 8.0 지원

---

예)

```
CREATE INDEX idx_year
ON orders ((YEAR(order_date)));
```

---

쿼리

```
SELECT *
FROM orders
WHERE YEAR(order_date)=2026;
```

---

인덱스 사용 가능

---

# 7. Keyset Pagination

대용량 게시판 필수

---

## OFFSET 방식

```
SELECT *
FROM posts
ORDER BY id DESC
LIMIT 20 OFFSET 100000;
```

문제

```
100000건을 읽고 버림
```

---

## Keyset 방식

```
SELECT *
FROM posts
WHERE id < 900000
ORDER BY id DESC
LIMIT 20;
```

---

장점

```
항상 일정 속도
```

---

실무에서는

```
무한스크롤
SNS
쇼핑몰
```

에서 사용

---

# 8. InnoDB Clustered Index

InnoDB의 핵심

---

테이블 데이터 자체가

```
PK 순서
```

로 저장된다.

---

예)

```
CREATE TABLE members
(
    member_id INT PRIMARY KEY,
    name VARCHAR(100)
);
```

---

실제 저장

```
1
2
3
4
5
...
```

순으로 저장

---

## PK 조회

```
SELECT *
FROM members
WHERE member_id=100;
```

매우 빠름

---

## PK가 긴 경우

```
VARCHAR(200)
```

를 PK로 쓰면

모든 보조 인덱스가 커진다.

---

좋은 PK

```
INT
BIGINT
AUTO_INCREMENT
```

---

# 9. Covering Index

조회 시 테이블 접근 없이

인덱스만 읽는 기술

---

예)

```
CREATE INDEX idx_user
ON users(name, age);
```

---

쿼리

```
SELECT name, age
FROM users
WHERE name='홍길동';
```

---

실행계획

```
Using index
```

---

매우 빠르다.

---

# 10. Buffer Pool

MySQL 성능의 핵심

---

데이터를 메모리에 캐시한다.

---

확인

```
SHOW VARIABLES
LIKE 'innodb_buffer_pool_size';
```

---

권장

|   |   |
|---|---|
|서버용도|비율|
|전용 DB 서버|RAM의 70~80%|
|일반 서버|RAM의 30~50%|

---

예)

```
32GB RAM
```

전용 DB

```
24GB
```

정도

---

# 11. Lock 과 Deadlock

---

## 락 발생

트랜잭션 A

```
START TRANSACTION;

UPDATE account
SET money=100
WHERE id=1;
```

---

트랜잭션 B

```
UPDATE account
SET money=200
WHERE id=1;
```

---

대기 상태 발생

---

## 데드락

A

```
1번 잠금
2번 요청
```

B

```
2번 잠금
1번 요청
```

서로 기다림

---

확인

```
SHOW ENGINE INNODB STATUS;
```

---

예방

```
항상 동일 순서 UPDATE
트랜잭션 짧게 유지
필요한 행만 잠금
```

---

# 12. Performance Schema

MySQL 내부 성능 모니터링

---

느린 SQL 찾기

```
SELECT *
FROM performance_schema.events_statements_summary_by_digest
ORDER BY AVG_TIMER_WAIT DESC
LIMIT 10;
```

---

가장 많이 실행된 SQL

```
SELECT *
FROM performance_schema.events_statements_summary_by_digest
ORDER BY COUNT_STAR DESC
LIMIT 10;
```

---

# 13. 실무 체크리스트

## SQL

- SELECT * 사용 금지
- 필요한 컬럼만 조회
- 함수 사용 주의
- LIKE '%값' 주의

---

## 인덱스

- 선택도 높은 컬럼 우선
- 복합인덱스 순서 중요
- 중복 인덱스 제거
- Covering Index 고려

---

## 운영

- Slow Query Log 활성화
- Buffer Pool 점검
- Deadlock 모니터링
- Performance Schema 사용

---

# 마무리

초급 튜닝은

```
인덱스 추가
EXPLAIN 확인
```

수준이다.

고급 튜닝은

```
옵티마이저 이해
InnoDB 구조 이해
통계 정보 관리
락 분석
메모리 튜닝
```

영역이다.

실제 DBA와 시니어 백엔드 개발자는 SQL만 보는 것이 아니라

```
CPU
메모리
디스크 I/O
락
실행계획
버퍼풀
```

전체를 함께 분석하며 성능을 최적화한다.