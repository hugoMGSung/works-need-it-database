-- 기본 이너조인
SELECT e.empno
      , e.ename
      , e.job
      , TO_CHAR(e.hiredate, 'yyyy-mm-dd') hiredate
      , e.deptno
      , d.dname 
  FROM emp e
 INNER JOIN dept d
    ON e.deptno = d.deptno
 WHERE e.job = 'SALESMAN';

-- PL/SQL 이너조인
SELECT e.empno
      , e.ename
      , e.job
      , TO_CHAR(e.hiredate, 'yyyy-mm-dd') hiredate
      , e.deptno
      , d.dname 
  FROM emp e, dept d
-- WHERE 1 = 1 -- TIP
 WHERE e.deptno = d.deptno
   AND e.job = 'SALESMAN';
   
-- LEFT OUTER JOIN
SELECT e.empno
      , e.ename
      , e.job
      , TO_CHAR(e.hiredate, 'yyyy-mm-dd') hiredate
      , e.deptno
      , d.dname 
  FROM emp e
  LEFT OUTER JOIN dept d
    ON e.deptno = d.deptno;

-- RIGHT OUTER JOIN
SELECT e.empno
      , e.ename
      , e.job
      , TO_CHAR(e.hiredate, 'yyyy-mm-dd') hiredate
      , e.deptno
      , d.dname
      , e.comm
  FROM emp e
 RIGHT OUTER JOIN dept d
    ON e.deptno = d.deptno;


SELECT e.empno
      , e.ename
      , e.job
      , TO_CHAR(e.hiredate, 'yyyy-mm-dd') hiredate
      , e.deptno
      , d.dname
  FROM emp e, dept d
 WHERE e.deptno (+) = d.deptno; -- PL/SQL 형식의 right outer join
-- WHERE e.deptno = d.deptno (+); -- PL/SQL 형식의 left outer join

-- 3개테이블 조인
SELECT e.empno
      , e.ename
      , e.job
      , TO_CHAR(e.hiredate, 'yyyy-mm-dd') hiredate
      , e.deptno
      , d.dname
      , b.comm
  FROM emp e, dept d, bonus b
 WHERE e.deptno (+) = d.deptno
   AND e.ename = b.ename (+);
   
   
