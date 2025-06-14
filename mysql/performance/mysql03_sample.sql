/* 오버인덱스 테스트 */
-- 테이블 A: 인덱스가 없는 테이블
create table test_table_no_index (
   id INT auto_increment primary key, -- primary key에만 인덱스
   column1 INT,
   column2 INT,
   column3 INT,
   column4 INT,
   column5 INT,
   column6 INT,
   column7 INT,
   column8 INT,
   column9 INT,
   column10 INT
);

-- 테이블 B: 인덱스가 많은 테이블
create table test_table_many_indexes (
   id INT auto_increment primary key,
   column1 INT,
   column2 INT,
   column3 INT,
   column4 INT,
   column5 INT,
   column6 INT,
   column7 INT,
   column8 INT,
   column9 INT,
   column10 INT
);

-- test_table_many_indexes 모든 컬럼에 인덱스
create index idx_column1 on
test_table_many_indexes(column1);

create index idx_column2 on
test_table_many_indexes(column2);

create index idx_column3 on
test_table_many_indexes(column3);

create index idx_column4 on
test_table_many_indexes(column4);

create index idx_column5 on
test_table_many_indexes(column5);

create index idx_column6 on
test_table_many_indexes(column6);

create index idx_column7 on
test_table_many_indexes(column7);

create index idx_column8 on
test_table_many_indexes(column8);

create index idx_column9 on
test_table_many_indexes(column9);

create index idx_column10 on
test_table_many_indexes(column10);

-- 인덱스 확인
show index from test_table_no_index;
show index from test_table_many_indexes;

truncate table test_table_no_index;
truncate table test_table_many_indexes;

-- 10만건 데이터 삽입
set session cte_max_recursion_depth = 1000000;

-- 인덱스가 없는 테이블에 데이터 10만개 삽입
insert into test_table_no_index (column1, column2, column3, column4, column5, column6, column7, column8, column9, column10)
  with recursive cte as 
  (
  	select 1 as n
     union all 
    select n + 1 from cte where n < 1000000
  )
select 	FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000)
  from cte;
-- 0.555s

-- 인덱스가 많은 테이블에 데이터 10만개 삽입
insert into test_table_many_indexes (column1, column2, column3, column4, column5, column6, column7, column8, column9, column10)
  with recursive cte as 
  (
  	select 1 as n
	 union all    
	select n + 1 from cte where n < 1000000
  )
select 	FLOOR(RAND() * 1000),
		FLOOR(RAND() * 1000),
	   	FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000),
   		FLOOR(RAND() * 1000)
  from cte;