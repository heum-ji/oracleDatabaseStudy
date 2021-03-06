--------------------------------------------------------------------------------
/*
    03.19(금) 
*/
--------------------------------------------------------------------------------

/*
    KH_MEMBER 테이블
    MEMBER_NO 숫자
    MEMBER_NAME 문자
    MEMBER_AGE 숫자
    MEMBER_JOIN_COM 숫자
    
    MEMBER_NO, MEMBER_JOIN_COM 시퀀스로 처리
    MEMBER_NO : 500부터 시작해서 10씩 증가
    JOIN_COM : 1부터 시작해서 1씩증가
    두 시퀀스 모두 최대값은 10000/CYCLE X, CACHE X
    테스트 데이터 5명 삽입
*/

CREATE TABLE KH_MEMBER(
    MEMBER_NO NUMBER,
    MEMBER_NAME VARCHAR2(20),
    MEMBER_AGE NUMBER,
    MEMBER_JOIN_COM NUMBER 
);
CREATE SEQUENCE KH_MEMBER_NO
START WITH 500
INCREMENT BY 10
MAXVALUE 10000
NOCYCLE
NOCACHE;
CREATE SEQUENCE KH_JOIN_COM
START WITH 1
INCREMENT BY 1
MAXVALUE 10000
NOCYCLE
NOCACHE;

SELECT * FROM KH_MEMBER;
INSERT INTO KH_MEMBER VALUES(KH_MEMBER_NO.NEXTVAL,'멤버01',1,KH_JOIN_COM.NEXTVAL);
INSERT INTO KH_MEMBER VALUES(KH_MEMBER_NO.NEXTVAL,'멤버02',22,KH_JOIN_COM.NEXTVAL);
INSERT INTO KH_MEMBER VALUES(KH_MEMBER_NO.NEXTVAL,'멤버03',3,KH_JOIN_COM.NEXTVAL);
INSERT INTO KH_MEMBER VALUES(KH_MEMBER_NO.NEXTVAL,'멤버04',44,KH_JOIN_COM.NEXTVAL);
INSERT INTO KH_MEMBER VALUES(KH_MEMBER_NO.NEXTVAL,'멤버05',5,KH_JOIN_COM.NEXTVAL);

SELECT EMP_NAME, EMP_NO, HIRE_DATE FROM EMPLOYEE;

/* INDEX */
CREATE INDEX EMP_IDX ON EMPLOYEE(EMP_NAME,EMP_NO,HIRE_DATE);
DROP INDEX EMP_IDX;
SELECT * FROM USER_IND_COLUMNS; -- WHERE INDEX_NAME = 'EMP_IDX';

/* 
    SYNONYM
    GRANT CREATE SYNONYM TO 계정명; -- 권한 생성
    -- 비공개 동의어
  
    CREATE SYNONYM EMP FOR EMPLOYEE; -- 동의어 생성
    GRANT SELECT ON KH.DEPARTMENT TO test01; --다른 계정 조회 권한 부여
    REVOKE SELECT ON KH.DEPARTMENT FROM test01; -- 다른 계정 조회 권한 삭제
    -- 공개 동의어
    CREATE PUBLIC SYNONYM DEPT FOR KH.DEPARTMENT; -- 동의어 생성
    DROP PUBLIC SYNONYM DEPT; -- 삭제
*/

SELECT * FROM EMPLOYEE;
SELECT * FROM EMP;

CREATE SYNONYM EMP FOR EMPLOYEE;
SELECT * FROM DEPT;

/*
    PL/SQL의 유형
    1. 익명 블록(Anonymous Block)
    - 이름이 없는 블록, 간단한 블록 수행시 사용
    
    2. 프로시저(Procedure)
    - 지정된 특정 처리를 실행하는 서브 프로그램의 한종류
    - return 값 없음
    
    3. 함수 (Function)
    - 프로시저와 수행 결과가 유사하지만 반환값 여부의 차이가 존재
    - return 값 있음
*/
-- PL/SQL을 사용한 출력내용을 화면에 보여주는 설정
-- 접속할때마다 ON해야 사용 가능
SET SERVEROUTPUT ON; 

BEGIN
    DBMS_OUTPUT.PUT_LINE('HELLO ORACLE'); -- prinln 기능
END;
/

SELECT * FROM EMPLOYEE;

SELECT EMP_ID FROM EMPLOYEE WHERE EMP_NAME = '선동일';

DECLARE
    ID NUMBER;
BEGIN
    SELECT EMP_ID 
    INTO ID -- ID에 SELECT 대입 / SELECT / FROM 사이
    FROM EMPLOYEE WHERE EMP_NAME = '&이름'; -- 대체변수 입력 값 받음
    DBMS_OUTPUT.PUT_LINE(ID);
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('데이터 없음');
END;
/
-- 사번을 입력받아서 이름, 직급코드, 부서코드 출력
DECLARE
    NAME VARCHAR2(20);
    J_CODE VARCHAR2(20);
    D_CODE VARCHAR2(20);
BEGIN
    SELECT EMP_NAME, JOB_CODE, DEPT_CODE 
    INTO NAME, J_CODE, D_CODE
    FROM EMPLOYEE WHERE EMP_ID = '&사번';
    
    DBMS_OUTPUT.PUT_LINE('이름 : ' || NAME);
    DBMS_OUTPUT.PUT_LINE('직급코드 : ' || J_CODE);
    DBMS_OUTPUT.PUT_LINE('부서코드 : ' || D_CODE);
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('데이터 없음');
END;
/
-- 사원 번호를 입력 받아서, 이름, 부서명, 직급명 출력
-- JOIN
DECLARE
    NAME VARCHAR2(20);
    D_NAME VARCHAR2(20);
    J_NAME VARCHAR2(20);
BEGIN
    SELECT EMP_NAME, DEPT_TITLE, JOB_NAME
    INTO NAME, D_NAME, J_NAME
    FROM EMPLOYEE
    JOIN DEPARTMENT ON(DEPT_CODE = DEPT_ID)
    JOIN JOB USING(JOB_CODE)
    WHERE EMP_ID = '&사번';
    
    DBMS_OUTPUT.PUT_LINE('이름 : ' || NAME);
    DBMS_OUTPUT.PUT_LINE('부서명 : ' || D_NAME);
    DBMS_OUTPUT.PUT_LINE('직급명 : ' || J_NAME);
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('데이터 없음');
END;
/
-- 서브쿼리 
DECLARE
    NAME VARCHAR2(20);
    D_NAME VARCHAR2(20);
    J_NAME VARCHAR2(20);
BEGIN
    SELECT EMP_NAME,
    (SELECT DEPT_TITLE FROM DEPARTMENT D WHERE E.DEPT_CODE = D.DEPT_ID),
    (SELECT JOB_NAME FROM JOB J WHERE E.JOB_CODE = J.JOB_CODE)
    INTO NAME, D_NAME, J_NAME
    FROM EMPLOYEE E
    WHERE EMP_ID = '&사번';
    DBMS_OUTPUT.PUT_LINE('이름 : ' || NAME);
    DBMS_OUTPUT.PUT_LINE('부서명 : ' || D_NAME);
    DBMS_OUTPUT.PUT_LINE('직급명 : ' || J_NAME);
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('데이터 없음');
END;
/

/*
    변수선언
    변수명 [CONSTANT] 자료형(크기) [NOT NULL] [:=초기값];
    컬럼 타입 불러오기 - 테이블명.컬럼명%TYPE
    모든 컬럼 타입 불러오기 - 테이블명%ROWTYPE
*/
DECLARE
    NO1 NUMBER := 10;
BEGIN
    DBMS_OUTPUT.PUT_LINE(NO1);
    NO1 := 100;
    DBMS_OUTPUT.PUT_LINE(NO1);
END;
/

DECLARE
    NAME EMPLOYEE.EMP_NAME%TYPE;
    D_CODE EMPLOYEE.DEPT_CODE%TYPE;
BEGIN
    SELECT EMP_NAME, DEPT_CODE
    INTO NAME, D_CODE
    FROM EMPLOYEE WHERE EMP_ID = '&사번';
    DBMS_OUTPUT.PUT_LINE(NAME);
    DBMS_OUTPUT.PUT_LINE(D_CODE);
END;
/

DECLARE
    MYROW EMPLOYEE%ROWTYPE;
BEGIN
    SELECT EMP_NAME,EMAIL,PHONE,SALARY,HIRE_DATE
    INTO MYROW.EMP_NAME, MYROW.EMAIL,MYROW.PHONE,MYROW.SALARY,MYROW.HIRE_DATE
    FROM EMPLOYEE WHERE EMP_ID = '&사번';
    DBMS_OUTPUT.PUT_LINE(MYROW.EMP_NAME);
END;
/

DECLARE
    -- MYRECORD 라는 데이터 타입 작성
    TYPE MYRECORD IS RECORD(
        NAME EMPLOYEE.EMP_NAME%TYPE,
        EMAIL EMPLOYEE.EMAIL%TYPE,
        PHONE EMPLOYEE.PHONE%TYPE,
        SAL EMPLOYEE.SALARY%TYPE,
        H_DATE EMPLOYEE.HIRE_DATE%TYPE
    );
    -- MYRECORD 타입 변수 선언
    MY MYRECORD;
BEGIN
    SELECT EMP_NAME,EMAIL,PHONE,SALARY,HIRE_DATE
    INTO MY
    FROM EMPLOYEE WHERE EMP_ID = '&사번';
    DBMS_OUTPUT.PUT_LINE(MY.NAME);
    DBMS_OUTPUT.PUT_LINE(MY.EMAIL);
    DBMS_OUTPUT.PUT_LINE(MY.PHONE);
    DBMS_OUTPUT.PUT_LINE(MY.SAL);
    DBMS_OUTPUT.PUT_LINE(MY.H_DATE);
END;
/
----------------------------------------------------------
/*
    선택문
    IF, IF ~ ELSE, IF ~ ELSE IF
    
    IF(조건식) {
        조건식이 TRUE면 수행
    }
    
    IF 조건 THEN 조건이 TRUE면 실행할 구문
    
    END IF
*/
----------------------------------------------------------
-- 사원번호를 입력받아서 사번,이름,급여,보너스를 출력
-- 만약에 보너스가 없으면 '보너스를 지급받지 않는 사원입니다.' 출력
DECLARE
    ID EMPLOYEE.EMP_ID%TYPE;
    NAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    BO EMPLOYEE.BONUS%TYPE;
BEGIN
    SELECT EMP_ID,EMP_NAME,SALARY,NVL(BONUS,0)
    INTO ID,NAME,SAL,BO
    FROM EMPLOYEE WHERE EMP_ID = '&사원번호';
    DBMS_OUTPUT.PUT_LINE('사번 : ' || ID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || NAME);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || SAL);
    DBMS_OUTPUT.PUT_LINE('보너스율 : ' || BO * 100 || '%');
    IF (BO = 0) 
    THEN DBMS_OUTPUT.PUT_LINE('보너스를 지급 받지 않는 사원입니다.');
    END IF;
END;
/
-- 사원번호를 입력받고 사번,이름,부서코드,부서명을 출력
-- 이때 직급코드가 J1,J2면 '임원진입니다.' , 그외 '일반 직원입니다.'
DECLARE
    ID EMPLOYEE.EMP_ID%TYPE;
    NAME EMPLOYEE.EMP_NAME%TYPE;
    D_CODE EMPLOYEE.DEPT_CODE%TYPE;
    D_TITLE DEPARTMENT.DEPT_TITLE%TYPE;
    J_CODE EMPLOYEE.JOB_CODE%TYPE;
BEGIN
    SELECT EMP_ID,EMP_NAME,DEPT_CODE,DEPT_TITLE,JOB_CODE
    INTO ID,NAME,D_CODE,D_TITLE,J_CODE
    FROM EMPLOYEE 
    LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)WHERE EMP_ID = '&사번';
    DBMS_OUTPUT.PUT_LINE('사번 : ' || ID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || NAME);
    DBMS_OUTPUT.PUT_LINE('부서코드 : ' || D_CODE);
    DBMS_OUTPUT.PUT_LINE('부서명 : ' || D_TITLE);
    IF J_CODE IN('J1','J2')
    THEN DBMS_OUTPUT.PUT_LINE('임원진입니다.');
    ELSE DBMS_OUTPUT.PUT_LINE('일반 직원입니다.');
    END IF;
END;
/

-- 사번을 입력 받은 후 급여에 따라서 등급을 나누어 출력
-- 출력은 사번, 이름, 급여, 급여등급
DECLARE
    ID EMPLOYEE.EMP_ID%TYPE;
    NAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    SALGRADE CHAR(1);
BEGIN
    SELECT EMP_ID,EMP_NAME,SALARY
    INTO ID,NAME,SAL
    FROM EMPLOYEE WHERE EMP_ID = '&사번';
    DBMS_OUTPUT.PUT_LINE('사번 : ' || ID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || NAME);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || SAL);
    
    IF SAL >= 5000000 THEN SALGRADE := 'A';
    ELSIF SAL >= 3000000 THEN SALGRADE := 'B';
    ELSE SALGRADE := 'C';
    END IF;
    DBMS_OUTPUT.PUT_LINE('급여등급 : ' || SALGRADE);
END;
/