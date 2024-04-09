drop table emp;

-- 사원(emp) 테이블 작성
create table emp (eno int, ename varchar(20), pno int, pos varchar(10), pcode varchar(7), addr varchar(100), salary int, bonus int, regdate date, gender int);

-- 컬럼 추가
alter table emp add (superior int, tel varchar(13));

-- 컬럼 숨기기
alter table emp modify salary invisible;
alter table emp modify bonus invisible;
alter table emp modify regdate invisible;
alter table emp modify gender invisible;
alter table emp modify superior invisible;

-- 컬럼 보이기
alter table emp modify salary visible;
alter table emp modify bonus visible;
alter table emp modify regdate visible;
alter table emp modify gender visible;
alter table emp modify superior visible;

-- 데이터 추가
insert into emp values(2001, '수민', 10, '부장', '125-365', '서울 용산구', '02-985-1254', 3500000, 1000000, '1980-12-01', 1, null);
insert into emp values(2002, '시은', 10, '대리', '354-865', '서울 강남구', '02-865-1245', 4000000, null, '2000-01-25', 1, 2004);
insert into emp values(2003, '아이사', 20, '사원', '587-456', '부산 해운대구', '051-256-9874', 2500000, 1000000, '2002-05-24', 2, 2002);
insert into emp values(2004, '세은', 30, '과장', '987-452', '서울 강남구', '02-333-6589', 5000000, null, '1997-03-22', 2, 2001);
insert into emp values(2005, '윤', 10, '대리', '123-322', '서울 성동구', '02-888-9564', 3000000, 1000000, '1999-07-15', 2, 2004);
insert into emp values(2006, '재이', 20, '사원', '154-762', '서울 송파구', '02-3369-9874', 2000000, null, '2003-05-22', 2, 2005);
insert into emp values(2007, '최유진', 30, '대리', '367-985', '서울 영등포구', '02-451-2563', 3000000, 1000000, '2006-01-25', 2, 2004);
insert into emp values(2008, '샤오팅', 40, '사원', '552-126', '서울 중구', '02-447-3526', 2400000, null, '2001-02-02', 2, 2007);
insert into emp values(2009, '마시로', 10, '사원', '315-276', '서울 종로구', '02-123-1278', 2500000, 1000000, '2009-04-17', 2, 2002);
insert into emp values(2010, '김채현', 20, '사원', '485-172', '서울 성북구', '02-478-1235', 2450000, 800000, '2009-12-15', 2, 2004);

select * from emp;

-- 절차적 언어(Procedural Language)의 SQL => PL/SQL
-- SQL 구문을 하나의 명령 블록으로 구성하여 필요 시 호출하여 사용하며, IF, LOOP, FOR 등을 활용하여 더 효과적으로 SQL을 활용할 수 있다.
-- 프로시저(Procedure), 함수(Function), 트리거(Trigger)

-- PL 실행 결과 출력문 활성화
SET SERVEROUTPUT ON;

-- CHR(9) : 띄어쓰기
-- CHR(10) : 한 줄씩
DECLARE
    TYPE firsttype IS RECORD(a emp.ename%TYPE, b emp.pos%TYPE, c emp.salary%TYPE);
cus1 firsttype;
BEGIN
    SELECT ename, pos, salary INTO cus1 FROM emp where eno=2001;
    DBMS_OUTPUT.PUT_LINE('****************************************************');
    DBMS_OUTPUT.PUT_LINE(cus1.a || CHR(10) || cus1.b || CHR(10) || cus1.c);
    DBMS_OUTPUT.PUT_LINE('현재 계정 : ' || USER);
    DBMS_OUTPUT.PUT_LINE('현재 질의 시간 : ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:MM:SS'));
END;

-- 익명의 프로시저를 활용하여 사원 테이블로 부터 사원번호 2002인 사원의
-- 사원번호, 사원명, 직급, 주소, 입사일을 출력하시오.
DECLARE
    sawon emp%ROWTYPE;
BEGIN
    SELECT * INTO sawon FROM emp where eno=2002;
    DBMS_OUTPUT.PUT_LINE('****************************************************');
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || sawon.eno);
    DBMS_OUTPUT.PUT_LINE('사원명 : ' || sawon.ename);
    DBMS_OUTPUT.PUT_LINE('직급 : ' || sawon.pos);
    DBMS_OUTPUT.PUT_LINE('주소 : ' || sawon.addr);
    DBMS_OUTPUT.PUT_LINE('입사일 : ' || TO_CHAR(sawon.regdate, 'YYYY-MM-DD'));
END;

-- 익명의 반복 프로시저 실습
-- 대입할 때 := 사용
DECLARE
    TYPE ename_type IS TABLE OF emp.ename%TYPE INDEX BY BINARY_INTEGER;
    TYPE pos_type IS TABLE OF emp.pos%TYPE INDEX BY BINARY_INTEGER;
    ename_col ename_type;
    pos_col pos_type;
    i BINARY_INTEGER := 0;
BEGIN
    FOR k IN(SELECT ename, pos FROM emp) LOOP
        i := i + 1;
        ename_col(i) := k.ename;
        pos_col(i) := k.pos;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('***************');
    DBMS_OUTPUT.PUT_LINE('사원명      직급');
    DBMS_OUTPUT.PUT_LINE('***************');
    FOR j IN 1..i LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(ename_col(j), 12) || RPAD(pos_col(j), 10));
    END LOOP;
END;

-- 사원번호(eno)와 급여(salary)를 매개변수로 입력받아 해당 사원의 급여를 갱신하는 프로시저(update_pay)를 작성하여라
CREATE OR REPLACE PROCEDURE update_pay(u_eno IN INT, u_salary IN INT)
IS
BEGIN
    UPDATE emp SET salary=u_salary WHERE eno=u_eno;
    COMMIT;
END update_pay;

EXEC update_pay(2001, 5000000);
EXEC update_pay(2006, 2800000);

select * from emp;

-- 사원번호(eno)와 직급(pos), 주소(addr)를 입력받아 갱신하는 프로시저(update_emp)를 작성하고,
-- 임의의 데이터로 3건 이상 실행하도록 하시오.
CREATE OR REPLACE PROCEDURE update_emp(u_eno IN emp.eno%TYPE, u_pos IN emp.pos%TYPE, u_addr IN emp.addr%TYPE)
IS
BEGIN
    UPDATE emp SET pos=u_pos, addr=u_addr WHERE eno=u_eno;
    COMMIT;
END update_emp;

EXEC update_emp(2002, '과장', '서울 중구');
EXEC update_emp(2008, '대리', '서울 강북구');
EXEC update_emp(2010, '대리', '경기도 용인시');

select * from emp;

-- 함수(Function)
-- 사원번호(eno)를 매개변수로 입력받아 특정 직원의 세금(3.3%)을 계산하여 출력하는 함수(tax_fnc)를 작성하고 실행하시오.
-- 임의로 3건의 실행문을 실행하고, 그 결과를 출력하시오.
CREATE OR REPLACE FUNCTION tax(v_eno IN emp.eno%TYPE)
RETURN NUMBER
IS
    v_tax NUMBER;
BEGIN
    SELECT (salary+NVL(bonus, 0))*0.033 INTO v_tax FROM emp WHERE eno=v_eno;
    RETURN v_tax;
END tax;
/

-- 실행 방법1
DECLARE
    v_tax NUMBER;
BEGIN
    v_tax := tax(2001);
    DBMS_OUTPUT.PUT_LINE('세금 : ' || v_tax);
END;

-- 실행 방법2
select tax(2001) as "세금" from dual;

-- 실행 방법3
select distinct tax(2001) as "세금" from emp;

-- 직급(pos)을 매개변수로 입력 받아 해당 직급별 급여 총액, 평균 급여, 인원수를 출력하는
-- 프로시저(tot_emp)를 작성하시오.
CREATE OR REPLACE PROCEDURE tot_emp(v_pos IN emp.pos%TYPE)
IS
    a NUMBER := 0;
    b NUMBER(12,0) := 0;
    c NUMBER := 0;
BEGIN
    SELECT SUM(salary+NVL(bonus,0)), AVG(salary+NVL(bonus,0)), COUNT(*) INTO a,b,c FROM emp WHERE emp.pos=v_pos;
    DBMS_OUTPUT.PUT_LINE('급여 총액 : ' || a || '원');
    DBMS_OUTPUT.PUT_LINE('평균 급여 : ' || b || '원');
    DBMS_OUTPUT.PUT_LINE('인원수 : ' || c || '명');
END;

EXEC tot_emp('사원');

-- 사원을 추가하는 프로시저(ins_emp)를 작성하시오.
-- (단, 추가하는 데이터는 임의로 할 것.)
CREATE OR REPLACE PROCEDURE ins_emp(i_eno IN emp.eno%TYPE, i_ename IN emp.ename%TYPE, i_pos IN emp.pos%TYPE, i_salary IN emp.salary%TYPE)
IS
BEGIN
    INSERT INTO emp (eno, ename, pos, salary) VALUES(i_eno, i_ename, i_pos, i_salary);
    COMMIT;
END ins_emp;

EXEC ins_emp(2011, '강산', '사원', 3300000);
select * from emp;

-- 사원번호(eno)를 매개변수로 입력받아 해당 직원에 대한 퇴사 처리를 하는 프로시저(del_emp)
-- (작성된 del_emp 프로시저에서 단, 매개값으로 사원번호가 2001인 사원을 진행할 것.)
CREATE OR REPLACE PROCEDURE del_emp(d_eno IN emp.eno%TYPE)
IS
BEGIN
    DELETE FROM emp WHERE emp.eno=d_eno;
    COMMIT;
END del_emp;
/
EXEC del_emp(2001);
EXEC del_emp(2011);
select * from emp;