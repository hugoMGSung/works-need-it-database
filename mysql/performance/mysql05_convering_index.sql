/* 커버링 인덱스 */
drop table if exists users;

-- 테이블 신규 생성
create table users (
   id INT auto_increment primary key,
   name VARCHAR(100),
   created_at DATETIME
);

-- 더미 데이터 추가
insert into users (name, created_at) values 
('박미나', now()),
('김미현', now()),
('김민재', now()),
('이재현', now()),
('조민규', now()),
('하재원', now()),
('최지우', now());

-- 커버링 인덱스
create index idx_users_id_name ON users(id, name);

show index from users;