DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
   id INT AUTO_INCREMENT PRIMARY KEY,
   title VARCHAR(255) NOT NULL,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   user_id INT,
   FOREIGN KEY (user_id) REFERENCES users(id)
);


-- 더미데이터
set session cte_max_recursion_depth = 1000000;

-- users 테이블에 더미 데이터 삽입
insert into users (name, created_at)
with recursive cte (n) as
(
 select 1
 union all
 select n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
select 
   CONCAT('User', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
   TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
from cte;

-- posts 테이블에 더미 데이터 삽입
insert into posts (title, created_at, user_id)
with recursive cte (n) as
(
 SELECT 1
 UNION ALL
 SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
   CONCAT('Post', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
   TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at, -- 최근 10년 내의 임의의 날짜와 시간 생성
   FLOOR(1 + RAND() * 50000) AS user_id -- 1부터 50000 사이의 난수로 급여 생성
FROM cte;


select count(*) from users;
select count(*) from posts;


-- 최초 SQL 조회
explain
select p.id, p.title, p.created_at
  from posts p
  join users u on u.id = p.user_id
 where u.name like 'User000004%'
   and p.created_at between '2024-01-01' and '2024-12-31';

-- 인덱스 추가
create index idx_users_name on users(name);
create index idx_posts_created_at on posts(created_at);


explain
select p.id, p.title, p.created_at
  from posts p
  join users u on u.id = p.user_id
 where u.name like 'User000004%'
   and p.created_at between '2024-01-01' and '2024-12-31';



-- 2024년 주문데이터 조회
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS orders;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100),
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
   id INT AUTO_INCREMENT PRIMARY KEY,
   ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   user_id INT,
   FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 더미데이터 생성
SET SESSION cte_max_recursion_depth = 1000000;

-- users 테이블에 더미 데이터 삽입
INSERT INTO users (name, created_at)
WITH RECURSIVE cte (n) AS
(
 SELECT 1
 UNION ALL
 SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
   CONCAT('User', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
   TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

-- orders 테이블에 더미 데이터 삽입
INSERT INTO orders (ordered_at, user_id)
WITH RECURSIVE cte (n) AS
(
 SELECT 1
 UNION ALL
 SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
   TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS ordered_at, -- 최근 10년 내의 임의의 날짜와 시간 생성
   FLOOR(1 + RAND() * 1000000) AS user_id    -- 1부터 1000000 사이의 난수로 급여 생성
FROM cte;

select count(*) from users;
select count(*) from orders;

-- 기본 쿼리
explain
select *
  from orders
 where YEAR(ordered_at) = 2024
 order by ordered_at
 limit 10000;   -- 0.3s, all type
 
-- 인덱스 생성
create index idx_orders_ordered_at on orders(ordered_at);

-- 재조회
-- explain
select *
  from orders
 where YEAR(ordered_at) = 2024
 order by ordered_at
 limit 10000;   -- 0.3s, all type
 
-- 쿼리 수정
-- explain
select *
  from orders
 where ordered_at >= '2024-01-01 00:00:00'
   and ordered_at < '2025-01-01 00:00:00'
  limit 10000;   -- 0.1s, range type
 
-- 동일쿼리
select *
  from orders
 where ordered_at between '2024-01-01 00:00:00' 
  and '2024-12-31 23:59:59'
 limit 10000;   -- 0.1s, range type



-- 24년도 1학기  100점인학생 조회
DROP TABLE IF EXISTS scores;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
   student_id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100),
   age INT
);

CREATE TABLE subjects (
   subject_id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100)
);

CREATE TABLE scores (
   score_id INT AUTO_INCREMENT PRIMARY KEY,
   student_id INT,
   subject_id INT,
   year INT,
   semester INT,
   score INT,
   FOREIGN KEY (student_id) REFERENCES students(student_id),
   FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- 더미데이터
SET SESSION cte_max_recursion_depth = 1000000;

-- students 테이블에 더미 데이터 삽입
INSERT INTO students (name, age)
WITH RECURSIVE cte (n) AS
(
 SELECT 1
 UNION ALL
 SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
   CONCAT('Student', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
   FLOOR(1 + RAND() * 100) AS age -- 1부터 100 사이의 랜덤한 점수 생성
FROM cte;

-- subjects 테이블에 과목 데이터 삽입
INSERT INTO subjects (name)
VALUES
   ('Mathematics'),
   ('English'),
   ('History'),
   ('Biology'),
   ('Chemistry'),
   ('Physics'),
   ('Computer Science'),
   ('Art'),
   ('Music'),
   ('Physical Education'),
   ('Geography'),
   ('Economics'),
   ('Psychology'),
   ('Philosophy'),
   ('Languages'),
   ('Engineering');

-- scores 테이블에 더미 데이터 삽입
INSERT INTO scores (student_id, subject_id, year, semester, score)
WITH RECURSIVE cte (n) AS
(
 SELECT 1
 UNION ALL
 SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
   FLOOR(1 + RAND() * 1000000) AS student_id,  -- 1부터 1000000 사이의 난수로 학생 ID 생성
   FLOOR(1 + RAND() * 16) AS subject_id,             -- 1부터 16 사이의 난수로 과목 ID 생성
   YEAR(NOW()) - FLOOR(RAND() * 5) AS year,   -- 최근 5년 내의 임의의 연도 생성
   FLOOR(1 + RAND() * 2) AS semester,                -- 1 또는 2 중에서 랜덤하게 학기 생성
   FLOOR(1 + RAND() * 100) AS score -- 1부터 100 사이의 랜덤한 점수 생성
FROM cte;


select count(*) from students;
select count(*) from subjects;
select count(*) from scores;

-- 기존 쿼리
select st.student_id, st.name, avg(sc.score) as average_score
  from students st
  join scores sc 
    on st.student_id = sc.student_id
 group by st.student_id, st.name, sc.year, sc.semester
having avg(sc.score) = 100
   and sc.year = 2024
   and sc.semester = 1;   -- 47s


-- 개선 쿼리
select st.student_id, st.name, avg(sc.score) as average_score
  from students st
  join scores sc 
    on st.student_id = sc.student_id
 where sc.year = 2024
   and sc.semester = 1
 group by st.student_id, st.name, sc.year, sc.semester
having avg(sc.score) = 100;  -- 1.381s

-- 인덱스 생성
create index idx_scores_year_semester on scores(year, semester);

select st.student_id, st.name, avg(sc.score) as average_score
  from students st
  join scores sc 
    on st.student_id = sc.student_id
 where sc.year = 2024
   and sc.semester = 1
 group by st.student_id, st.name, sc.year, sc.semester
having avg(sc.score) = 100;  -- 3.375s

drop index idx_scores_year_semester on scores;