SET SERVEROUTPUT ON;

-- 커서(CURSOR) : SELECT 또는 DML과 같은 SQL의 한 컬럼의 결과셋(ResultSet)을 저장하여 필요한 곳에서 활용하기 위한 객체
--      선언(DECLARATION) -> 열기(OPEN) -> 읽기(FETCH) -> 닫기(CLOSE) : 명시적 커서
--      선언(DECLARATION) -> 반복 루프(FOR/LOOP/WHILE...) : 묵시적 커서

-- 명시적 커서(EXPLICIT CURSOR) : 선언 -> 열기 -> 읽기 -> 닫기 등의 순서로 이루어지는 커서
SELECT * FROM emp;

CREATE OR REPLACE PROCEDURE emp_prt1(vpno IN emp.pno%TYPE)
IS
    CURSOR cur_pno
    IS
    SELECT pno, ename, pos, salary FROM emp WHERE pno=vpno;
vvpno emp.pno%TYPE;
vvename emp.ename%TYPE;
vvpos emp.pos%TYPE;
vvsalary emp.salary%TYPE;
BEGIN
    OPEN cur_pno;
    DBMS_OUTPUT.PUT_LINE('****************************');
    DBMS_OUTPUT.PUT_LINE('부서코드   사원명   직급   급여');
    DBMS_OUTPUT.PUT_LINE('****************************');
    LOOP
        FETCH cur_pno INTO vvpno, vvename, vvpos, vvsalary;
        EXIT WHEN cur_pno%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(vvpno || '        ' || vvename || '   '  || vvpos || '   '  || vvsalary || '   ' );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('****************************');
    DBMS_OUTPUT.PUT_LINE('전체건수 : ' || cur_pno%ROWCOUNT);
    CLOSE cur_pno;
END;
/

EXEC emp_prt1(10);

-- 묵시적 커서(IMPLICIT CURSOR)
CREATE OR REPLACE PROCEDURE emp_prt2(vpno IN emp.pno%TYPE)
IS
    CURSOR cur_pno
    IS
    SELECT pno, ename, pos, salary FROM emp WHERE pno=vpno;
vcnt NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('**********************');
    DBMS_OUTPUT.PUT_LINE('부서코드 사원명 직급 급여');
    DBMS_OUTPUT.PUT_LINE('**********************');
    FOR cur IN cur_pno LOOP
        DBMS_OUTPUT.PUT_LINE(cur.pno || '     ' || cur.ename || '   ' || cur.pos || '   ' || cur.salary);
        vcnt := cur_pno%ROWCOUNT;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('**********************');
    DBMS_OUTPUT.PUT_LINE('전체 건수 : ' || vcnt);
END;
/

EXEC emp_prt2(10);

-- 직속코드(SUPERIOR)를 매개변수로 입력받아 입력한 직속코드에 속해 직원의
-- 사원번호(eno), 사원명(ename), 직급(pos), 급여(salary)를 출력하는 cur_super
-- 묵시적 커서(IMPLICIT CURSOR)를 생성하시오.
CREATE OR REPLACE PROCEDURE cur_super(vsup IN emp.superior%TYPE)
IS
    CURSOR cur_sup
    IS
    SELECT eno, ename, pos, salary FROM emp WHERE superior=vsup;
vcnt NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('*************************');
    DBMS_OUTPUT.PUT_LINE('사원코드  사원명  직급  급여');
    DBMS_OUTPUT.PUT_LINE('*************************');
    FOR cur IN cur_sup LOOP
        DBMS_OUTPUT.PUT_LINE(cur.eno || '   ' || cur.ename || '   ' || cur. pos || '   ' || cur.salary);
        vcnt := cur_sup%ROWCOUNT;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('**********************');
    DBMS_OUTPUT.PUT_LINE('전체 건수 : ' || vcnt);
END;
/

EXEC cur_super(2004);

-- 패키지(PACKAGE) : 여러 개의 프로시저 또는 함수 등을 하나의 그룹으로 묶은 묶음.
-- 패키지 선언부(PACKAGE DECLARATION)
CREATE OR REPLACE PACKAGE emp_pack
IS
    PROCEDURE eno_out;
    PROCEDURE ename_out;
    PROCEDURE pno_out;
    PROCEDURE pos_out;
END emp_pack;    
/

-- 패키지 기능 정의부(PACKAGE DEFINE OF FUNCTION)
CREATE OR REPLACE PACKAGE BODY emp_pack 
IS
    CURSOR sw_cur IS SELECT * FROM emp;
    
    PROCEDURE eno_out
    IS
    BEGIN
       DBMS_OUTPUT.PUT_LINE('사원번호');
       DBMS_OUTPUT.PUT_LINE('--------');
       FOR k IN sw_cur LOOP 
          DBMS_OUTPUT.PUT_LINE(k.eno);
       END LOOP;
    END eno_out;
    PROCEDURE ename_out
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('사원명');
        DBMS_OUTPUT.PUT_LINE('------');
        FOR k IN sw_cur LOOP 
            DBMS_OUTPUT.PUT_LINE(k.ename);
        END LOOP;
    END ename_out;
    PROCEDURE pno_out
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('부서번호');
        DBMS_OUTPUT.PUT_LINE('------');
        FOR k IN sw_cur LOOP
            DBMS_OUTPUT.PUT_LINE(k.pno);
        END LOOP;
    END pno_out;
    PROCEDURE pos_out
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('직급');
        DBMS_OUTPUT.PUT_LINE('----');
        FOR k IN sw_cur LOOP 
            DBMS_OUTPUT.PUT_LINE(k.pos);
        END LOOP;
    END pos_out;
END;
/
EXEC emp_pack.ename_out;
EXEC emp_pack.eno_out;
EXEC emp_pack.pno_out;

-- 트리거(TRIGGER) : 특정 상황이나 동작 등을 이벤트라고 할 때, 이벤트가 발생하면,
-- 연쇄동작으로 해당 기능을 자동으로 처리해주는 서브 프로그램의 일종

-- 상품(goods) 테이블
-- 상품코드(pno)   숫자
-- 상품명(pname)   가변문자열, 최대 100 글자
-- 단가(price)     숫자
CREATE TABLE goods(pno NUMBER, pname VARCHAR(100), price NUMBER);

-- 입고(store) 테이블
-- 상품코드(pno)    숫자
-- 수량(amount)    숫자
-- 매입단가(price)  숫자
CREATE TABLE store(pno NUMBER, amount NUMBER, price NUMBER);

-- 출고(release) 테이블
-- 상품코드(pno)    숫자
-- 수량(amount)    숫자
-- 출고단가(price)  숫자
CREATE TABLE release(pno NUMBER, amount NUMBER, price NUMBER);

-- 재고(inventory) 테이블
-- 상품코드(pno)    숫자
-- 수량(amount)    숫자
-- 재고단가(price)  숫자
CREATE TABLE inventory(pno NUMBER, amount NUMBER, price NUMBER);

-- 데이터 추가
-- 상품 등록
INSERT INTO goods VALUES(100, '먹태깡', 2500);
INSERT INTO goods VALUES(200, '꼬북칩', 2000);
INSERT INTO goods VALUES(300, '짜파링', 3000);
INSERT INTO goods VALUES(400, '팅쵹', 2800);
INSERT INTO goods VALUES(500, '감튀', 2600);

SELECT * FROM goods;

-- 입고 처리
INSERT INTO store VALUES(100, 2, 2500);

-- 재고 처리 : 자동처리됨
INSERT INTO inventory VALUES(100, 2, 3500);     -- 출고 시 원래 가격의 40% 마진율
COMMIT;

-- 입고 시 재고 처리 : 입고 테이블에 새로운 레코드가 추가되면, 재고는 증가된다.
-- 만약, 현재 해당 상품의 재고가 없으면, 새로운 상품을 재고를 처리하고,
-- 해당 상품이 기존에 존재하면, 그 제품의 수량과 단가를 적용하여 재고를 처리할 수 있도록 한다.
-- 트리거 이름 : store_trigger
CREATE OR REPLACE TRIGGER store_trigger
AFTER INSERT ON store
FOR EACH ROW
DECLARE
    vcnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO vcnt FROM inventory WHERE pno=:NEW.pno;
    IF vcnt=0 THEN
        INSERT INTO inventory VALUES(:NEW.pno, :NEW.amount, :NEW.price*1.4);
    ELSE
        UPDATE inventory SET amount=amount+:NEW.amount, price=:NEW.price*1.4 WHERE pno=:NEW.pno;
    END IF;
END;
/
SELECT * FROM inventory;
INSERT INTO store VALUES(100, 2, 2500);
INSERT INTO store VALUES(200, 4, 2000);
INSERT INTO store VALUES(400, 5, 2800);

-- 출고 시 재고 처리 : 출고(release) 테이블에 새로운 레코드가 추가되면, 재고는 감소된다.
-- 만약, 현재 해당 상품이 모두 출고되면, 해당 상품의 재고 정보를 삭제하고
-- 해당 상품이 출고되고도 잔존하면, 그 제품의 수량을 적용하여 재고를 처리할 수 있도록 구현
-- 트리거 이름 : release_trigger
CREATE OR REPLACE TRIGGER release_trigger
AFTER INSERT ON release
FOR EACH ROW
DECLARE
    vcnt NUMBER;
BEGIN
    SELECT amount-:NEW.amount INTO vcnt FROM inventory WHERE pno=:NEW.pno;
    IF vcnt=0 THEN
        DELETE FROM inventory WHERE pno=:NEW.pno;
    ELSE
        UPDATE inventory SET amount=amount-:NEW.amount WHERE pno=:NEW.pno;
    END IF;
END;
/

SELECT * FROM release;
INSERT INTO release VALUES(100, 1, 2500);
SELECT * FROM inventory;

-- 반출(recall) 시의 재고 처리 : 입고(store) 테이블에 수량이 감소하면, 재고도 감소된다.
-- 만약, 현재 해당 상품이 모두 반출(recall)되면, 해당 상품의 재고 정보를 삭제하고,
-- 해당 상품이 반출되고도 잔존하면, 그 제품의 수량을 적용하여 재고를 처리할 수 있도록 구현
-- 트리거 이름 : recall_trigger
CREATE OR REPLACE TRIGGER recall_trigger
AFTER UPDATE ON store
FOR EACH ROW
DECLARE
    vcnt NUMBER;
BEGIN
    SELECT amount-:NEW.amount INTO vcnt FROM inventory WHERE pno=:NEW.pno;
    IF vcnt=0 THEN
        DELETE FROM inventory WHERE pno=:NEW.pno;
    ELSE
        UPDATE inventory SET amount=amount-:NEW.amount WHERE pno=:NEW.pno;
    END IF;
END;
/
SELECT * FROM inventory;
SELECT * FROM store;
UPDATE store SET amount=amount-1 WHERE pno=100;

-- 반품(return) 시의 재고 처리 : 출고(release) 테이블에 수량이 감소하면, 재고는 증가된다.
-- 만약, 현재 해당 상품의 재고가 없으면, 해당 상품으로 재고를 처리하고,
-- 해당 상품이 기존에 존재하면, 그 제품의 수량을 적용하여 재고를 처리할 수 있도록 구현
-- 트리거 이름 : return_trigger
CREATE OR REPLACE TRIGGER return_trigger
AFTER UPDATE ON release
FOR EACH ROW
DECLARE
    vcnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO vcnt FROM inventory WHERE pno=:NEW.pno;
    IF vcnt=0 THEN
        INSERT INTO inventory VALUES (:NEW.pno, :NEW.amount, :NEW.price);
    ELSE
        UPDATE inventory SET amount=amount+:NEW.amount, price=:NEW.price*1.4 WHERE pno=:NEW.pno;
    END IF;
END;
/
select * from inventory;
UPDATE release SET amount=amount-2 WHERE pno=100;