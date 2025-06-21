
DROP TABLE IF EXISTS users;

create table users (
  id INT auto_increment primary key,
  name VARCHAR(100),
  department VARCHAR(100),
  created_at TIMESTAMP default CURRENT_TIMESTAMP
);

set session cte_max_recursion_depth = 1000000;

-- 더미 데이터 삽입 쿼리
insert into users (name, department, created_at)
  with recursive cte (n) as
  (
    select 1
     union all
    select n + 1 
      from cte where n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
  )
select CONCAT('User_', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
  case when n % 10 = 1 then 'Engineering'
	   when n % 10 = 2 then 'Marketing'
 	   when n % 10 = 3 then 'Sales'
	   when n % 10 = 4 then 'Finance'
	   when n % 10 = 5 then 'HR'
	   when n % 10 = 6 then 'Operations'
	   when n % 10 = 7 then 'IT'
	   when n % 10 = 8 then 'Customer Service'
	   when n % 10 = 9 then 'Research and Development'
	   else 'Product Management'
   end AS department,  -- 의미 있는 단어 조합으로 부서 이름 생성
   TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;


-- 데이터확인
select * from users limit 100;
select count(*) from users;

-- 최근 3일 이내 등록된 사람들 조회
explain analyze
 select * from users
  where created_at >= DATE_SUB(NOW(), interval 3 day);

/* Analyze는 맨아래에서부터 읽음
 * -> Filter: (users.created_at >= <cache>((now() - interval 3 day)))  (cost=34086 rows=332286) (actual time=0.134..289 rows=1113 loops=1)
    -> Table scan on users  (cost=34086 rows=996959) (actual time=0.0676..199 rows=1e+6 loops=1)
 */

-- 인덱스 생성
create index idx_users_created_at on users(created_at desc);

show index from users;

drop index idx_users_created_at on users;
/*
 * -> Index range scan on users using idx_users_created_at over ('2025-06-18 10:12:18' <= created_at), with index condition: (users.created_at >= <cache>((now() - interval 3 day)))  (cost=498 rows=1106) (actual time=0.63..4.77 rows=1106 loops=1)
 * */


-- 3일이내이면서 sale 부서 사용자 조회
explain analyze
select * from users
 where department = 'Sales'
   and created_at >= DATE_SUB(NOW(), interval 3 day);

/*
 * -> Filter: ((users.department = 'Sales') and (users.created_at >= <cache>((now() - interval 3 day))))  (cost=93906 rows=33229) (actual time=1.66..254 rows=108 loops=1)
    -> Table scan on users  (cost=93906 rows=996959) (actual time=0.0605..196 rows=1e+6 loops=1)
 */

-- 인덱스 추가방법 3가지
drop index idx_users_created_at on users;

-- 1. created_at 컬럼 기준으로 인덱스 생성
create index idx_users_created_at on users(created_at);

/*
 * -> Filter: (users.department = 'Sales')  (cost=496 rows=110) (actual time=0.338..3.95 rows=108 loops=1)
    -> Index range scan on users using idx_users_created_at over ('2025-06-18 10:29:53' <= created_at), with index condition: (users.created_at >= <cache>((now() - interval 3 day)))  (cost=496 rows=1102) (actual time=0.333..3.87 rows=1102 loops=1)
 * */

-- 2. department 컬럼 기준으로 인덱스 생성
create index idx_users_department on users(department);

/*
 * -> Filter: (users.created_at >= <cache>((now() - interval 3 day)))  (cost=8948 rows=63765) (actual time=0.626..248 rows=108 loops=1)
    -> Index lookup on users using idx_users_department (department='Sales')  (cost=8948 rows=191314) (actual time=0.163..238 rows=100000 loops=1)
 */

-- 3. department, created_at 둘다 인덱스 생성
create index idx_users_department on users(department);
create index idx_users_created_at on users(created_at);
show index from users;

select department, count(*)
  from users
 group by department;


-- 3일이내이면서 sale 부서 사용자 조회
explain analyze
select * from users
 where department = 'Sales'
   and created_at >= DATE_SUB(NOW(), interval 3 day);

/*
 * -> Filter: (users.department = 'Sales')  (cost=495 rows=211) (actual time=0.448..3.35 rows=107 loops=1)
    -> Index range scan on users using idx_users_created_at over ('2025-06-18 10:44:20' <= created_at), with index condition: (users.created_at >= <cache>((now() - interval 3 day)))  (cost=495 rows=1099) (actual time=0.442..3.29 rows=1099 loops=1)
 */


show index from users;
alter table users drop index idx_users_department;
drop index idx_users_depart_date on users;

create index idx_users_depart_date on users(created_at, department);
create index idx_users_depart_date on users(department, created_at);

-- 3일이내이면서 sale 부서 사용자 조회
-- explain analyze
select * from users
 where department = 'Sales'
   and created_at >= DATE_SUB(NOW(), interval 3 day);

-- 0.015초대 

/*
 * -> Index range scan on users using idx_users_depart_date over ('2025-06-18 11:11:06' <= created_at AND 'Sales' <= department), with index condition: ((users.department = 'Sales') and (users.created_at >= <cache>((now() - interval 3 day))))  (cost=493 rows=1094) (actual time=0.681..0.696 rows=107 loops=1)
 * */

