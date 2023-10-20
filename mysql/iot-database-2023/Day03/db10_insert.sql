-- INSERT 
INSERT INTO usertbl
(userID, name, birthYear, addr, mobile1, mobile2, height, mDate)
VALUES
('SMG', '성명건', 1976, '부산', '010', '66887777', 179, '2023-03-02');

-- 컬럼을 다 적을때 입력안할 컬럼은 NULL로 지정
INSERT INTO usertbl
(userID, name, birthYear, addr, mobile1, mobile2, height, mDate)
VALUES
('SHM', '손흥민', 1991, '서울', NULL, NULL, NULL, NULL);

-- NULL컬럼은 생략가능
INSERT INTO usertbl
(userID, name, birthYear, addr)
VALUES
('SHM', '손흥민', 1991, '서울');

-- 컬럼 지정을 생략가능(단, 입력할 값의 순서가 컬럼순서 일치)
INSERT INTO usertbl VALUES
('SJW', '손정웅', 1969, '서울', '010', '55664433', '176', NULL);

-- AUTO_INCREMENT 의 경우 필드값을 입력하지 않아도 됨
INSERT INTO buytbl 
(userID, prodName, groupName, price, amount)
VALUES
('SMG', '노트북', '전자', 5000000, 1);