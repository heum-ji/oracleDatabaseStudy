--------------------------------------------------------------------------------
/*
    03.19(금) 
*/
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
/*
	PL/SQL 반복문
*/
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON; -- SCRIPT OUTPUT 보이게 설정

-- IF
DECLARE
    NUM NUMBER := 1;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE(NUM);
        NUM := NUM + 1;
        IF NUM > 5 THEN EXIT; -- EXIT = BREAK 와 같은 기능
        END IF;
    END LOOP;
END;
/
-- FOR
DECLARE
BEGIN
    FOR NUM IN 1..5 LOOP
        DBMS_OUTPUT.PUT_LINE(NUM);
    END LOOP;
END;
/

DECLARE
BEGIN
    FOR NUM IN REVERSE 1..5 LOOP -- REVERSE 내림차순
        DBMS_OUTPUT.PUT_LINE(NUM);
    END LOOP;
END;
/
-- WHILE
DECLARE
    NUM NUMBER := 1;
BEGIN
    WHILE NUM <= 5 LOOP
        DBMS_OUTPUT.PUTLINE(NUM);
        NUM := NUM+1;
    END LOOP;
END;
/

CREATE TABLE TEST_TBL(
    TEST_NUM    NUMBER,
    TEST_CHAR   VARCHAR2(20)
);

DECLARE
BEGIN
    FOR I IN 1..10 LOOP
        INSERT INTO TEST_TBL VALUES(I,'테스트' || I);
    END LOOP;
END;
/
SELECT * FROM TEST_TBL;

-- 급여 1~5위를 조회하는 구문 작성
SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY SALARY DESC) AS RANKING,EMP_NAME,SALARY FROM EMPLOYEE)
WHERE RANKING < 6;
-- 보너스 1~5위를 조회하는 구문 작성
SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY NVL(BONUS,0) DESC) AS RANKING,EMP_NAME,BONUS FROM EMPLOYEE)
WHERE RANKING < 6;
-- 입사일 오래된 순으로 1~5위 조회하는 구문 작성
SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY HIRE_DATE ASC) AS RANKING,EMP_NAME,HIRE_DATE FROM EMPLOYEE)
WHERE RANKING < 6;
-- '급여','보너스','입사일'
-- 입력값 별 1~5위 출력
DECLARE
    KEYWORD VARCHAR2(20);
    RANKING NUMBER;
    NAME    EMPLOYEE.EMP_NAME%TYPE;
    SAL     EMPLOYEE.SALARY%TYPE;
    BO      EMPLOYEE.BONUS%TYPE;
    H_DATE  EMPLOYEE.HIRE_DATE%TYPE;
BEGIN
    KEYWORD := '&키워드입력';
    IF KEYWORD = '급여' THEN
        DBMS_OUTPUT.PUT_LINE('----- 급여 TOP 5 -----');
        FOR I IN 1..5 LOOP
            SELECT *
            INTO RANKING, NAME, SAL
            FROM (SELECT ROW_NUMBER() OVER(ORDER BY SALARY DESC) AS RANKING,EMP_NAME,SALARY FROM EMPLOYEE)
            WHERE RANKING = I;
            DBMS_OUTPUT.PUT_LINE('랭킹 : ' || RANKING || ' / 이름 : ' || NAME || ' / 급여 : ' || SAL);
        END LOOP;
    ELSIF KEYWORD = '보너스' THEN
        DBMS_OUTPUT.PUT_LINE('----- 보너스 TOP 5 -----');
        FOR I IN 1..5 LOOP
            SELECT *
            INTO RANKING, NAME, BO
            FROM (SELECT ROW_NUMBER() OVER(ORDER BY NVL(BONUS,0) DESC) AS RANKING,EMP_NAME,BONUS FROM EMPLOYEE)
            WHERE RANKING = I;
            DBMS_OUTPUT.PUT_LINE('랭킹 : ' || RANKING || ' / 이름 : ' || NAME || ' / 보너스 : ' || BO);
        END LOOP;
    ELSIF KEYWORD = '입사일' THEN
        DBMS_OUTPUT.PUT_LINE('----- 입사일 TOP 5 -----');
        FOR I IN 1..5 LOOP
            SELECT *
            INTO RANKING, NAME, H_DATE
            FROM (SELECT ROW_NUMBER() OVER(ORDER BY HIRE_DATE ASC) AS RANKING,EMP_NAME,HIRE_DATE FROM EMPLOYEE)
            WHERE RANKING = I;
            DBMS_OUTPUT.PUT_LINE('랭킹 : ' || RANKING || ' / 이름 : ' || NAME || ' / 입사일 : ' || H_DATE);
        END LOOP;
    ELSE DBMS_OUTPUT.PUT_LINE('잘못입력하셨습니다.');
    END IF;
END;
/

--------------------------------------------------------------------------------
/*
    TRIGGER
*/
--------------------------------------------------------------------------------
CREATE TABLE M_TBL(
    USERID      VARCHAR2(20) PRIMARY KEY,
    USERPW      VARCHAR2(20) NOT NULL,
    USERNAME    VARCHAR2(20) NOT NULL,
    ENROLL_DATE DATE
);
INSERT INTO M_TBL VALUES('user01','1234','유저1',SYSDATE - 2);
INSERT INTO M_TBL VALUES('user02','1111','유저2',SYSDATE - 1);
INSERT INTO M_TBL VALUES('user03','2222','유저3',SYSDATE);
SELECT * FROM M_TBL;

CREATE TABLE DEL_M_TBL(
    USERID      VARCHAR2(20) PRIMARY KEY,
    USERNAME    VARCHAR2(20) NOT NULL,
    ENROLL_DATE DATE,
    OUT_DATE    DATE
);

-- PL/SQL 방법 : user02 탈퇴
DECLARE
    ID      M_TBL.USERID%TYPE;
    NAME    M_TBL.USERNAME%TYPE;
    EN_DATE M_TBL.ENROLL_DATE%TYPE;
BEGIN
    SELECT USERID,USERNAME,ENROLL_DATE
    INTO ID,NAME,EN_DATE
    FROM M_TBL WHERE USERID = 'user02';
    
    INSERT INTO DEL_M_TBL VALUES(ID,NAME,EN_DATE,SYSDATE); -- 삭제 테이블에 삽입
    DELETE FROM M_TBL WHERE USERID = 'user02'; -- 기존 회원 테이블에서 삭제
END;
/
SELECT * FROM M_TBL;
SELECT * FROM DEL_M_TBL;

-- M_TBL에서 DELETE 실행 후 자동 실행
CREATE OR REPLACE TRIGGER M_TBL_TRG
AFTER DELETE ON M_TBL -- INSERT / DELETE/ UPDATE 가능 // DATA의 변경이 생긴 경우
FOR EACH ROW -- ROW마다 트리거 발동 / 최종적으로 발생하면 되면 해당 문구 X
BEGIN
    -- BIND 변수
    INSERT INTO DEL_M_TBL VALUES(:OLD.USERID,:OLD.USERNAME,:OLD.ENROLL_DATE,SYSDATE);
END;
/

CREATE OR REPLACE TRIGGER M_TBL_INSERT_TRG
AFTER INSERT ON M_TBL
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE(:NEW.USERNAME || '님 환영합니다');
END;
/

INSERT INTO M_TBL VALUES('user04','4444','유저4',SYSDATE);
COMMIT; -- 커밋해야 최종적으로 적용되므로, put_line 동작함

-- BIND 변수 / OLD/NEW
-- BIND 변수를 사용하면 불 필요한 HARD PARSING을 없앰

CREATE TABLE LOG_TBL(
    DUSERID     VARCHAR2(20),
    CONTENTS    VARCHAR2(100),
    MODIFY_DATE DATE
);

CREATE OR REPLACE TRIGGER M_TBL_MODIFY_TRG
AFTER UPDATE ON M_TBL
FOR EACH ROW
BEGIN
    INSERT INTO LOG_TBL VALUES(:OLD.USERID,:OLD.USERNAME || ' --> ' || :NEW.USERNAME,SYSDATE);
END;
/

-- old : update 전 value / new : update 후 value
UPDATE M_TBL SET USERNAME = '변경이름!!' WHERE USERID = 'user04';

SELECT * FROM M_TBL;
SELECT * FROM DEL_M_TBL;
SELECT * FROM LOG_TBL;
DELETE FROM M_TBL WHERE USERID = 'user03';

CREATE TABLE PRODUCT(
    PCODE NUMBER PRIMARY KEY,   -- 상품번호
    PNAME VARCHAR2(30),         -- 상품명
    BRAND VARCHAR2(30),         -- 브랜드
    PRICE NUMBER,               -- 가격
    STOCK NUMBER DEFAULT 0      -- 수량
);
CREATE TABLE PRO_DETAIL(        
    DCODE   NUMBER PRIMARY KEY,                     -- 입출고 관리번호
    PCODE   NUMBER REFERENCES PRODUCT(PCODE),       -- 상품번호
    P_DATE  DATE,                                   -- 입출고 날짜
    AMOUNT  NUMBER,                                 -- 입출고 수량
    STATUS  CHAR(6) CHECK(STATUS IN ('입고','출고')) -- 입고/출고 구분
);
CREATE SEQUENCE PRO_SEQ;
CREATE SEQUENCE DCODE_SEQ;
DCODE_SEQ.NEXTVAL;
DROP SEQUENCE DCODE_SEQ;
/* 상품 삽입 */
INSERT INTO PRODUCT VALUES(PRO_SEQ.NEXTVAL, '마이크','삼성',100000,DEFAULT);
INSERT INTO PRODUCT VALUES(PRO_SEQ.NEXTVAL, '아이폰12','애플',1000000,DEFAULT);
INSERT INTO PRODUCT VALUES(PRO_SEQ.NEXTVAL, '보조배터리','샤오미',1000,DEFAULT);
/* 입출고 삽입 */
INSERT INTO PRO_DETAIL VALUES(DCODE_SEQ.NEXTVAL,2,SYSDATE,10,'입고');
UPDATE PRODUCT SET STOCK = STOCK + 10 WHERE PCODE = 2;
INSERT INTO PRO_DETAIL VALUES(DCODE_SEQ.NEXTVAL,2,SYSDATE,2,'출고');
UPDATE PRODUCT SET STOCK = STOCK - 2 WHERE PCODE = 2;

-- 마이크 입고 20개
INSERT INTO PRO_DETAIL VALUES(DCODE_SEQ.NEXTVAL,1,SYSDATE,20,'입고');
UPDATE PRODUCT SET STOCK = STOCK + 20 WHERE PCODE = 1;
-- 보조 배터리 입고 30개
INSERT INTO PRO_DETAIL VALUES(DCODE_SEQ.NEXTVAL,3,SYSDATE,30,'입고');
UPDATE PRODUCT SET STOCK = STOCK + 30 WHERE PCODE = 3;
-- 마이크 출고 5개
INSERT INTO PRO_DETAIL VALUES(DCODE_SEQ.NEXTVAL,1,SYSDATE,5,'출고');
UPDATE PRODUCT SET STOCK = STOCK - 5 WHERE PCODE = 1;
-- 아이폰 입고 7개
INSERT INTO PRO_DETAIL VALUES(DCODE_SEQ.NEXTVAL,2,SYSDATE,7,'입고');
UPDATE PRODUCT SET STOCK = STOCK + 7 WHERE PCODE = 2;

-- 입/출고 TRIGGER 변환
CREATE OR REPLACE TRIGGER TEST_TRG
AFTER INSERT ON PRO_DETAIL
FOR EACH ROW
BEGIN
    IF :NEW.STATUS = '입고' THEN
        UPDATE PRODUCT SET STOCK = STOCK + :NEW.AMOUNT WHERE PCODE = :NEW.PCODE;
    ELSIF :NEW.STATUS = '출고' THEN
        UPDATE PRODUCT SET STOCK = STOCK - :NEW.AMOUNT WHERE PCODE = :NEW.PCODE;
    END IF;
END;
/

INSERT INTO PRO_DETAIL VALUES(DCODE_SEQ.NEXTVAL,3,SYSDATE,10,'출고');
INSERT INTO PRO_DETAIL VALUES(DCODE_SEQ.NEXTVAL,2,SYSDATE,5,'입고');
INSERT INTO PRO_DETAIL VALUES(DCODE_SEQ.NEXTVAL,3,SYSDATE,5,'입고');

SELECT * FROM PRODUCT;
SELECT * FROM PRO_DETAIL;
COMMIT;
--------------------------------------------------------
