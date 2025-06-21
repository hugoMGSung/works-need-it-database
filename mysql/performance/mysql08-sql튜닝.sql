-- 
drop table if exists users;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100),
   department VARCHAR(100),
   salary INT,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


SET SESSION cte_max_recursion_depth = 2000000;

-- 더미 데이터 삽입 쿼리
INSERT INTO users (name, department, salary, created_at)
WITH RECURSIVE cte (n) AS
(
 SELECT 1
 UNION ALL
 SELECT n + 1 FROM cte WHERE n < 2000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
   CONCAT('User', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
   CASE 
       WHEN n % 10 = 1 THEN 'Engineering'
       WHEN n % 10 = 2 THEN 'Marketing'
       WHEN n % 10 = 3 THEN 'Sales'
       WHEN n % 10 = 4 THEN 'Finance'
       WHEN n % 10 = 5 THEN 'HR'
       WHEN n % 10 = 6 THEN 'Operations'
       WHEN n % 10 = 7 THEN 'IT'
       WHEN n % 10 = 8 THEN 'Customer Service'
       WHEN n % 10 = 9 THEN 'Research and Development'
       ELSE 'Product Management'
   END AS department,  -- 의미 있는 단어 조합으로 부서 이름 생성
   FLOOR(1 + RAND() * 1000000) AS salary,    -- 1부터 1000000 사이의 난수로 나이 생성
   TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;


explain 
select * from users
 order by salary
 limit 100;

/* 인덱스 생성 이전
 * -> Limit: 100 row(s)  (cost=201024 rows=100) (actual time=582..582 rows=100 loops=1)
    -> Sort: users.salary, limit input to 100 row(s) per chunk  (cost=201024 rows=1.99e+6) (actual time=582..582 rows=100 loops=1)
        -> Table scan on users  (cost=201024 rows=1.99e+6) (actual time=0.0643..429 rows=2e+6 loops=1)
 */

/* 인덱스 생성 후
 * -> Limit: 100 row(s)  (cost=0.132 rows=100) (actual time=0.0927..0.464 rows=100 loops=1)
    -> Index scan on users using idx_users_salary  (cost=0.132 rows=100) (actual time=0.0915..0.458 rows=100 loops=1)
 */

-- 인덱스 생성
create index idx_users_salary on users(salary);

-- 최근 3일 이내에 Sale부서 사용자 데이터를 salary 정렬한 뒤 100건만
select * from users
 where created_at >= date_sub(now(), interval 3 day)
   and department = 'sales'
 order by salary
 limit 100;

/* 인덱스 없을때
 * -> Limit: 100 row(s)  (cost=189573 rows=100) (actual time=767..767 rows=100 loops=1)
    -> Sort: users.salary, limit input to 100 row(s) per chunk  (cost=189573 rows=1.99e+6) (actual time=767..767 rows=100 loops=1)
        -> Filter: ((users.department = 'sales') and (users.created_at >= <cache>((now() - interval 3 day))))  (cost=189573 rows=1.99e+6) (actual time=3.55..766 rows=220 loops=1)
            -> Table scan on users  (cost=189573 rows=1.99e+6) (actual time=1.55..642 rows=2e+6 loops=1)
 */

/* salary 컬럼 인덱스 
 * -> Limit: 100 row(s)  (cost=9.09 rows=3.33) (actual time=60.9..14832 rows=100 loops=1)
    -> Filter: ((users.department = 'sales') and (users.created_at >= <cache>((now() - interval 3 day))))  (cost=9.09 rows=3.33) (actual time=60.9..14832 rows=100 loops=1)
        -> Index scan on users using idx_users_salary  (cost=9.09 rows=100) (actual time=1.88..14689 rows=780101 loops=1)
 * */

/* created_at 컬럼 인덱스
 * -> Limit: 100 row(s)  (cost=1397 rows=100) (actual time=7.53..7.53 rows=100 loops=1)
    -> Sort: users.salary, limit input to 100 row(s) per chunk  (cost=1397 rows=2089) (actual time=7.53..7.53 rows=100 loops=1)
        -> Filter: (users.department = 'sales')  (cost=1397 rows=2089) (actual time=0.752..7.45 rows=220 loops=1)
            -> Index range scan on users using idx_users_created_at over ('2025-06-18 14:14:37' <= created_at), with index condition: (users.created_at >= <cache>((now() - interval 3 day)))  (cost=1397 rows=2089) (actual time=0.742..7.34 rows=2089 loops=1)
 * */

show index from users;
drop index idx_users_salary on users;
drop index idx_users_created_at on users;

create index idx_users_created_at on users(created_at);



-- HAVING
DROP TABLE IF EXISTS users;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100),
   age INT,
   department VARCHAR(100),
   salary INT,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SET SESSION cte_max_recursion_depth = 2000000;

-- 더미 데이터 삽입 쿼리
INSERT INTO users (name, age, department, salary, created_at)
WITH RECURSIVE cte (n) AS
(
 SELECT 1
 UNION ALL
 SELECT n + 1 FROM cte WHERE n < 2000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
   CONCAT('User', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
   FLOOR(1 + RAND() * 100) AS age, -- 1부터 100 사이의 난수로 생성
   CASE 
       WHEN n % 10 = 1 THEN 'Engineering'
       WHEN n % 10 = 2 THEN 'Marketing'
       WHEN n % 10 = 3 THEN 'Sales'
       WHEN n % 10 = 4 THEN 'Finance'
       WHEN n % 10 = 5 THEN 'HR'
       WHEN n % 10 = 6 THEN 'Operations'
       WHEN n % 10 = 7 THEN 'IT'
       WHEN n % 10 = 8 THEN 'Customer Service'
       WHEN n % 10 = 9 THEN 'Research and Development'
       ELSE 'Product Management'
   END AS department,  -- 의미 있는 단어 조합으로 부서 이름 생성
   FLOOR(1 + RAND() * 1000000) AS salary,    -- 1부터 1000000 사이의 난수로 생성
   TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;


select count(*) from users;

-- 쿼리
-- explain analyze
select age, MAX(salary) from users
 group by age
having age >= 20 and age < 30;
/*
 * -> Filter: ((users.age >= 20) and (users.age < 30))  (actual time=844..844 rows=10 loops=1)
    -> Table scan on <temporary>  (actual time=844..844 rows=100 loops=1)
        -> Aggregate using temporary table  (actual time=844..844 rows=100 loops=1)
            -> Table scan on users  (cost=201571 rows=1.99e+6) (actual time=0.0999..533 rows=2e+6 loops=1)
 */

create index idx_users_age on users(age);

-- explain analyze
select age, MAX(salary) from users
 group by age
having age >= 20 and age < 30;
/*
 * -> Filter: ((users.age >= 20) and (users.age < 30))  (cost=401637 rows=90) (actual time=5826..27141 rows=10 loops=1)
    -> Group aggregate: max(users.salary)  (cost=401637 rows=90) (actual time=212..27141 rows=100 loops=1)
        -> Index scan on users using idx_users_age  (cost=202384 rows=1.99e+6) (actual time=5.9..27029 rows=2e+6 loops=1)
 */

-- 멀티인덱스 사용
drop index idx_users_age on users;
drop index idx_users_age_salary on users;
create index idx_users_age_salary on users(age, salary DESC);

-- explain analyze
select age, MAX(salary) from users
 group by age
having age >= 20 and age < 30;
/*
 * -> Filter: ((users.age >= 20) and (users.age < 30))  (cost=130 rows=96) (actual time=0.13..0.441 rows=10 loops=1)
    -> Covering index skip scan for grouping on users using idx_users_age_salary  (cost=130 rows=96) (actual time=0.0427..0.429 rows=100 loops=1)
 */


-- HAVING 대신 WHERE절 사용 : AGGREGATE(집계)함수의 수치를 필터링시 사용
explain analyze
select age, MAX(salary) from users
 where age >= 20 and age < 30
 group by age;
/*
 * -> Filter: ((users.age >= 20) and (users.age < 30))  (cost=28.4 rows=21) (actual time=0.0241..0.052 rows=10 loops=1)
    -> Covering index skip scan for grouping on users using idx_users_age_salary over (20 <= age < 30)  (cost=28.4 rows=21) (actual time=0.0213..0.0483 rows=10 loops=1)
 */