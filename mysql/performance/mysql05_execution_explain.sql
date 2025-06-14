/* 실행계획 */
DROP TABLE IF EXISTS users; # 기존 테이블 삭제

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100),
   age INT
);

INSERT INTO users (name, age) VALUES
('박미나', 26),
('김미현', 23),
('김민재', 21),
('이재현', 24),
('조민규', 23),
('하재원', 22),
('최지우', 22);

-- 실행계획 조회
explain
select * from users
 where age = 23;


-- 상세 실행계획
explain analyze
select * from users
 where age = 23;

/* 실행계획 상세는 하단에서부터 읽어감.
 * -> Filter: (users.age = 23)  (cost=0.95 rows=1) (actual time=0.0425..0.0476 rows=2 loops=1)
    -> Table scan on users  (cost=0.95 rows=7) (actual time=0.039..0.0446 rows=7 loops=1)
    0. 전체시간 0.0476s
    1. 테이블은 전체 스캔 0.0446s
    2. 필터링 걸린 시간 0.0476 - 0.0446 = 0.003s
 * */

-- 실행계획 json 포맷 출력
explain format=json
select * from users
 where age = 23;

/*
 * {
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "0.95"
    },
    "table": {
      "table_name": "users",
      "access_type": "ALL",
      "rows_examined_per_scan": 7,
      "rows_produced_per_join": 0,
      "filtered": "14.29",
      "cost_info": {
        "read_cost": "0.85",
        "eval_cost": "0.10",
        "prefix_cost": "0.95",
        "data_read_per_join": "415"
      },
      "used_columns": [
        "id",
        "name",
        "age"
      ],
      "attached_condition": "(`performance`.`users`.`age` = 23)"
    }
  }
}
 * 
 */

-- 다시 실행계획
explain
select * from users
 where age = 23;


-- index type : Full index scan
drop table if exists users; # 기존 테이블 삭제

create table users (
   id INT auto_increment primary key,
   name VARCHAR(100),
   age INT
);

-- CTE 재귀 값 100만
set session cte_max_recursion_depth = 1000000;

-- 더미 데이터 삽입 쿼리
insert into users (name, age)
  with recursive cte (n) as 
  (
  	SELECT 1
	 UNION ALL
 	SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
  )
SELECT CONCAT('User_', LPAD(n, 7, '0')),   -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
   	   FLOOR(1 + RAND() * 1000) AS age    -- 1부터 1000 사이의 난수로 나이 생성
  FROM cte;

-- 조회
explain
 select * from users
  order by name
  limit 100;

-- 인덱스 생성
create index idx_users_name on users(name);

-- 인덱스 생성 후 재 조회

 select * from users
  order by name
  limit 100;
 

-- const type
drop table if exists users; # 기존 테이블 삭제

create table users (
   id INT auto_increment PRIMARY key, 
   account VARCHAR(100) unique 
);

insert into users (account) values 
('user1@example.com'),
('user2@example.com'),
('user3@example.com'),
('user4@example.com'),
('user5@example.com'),
('user6@example.com'),
('user7@example.com');

show index from users;
-- 실행계획 
explain select * from users where id = 3;
explain select * from users where account = 'user3@example.com';

-- range
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  age INT
);

SET SESSION cte_max_recursion_depth = 1000000;
-- 더미 데이터 삽입 쿼리
INSERT INTO users (age)
WITH RECURSIVE cte (n) AS
(
SELECT 1
UNION ALL
SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT
  FLOOR(1 + RAND() * 1000) AS age    -- 1부터 1000 사이의 난수로 나이 생성
FROM cte;

-- 인덱스 생성
CREATE INDEX idx_age ON users(age);

-- 실행계획
explain
select * from users where age between 10 and 20;

explain
select * from users where age in (10, 20, 30);

explain
select * from users where age < 20;

-- ref
DROP TABLE IF EXISTS users; # 기존 테이블 삭제


CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100)
);


INSERT INTO users (name) VALUES
('성유고'),
('박태윤'),
('김지현'),
('애슐리'),
('이지훈');


CREATE INDEX idx_name ON users(name);

-- 실행계획
explain
select * from users where name = '애슐리';