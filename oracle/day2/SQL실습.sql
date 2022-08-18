-- 행단위로 조회하는 셀렉션
SELECT * FROM emp
 WHERE sal = 5000;
 
SELECT * FROM emp
 WHERE job = 'CLERK';
 
SELECT * FROM emp
 WHERE comm = 0 OR comm IS NULL;

-- 보너스가 NULL이고 직업이 ANALYST인 사람만 셀렉션 
SELECT * FROM emp
 WHERE comm IS NULL AND job = 'ANALYST';
 
-- 프로젝션
SELECT empno, ename, deptno
  FROM emp
 WHERE deptno = 30;
 

-- 조인, 두개 이상의 테이블을 하나의 테이블처럼 조회하는 방법
SELECT e.empno, e.ename, e.job, e.hiredate, e.sal, d.deptno, d.dname
  FROM emp e
  JOIN dept d
    ON e.deptno = d.deptno;


-- DISTINCT 복습
SELECT DISTINCT job FROM emp;

-- 별명 ALIAS
SELECT ename, job, sal, sal*12 AS annsal
  FROM emp
 ORDER BY sal DESC; -- ASC 오름차순 / DESC 내림차순
 
-- WHERE
SELECT ename, job, sal, sal*12 AS annsal
  FROM emp
 WHERE sal*12 >= 10000;
 
SELECT ename, job, sal, sal*12 AS annsal
  FROM emp
 WHERE sal != 1000; -- <>, != 많이 쓰임 ^= 거의 안쓰임

SELECT ename, job, sal, sal*12 AS annsal
  FROM emp
 WHERE NOT sal = 1000;

-- IN 
SELECT ename, job, sal, sal*12 AS annsal
  FROM emp
 WHERE sal IN (800, 1600, 5000); 
 
SELECT ename, job, sal, sal*12 AS annsal
  FROM emp
 WHERE sal = 800 OR sal = 1600 OR sal = 5000; 
 
-- BETWEEN A AND B
SELECT ename, job, sal, sal*12 AS annsal
  FROM emp
 WHERE sal >= 1600 AND sal <= 2975;
 
SELECT ename, job, sal, sal*12 AS annsal
  FROM emp
 WHERE sal BETWEEN 1600 AND 2975;
 
-- LIKE
SELECT ename, job, sal, sal*12 AS annsal
  FROM emp
 WHERE ename LIKE '__RD';  -- J%, %ER, %E%, __RD
 
-- NULL, 함수명 NVL() 나중에 to be continued...
SELECT ename, job, sal, comm
  FROM emp
 WHERE comm IS NOT NULL;

-- 집합
SELECT empno, ename, job FROM emp
 WHERE comm IS NOT NULL
UNION ALL
SELECT deptno, dname, loc FROM dept;

