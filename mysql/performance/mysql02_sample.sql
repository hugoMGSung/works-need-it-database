/* PRIMARY, UNIQUE 제약조건 인덱스 */
-- 기존 테이블 삭제
drop table if exists users;

-- 새 테이블 생성
create table users (
	id INT primary key,  -- 자동증가 아님
	name VARCHAR(100)
);

-- 임시데이터 삽입

INSERT INTO users (id, name) VALUES 
	(1, 'aaa'),
	(3, 'bbb'),
	(5, 'ccc'),
	(7, 'ddd'),
	(9, 'eee');

select * from users;

-- id 9번을 2번으로 변경
update users
   set id = 2
 where id = 9;

-- UNIQUE 제약조건 인덱스
-- 기존 테이블 삭제
drop table if exists users;

-- 새 테이블 생성1
create table users (
	id INT not null,
	name VARCHAR(100) unique  -- unique CIndex 생성(인덱스테이블이 따로 생성)
);     

-- 새 테이블 생성2
create table users (
	id INT not null primary key, -- primary key에 CIndex 생성
	name VARCHAR(100) unique  -- unique NCIndex 생성(인덱스테이블이 따로 생성)
);
     
