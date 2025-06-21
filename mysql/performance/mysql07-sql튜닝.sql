drop table if exists users; # 기존 테이블 삭제

create table users (
   id INT auto_increment primary key,
   name VARCHAR(100),
   age INT
);

set session cte_max_recursion_depth = 2000000;

-- 더미 데이터 삽입 쿼리
insert into users (name, age)
with recursive cte (n) as
(
 select 1 
 union ALL
 SELECT n + 1 FROM cte WHERE n < 2000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
   CONCAT('User_', LPAD(n, 7, '0')),   -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
   FLOOR(1 + RAND() * 100) AS age    -- 1부터 100 사이의 난수로 나이 생성
FROM cte;


-- 데이터 확인
select count(*) from users;

-- 인덱스
create index idx_users_name on users(name);

-- 조회 쿼리
-- explain analyze
select * from users
 order by name desc;

/*
 * -> Sort: users.`name` DESC  (cost=200838 rows=2e+6) (actual time=1063..1160 rows=2e+6 loops=1)
    -> Table scan on users  (cost=200838 rows=2e+6) (actual time=0.125..322 rows=2e+6 loops=1)

 * */
show index from users;

-- 인덱스를 사용해서 더 늦어졌음
select * from users force index (idx_users_name)
 order by name desc;



-- 두번째 예시
drop table if exists users;

create table users (
   id INT auto_increment primary key,
   name VARCHAR(100),
   salary INT,
   created_at TIMESTAMP default CURRENT_TIMESTAMP
);

set session cte_max_recursion_depth = 2000000;

-- users 테이블에 더미 데이터 삽입
INSERT INTO users (name, salary, created_at)
WITH RECURSIVE cte (n) AS
(
 SELECT 1
 UNION ALL
 SELECT n + 1 FROM cte WHERE n < 2000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
   CONCAT('User_', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
   FLOOR(1 + RAND() * 1000000) AS salary,    -- 1부터 1000000 사이의 난수로 급여 생성
   TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

select count(*) from users;

-- 인덱스 생성
create index idx_users_name on users(name);
create index idx_users_salary on users(salary);

-- 함수를 왼쪽에 사용하면 속도가 더 느림
explain
select * from users
 where substring(name, 1, 10) = 'User_00000';

explain
select * from users
 where name like 'User_00000__';

select * from users force index(idx_users_name)
 where name like 'User_00000%';

-- 2달치 급여가 1000미만인 사용자 조회
explain analyze
select * from users
 where salary * 2 < 1000 
 order by salary;
/*
 * -> Sort: users.salary  (cost=200953 rows=1.99e+6) (actual time=590..590 rows=938 loops=1)
    -> Filter: ((users.salary * 2) < 1000)  (cost=200953 rows=1.99e+6) (actual time=0.122..589 rows=938 loops=1)
        -> Table scan on users  (cost=200953 rows=1.99e+6) (actual time=0.0868..506 rows=2e+6 loops=1)
 */

explain analyze
select * from users
 where salary < (1000 / 2)
 order by salary;
/*
 * -> Index range scan on users using idx_users_salary over (NULL < salary < 500), with index condition: (users.salary < <cache>((1000 / 2)))  (cost=428 rows=938) (actual time=0.358..2.8 rows=938 loops=1)
 */

