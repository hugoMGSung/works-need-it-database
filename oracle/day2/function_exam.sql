-- 문자열 함수

-- 대문자
SELECT * FROM emp
 WHERE job = UPPER('analyst');
 
SELECT UPPER('analyst') FROM dual;


SELECT LOWER(ename) ename, 
        INITCAP(job) job 
  FROM emp
 WHERE comm IS NOT NULL;
 
-- LENGTH 길이
SELECT ename, LENGTH(ename) AS 글자수, LENGTHB(ename) AS 바이트수
  FROM emp;
  
  
-- SUBSTRING 글자 잘라서 리턴
SELECT SUBSTR('안녕하세요, 한가람IT전문학원 빅데이터반입니다.', 18, 4) phase FROM dual;

-- REPLACE 글자 대체
SELECT REPLACE('안녕하세요, 한가람IT전문학원 빅데이터반입니다.', '안녕하세요', '저리가세요') phase 
  FROM dual;

-- CONCATENATION
SELECT 'A' || 'B' FROM dual;
SELECT CONCAT('A', 'B') FROM dual;

-- TRIM
SELECT '     안녕하세요.     ' FROM dual;
SELECT LTRIM('     안녕하세요.     ') FROM dual;
SELECT RTRIM('     안녕하세요.     ') FROM dual;
SELECT TRIM('     안녕하세요.     ') res FROM dual;

SELECT ROUND(15.193, 1) FROM dual;


-- SYSDATE
SELECT SYSDATE FROM dual;

-- TO_CHAR 
SELECT ename, hiredate, TO_CHAR(hiredate, 'yyyy-mm-dd'), 
        TO_CHAR(sal) || '$' 
  FROM emp;
  
-- TO_NUMBER
SELECT TO_NUMBER(REPLACE('2400$', '$', '')) + 100 FROM dual;
SELECT TO_NUMBER('이천사백') FROM dual;

-- TO_DATE
SELECT TO_DATE('2022-01-12') FROM dual;
SELECT TO_DATE('01/12/22') FROM dual;
SELECT TO_DATE('01/12/22', 'mm/dd/yy') FROM dual;


-- NVL
SELECT ename, job, sal, NVL(comm, 0) comm, 
        (sal*12) + NVL(comm, 0) AS annsal 
  FROM emp
 ORDER BY sal DESC;
 
 
-- 집계함수 SUM, COUNT, MIN, MAX, AVG
SELECT sal, NVL(comm, 0) comm FROM emp;
SELECT SUM(sal) totalsalary FROM emp;
SELECT SUM(comm) totalcommision FROM emp;
SELECT MAX(sal) FROM emp;
SELECT MIN(sal) FROM emp;
SELECT ROUND(AVG(sal), 0) sal_avg FROM emp;

SELECT MAX(sal) 월급최대, SUM(sal) 직업군당급여합계, job
  FROM emp
 GROUP BY job;
 
-- HAVING
SELECT MAX(sal) 월급최대, SUM(sal) 직업군당급여합계, job
  FROM emp
 GROUP BY job
HAVING MAX(sal) > 4000;
 
--
SELECT deptno, job, AVG(sal), MAX(sal), MIN(sal), SUM(sal), COUNT(*)
  FROM emp
 GROUP BY deptno, job
HAVING AVG(sal) >= 1000
 ORDER BY deptno, job;
 
SELECT deptno, NVL(job, '합계') JOB, 
        ROUND(AVG(sal), 2) 급여평균, MAX(sal) 급여최대, 
        SUM(sal) 급여합게, COUNT(*) 그룹별직원수
  FROM emp
 GROUP BY ROLLUP(deptno, job); 





  
