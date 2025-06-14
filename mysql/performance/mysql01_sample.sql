-- 기존 테이블 삭제
drop table if exists users;

-- 사용자 테이블 생성
create table users (
	id int primary key auto_increment, -- PK, 자동증가
	name varchar(100),
	age int
);

-- MySQL Workbench 1000만건 삽입불가
-- DBeaver 1000만건도 삽입가능

-- 100만건 (Python, C#, Java에서 BulkCopy 가능)
insert into users (name, age)
select CONCAT('User_', FLOOR(RAND() * 1000000))
     , FLOOR(RAND() * 100)
  from information_schema.tables t1,
  	   information_schema.tables t2
 limit 1000000;

-- 확인: 10만건 밖에 안들어감
select * from users;

truncate table users;

/* CTE 사용방식 */
-- 재귀호출 회수를 설정, 100만건
set session cte_max_recursion_depth = 1000000;

-- 더미데이터 삽입 쿼리
insert into users (name, age)
  with recursive cte(n) as (
  	select 1
  	 union all
  	select n+1 from cte where n < 1000000  -- 생성하려는 더미데이터 개수
  )
select CONCAT('User_', LPAD(n, 7, '0')) -- 7자리 User_0000001 ~ User_999999
     , FLOOR(1 + RAND()*100) as age
  from cte;

-- 더미데이터 확인
select * from users;

/* 인덱스 */
select * 
  from users
 where age = 25;
-- 인덱스 없을때 0.221s 소요
-- 인덱스 생성 후 0.127s 소요

-- 인덱스 생성, 1초 소요
create index idx_user_age on users(age);