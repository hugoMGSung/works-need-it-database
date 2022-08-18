## 3일차 학습

### INNER JOIN
```sql
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
```

### OUTER JOIN
```sql
SELECT e.empno
      , e.ename
      , e.job
      , TO_CHAR(e.hiredate, 'yyyy-mm-dd') hiredate
      , e.deptno
      , d.dname
  FROM emp e, dept d
 WHERE e.deptno (+) = d.deptno; -- PL/SQL 형식의 right outer join
-- WHERE e.deptno = d.deptno (+); -- PL/SQL 형식의 left outer join
```

### 3개 테이블 조인
```sql
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
```
