/* 멀티컬럼 인덱스 */
drop table if exists users;

-- 테이블 신규 생성
create table users (
   id INT auto_increment primary key,
   name VARCHAR(100),
   department VARCHAR(100),
   age INT
);

-- 더미 데이터 추가
insert into users (name, department, age) values 
('박미나', '회계', 26),
('김미현', '회계', 23),
('김민재', '회계', 21),
('이재현', '운영', 24),
('조민규', '운영', 23),
('하재원', '인사', 22),
('최지우', '인사', 22);

-- 멀티컬럼 인덱스 생성
create index idx_users_depart_name on users(department, name);

show index from users;

-- 중복수를 확인. 
select count(distinct department) from users;
select count(distinct name) from users;