DESC emp;

-- 주석, 아래의 select 구문을 실행
SELECT * FROM emp;

-- 컬럼을 구분해서 select
SELECT ename, job, hiredate
 FROM emp;
 
-- 부서명만 출력
SELECT DISTINCT deptno 
  FROM emp;

-- 이경우는 중복제거가 안됨  
SELECT DISTINCT empno, deptno
  FROM emp;

SELECT DISTINCT job, deptno
  FROM emp;
  
-- 조건절 where
SELECT * FROM emp
 WHERE empno = 7499;
 
SELECT * FROM emp
 WHERE ename = '홍길동';

SELECT * FROM emp
 WHERE job = 'CLERK';
 
-- 급여 SAL가 1500 이상인 사람 조회
SELECT * FROM emp
 WHERE sal > 1500;
 

