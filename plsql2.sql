-- 원의 반지름을 입력받아 원주율(3.1415)를 반영하여 넓이를 구하는 함수(circle_fnc)를 작성하시오.
CREATE OR REPLACE FUNCTION circle_fnc(r IN NUMBER)
RETURN NUMBER
IS
    circle NUMBER;
BEGIN
    circle := r*r*3.1415;
    RETURN circle;
END circle_fnc;
/
DECLARE
    circle NUMBER;
BEGIN
    circle := circle_fnc(10);
    DBMS_OUTPUT.PUT_LINE('원의 넓이 : ' || circle);
END;

-- 너비(w), 높이(h), 깊이(d)를 매개변수로 입력받아 직육면체의 부피를 구하는 함수(box_vol)를 작성하고, 실행하시오.
CREATE OR REPLACE FUNCTION box_vol(w IN NUMBER, h IN NUMBER, d IN NUMBER)
RETURN NUMBER
IS
    vol NUMBER;
BEGIN
    vol := w*h*d;
    RETURN vol;
END box_vol;
/
DECLARE
    vol NUMBER;
BEGIN
    vol := box_vol(3, 4, 5);
    DBMS_OUTPUT.PUT_LINE('부피 : ' || vol);
END;

-- 사원(emp) 테이블로부터 근무기간(y년 x개월)을 계산하는 함수(workdays_fnc)를 작성하시오.
-- (단, 입사일(regdate)을 입력받아 MONTH_BETWEEN 함수를 사용하여 년수와 개월수를 구할 수 있도록 할 것.)
-- (실행 시에는 사원명(ename)과 근무기간(y년 x개월)이 출력되도록 할 것.)
-- MONTHS_BETWEEN(나중날짜, 먼저날짜) : 흐른 개월 수 계산
-- FLOOR(숫자) : 소수점 이하 버림
-- 년수 구하기 : FLOOR(MONTHS_BETWEEN(SYSDATE, 입사일)/12)
-- 잔여 개월 수 구하기 : FLOOR(MOD(MONTHS_BETWEEN(SYSDATE, 입사일), 12))
CREATE OR REPLACE FUNCTION workdays_fnc(w_regdate IN DATE)
RETURN VARCHAR2
IS
    workdate VARCHAR2(40);
BEGIN
    workdate := FLOOR(MONTHS_BETWEEN(SYSDATE, w_regdate)/12) || '년 ' ||
     FLOOR(MOD(MONTHS_BETWEEN(SYSDATE, w_regdate), 12)) || '개월';
    RETURN workdate;
END workdays_fnc;

SELECT ename, workdays_fnc(regdate) AS "근무기간" FROM emp;

-- 사원(emp) 테이블에서 성별코드(gender)를 이용하여 성별을 구하는 함수(gender_fnc)를 작성하고, 실행하시오.
-- 단, 성별코드(gender)가 1 이거나 3 이면, '남' 이고, 아니면, '여' 이다.
-- 실행결과는 사원명, 성별 컬럼이 출력될 수 있도록 하시오
CREATE OR REPLACE FUNCTION gender_fnc(vgender IN emp.gender%TYPE)
RETURN VARCHAR2
IS
    egender VARCHAR2(10);
BEGIN
    IF vgender IN (1, 3) THEN
        egender := '남';
    ELSE
        egender := '여';
    END IF;
    RETURN egender;
END;
/

-- IS gcode VARCHAR(4)
-- gcode := SUBSTR(jumin, 8, 1) 성별코드가 주민번호에서 8번째 글자 1글자인 경우
-- IF gcode IN ('1', '3') THEN
SELECT ename, gender_fnc(gender) AS "성별" FROM emp;

-- 사원(emp) 테이블에서 급여(salary)를 이용하여 급여등급을 구하는 함수(grade_emp)를 작성하고, 실행하시오.
-- 단, 급여가 4,500,000 이상이면, 'A' / 3,500,000 이상이면, 'B' / 3,000,000 이상이면, 'C' / 나머지는 'D'
-- 실행결과는 사원코드, 사원명, 급여등급, 급여 순으로 출력될 수 있도록 하시오. (IF THEN~ELSIF THEN~ELSE)
CREATE OR REPLACE FUNCTION grade_emp(vsalary IN NUMBER)
RETURN VARCHAR2
IS
    grade VARCHAR2(10);
BEGIN
    IF vsalary >= 4500000 THEN
        grade := 'A';
    ELSIF vsalary >= 3500000 THEN
        grade := 'B';
    ELSIF vsalary >= 3000000 THEN
        grade := 'C';
    ELSE
        grade := 'D';
    END IF;
    RETURN grade;
END;
/
SELECT eno AS "사원코드", ename AS "사원명", grade_emp(salary) AS "급여등급", salary AS "급여" FROM emp;

-- loop_test 테이블 생성
-- 번호(no) 숫자
-- 이름(name) 가변 문자열 20글자, 기본값 '김기태'
CREATE TABLE loop_table(no NUMBER, name VARCHAR(20) DEFAULT '김기태');

-- LOOP 문을 활용하여 번호를 증가식으로 자동 채우면서 20개의 레코드를 추가될 수 있도록 반복할 것
-- 번호는 1~20
DECLARE
    vcnt NUMBER(2) := 1;
BEGIN
    LOOP
        INSERT INTO loop_table(NO) VALUES(vcnt);
        vcnt := vcnt+1;
        EXIT WHEN vcnt>20;
        COMMIT;
    END LOOP;
END;

SELECT * FROM loop_table;

-- FOR IN LOOP 문을 활용하여 번호를 증가식으로 자동 채우면서 10개의 레코드를 추가될 수 있도록 반복할 것
-- 번호는 21~30, 프로시저 이름 : loop2
CREATE OR REPLACE PROCEDURE loop2
IS
BEGIN
    FOR i IN 21..30 LOOP
        INSERT INTO loop_table(NO) VALUES(i);
        COMMIT;
    END LOOP;
END;
/

EXEC loop2;
SELECT * FROM loop_table;

-- WHILE LOOP 문을 활용하여 번호를 증가식으로 자동 채우면서 10개의 레코드를 추가될 수 있도록 반복할 것
-- 번호는 31~40, 프로시저 이름 : loop3
CREATE OR REPLACE PROCEDURE loop3
IS
    vcnt NUMBER(2) := 31;
BEGIN
    WHILE vcnt<=40 LOOP
        INSERT INTO loop_table(NO) VALUES(vcnt);
        vcnt := vcnt+1;
        COMMIT;
    END LOOP;
END;
/
EXEC loop3;
SELECT * FROM loop_table;

-- 예외처리 프로시저 exc_test
CREATE OR REPLACE PROCEDURE exc_test
IS
    sw emp%ROWTYPE;
BEGIN
    SELECT * INTO sw FROM emp WHERE eno=2001;
    DBMS_OUTPUT.PUT_LINE('데이터 검색 성공');
    COMMIT;
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('데이터가 너무 많습니다.');
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('데이터가 없습니다.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('기타 오류로 인해 정상처리 되지 못했습니다.');
END;
/

EXEC exc_test;