--------------------------------------------------------------------------------
/*
    03.17(수) 복습
*/
--------------------------------------------------------------------------------
SELECT * FROM EMPLOYEE; -- DEPT_CODE
SELECT * FROM DEPARMENT; -- DEPT_ID

SELECT EMP_NAME, DEPT_CODE, DEPT_TITLE
FROM EMPLOYEE
JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID);

SELECT * FROM EMPLOYEE; -- JOB_CODE
SELECT * FROM JOB; -- JOB_CODE

SELECT EMP_NAME, JOB_CODE, JOB_NAME
FROM EMPLOYEE
JOIN JOB USING (JOB_CODE);

SELECT * FROM EMPLOYEE;
SELECT * FROM DEPARTMENT;
SELECT * FROM LOCATION;

SELECT EMP_NAME, DEPT_CODE, DEPT_TITLE
FROM EMPLOYEE
JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
JOIN LOCATION ON (LOCAL_CODE = LOCATION_ID);
--------------------------------------------------------------------------------
/*
     03.17(수) 수업
*/
--------------------------------------------------------------------------------
/* [ SET OPERATOR ] */

-- 부서코드가 D5인 직원 사번, 이름, 부서코드, 급여 출력
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5';
-- 급여가 300만원 이상인 직원의 사번, 이름, 부서코드, 급여 출력
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= 3000000;
-- 대북혼 / 심봉선 중복

-- 1.  UNION : (합집합) : 두 조회결과를 중복된 데이터를 제외하고 합침 + 첫번쨰 컬럼으로 정렬
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5'
UNION
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= 3000000;

-- 2. UNION ALL(합집합) : 중복데이터 포함, 정렬 X
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5'
UNION ALL
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= 3000000;

-- 3. INTERSECT(교집합) : 여러개의 SELECT 결과 중 공통부분만 출력
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5'
INTERSECT
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= 3000000;

-- 4. MINUS(차집합) : 선행 SELECT에서 다음 SELECT와 겹치치 않는 부분만 출력
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5'
MINUS
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= 3000000;
--------------------------------------------------------------------------------
/*
    [ SUB QUERY ]
*/

-- 전직원의 평균 급여
SELECT FLOOR(AVG(SALARY)) FROM EMPLOYEE;
-- 직원중에 적진원 평균급여보다 급여가 많은 사람의 이름 조회
SELECT EMP_NAME FROM EMPLOYEE WHERE SALARY > 3047662;
SELECT EMP_NAME FROM EMPLOYEE WHERE SALARY > (SELECT FLOOR(AVG(SALARY)) FROM EMPLOYEE);

-- 1. 단일행 서브쿼리
-- 서브쿼리 조회결과가 (1행 1열) -> 1개의 단일값

-- 전지연 직원의 관리자 이름을 출력
-- 1) 전지연 직원의 매니저아이디 조회
SELECT MANAGER_ID FROM EMPLOYEE WHERE EMP_NAME = '전지연';
-- 2) 조회된 아이디를 활용해서 매니저 이름 조회
SELECT EMP_NAME FROM EMPLOYEE WHERE EMP_ID = 214;

-- SUBQUERY 풀이
SELECT EMP_NAME FROM EMPLOYEE WHERE EMP_ID = (SELECT MANAGER_ID FROM EMPLOYEE WHERE EMP_NAME = '전지연');
-- JOIN 풀이
SELECT E2.EMP_NAME
FROM EMPLOYEE E1
JOIN EMPLOYEE E2 ON (E1.MANAGER_ID = E2.EMP_ID)
WHERE E1.EMP_NAME = '전지연';

-- 2. 다중행 서브쿼리 : 서브쿼리 조회결과가 행이 여러개인경우
-- 송종기 OR 박나라가 속한 부서에 있는 사원들의 전체 정보
-- 송중기가 속한 부서코드
SELECT DEPT_CODE FROM EMPLOYEE WHERE EMP_NAME = '송종기';
-- 박나라가 속한 부서코드
SELECT DEPT_CODE FROM EMPLOYEE WHERE EMP_NAME = '박나라';
SELECT DEPT_CODE FROM EMPLOYEE WHERE EMP_NAME IN ('송종기','박나라');

SELECT EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE IN (SELECT DEPT_CODE FROM EMPLOYEE WHERE EMP_NAME IN ('송종기','박나라'));

SELECT EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE NOT IN (SELECT DEPT_CODE FROM EMPLOYEE WHERE EMP_NAME IN ('송종기','박나라'));
--------------------------------------------------------------------------------