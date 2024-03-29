--온라인트랜잭션 발생하지 않는 시간에 원격 RDS시스템으로부터 1000만건 정도 데이터를 읽어서 INSERT하는 배치 프로그램 성능개선
--UPDATE문에서 C1조건 만족하는 데이터 90%이상
--MYTAB 테이블의 PK는 DT+ID
--병렬처리 활용 불가

--[변경전 SQL]
CREATE TABLE MYTAB_TEMP
    AS
SELECT C0 AS ID, C1, C2, C3, C4
  FROM YOURTAB@RDS
 WHERE 1=2;
 
ALTER TABLE MYTAB_TEMP ADD CONSTRAINT MYTAB_TEMP_PK PRIMARY KEY(ID);

DECLARE V_CNT NUMBER;
BEGIN
   INSERT INTO MYTAB_TEMP
   SELECT C0, C1, C2, C3, C4
     FROM YOURTAB@RDS
	WHERE C0 IS NOT NULL
	  AND C5 >0;
	  
UPDATE MYTAB_TEMP SET C4 = C4 + 1 WHERE C1 < TRUNC(SYSDATE);

--배치 프로그램을 재실행할 경우를 대비하기 위한 DELETE(보통 0건 삭제)
DELETE FROM MYTAB WHERE DT = TO_CHAR(SYSDATE, 'YYYYMMDD');

INSERT INTO MYTAB (DT, ID, C1, C2, C3, C4)
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD'), A.*
  FROM MYTAB_TEMP A;

V_CNT := SQL%ROWCOUNT;
INSERT_LOG(SYSDATE, 'INSERT MYTAB_TEMP', 'SUCCESS', V_CNT || ' ROWS')

COMMIT;

EXCEPTION WHEN dup_val_on_index
INSERT_LOG(SYSDATE, 'INSERT MYTAB_TEMP', 'FAIL', '중복 데이터')

END;
/

DROP TABLE MYTAB_TEMP;

--[변경후 SQL]
CREATE TABLE MYTAB_TEMP NOLOGGING -- REDO로그 생성하지 않음
    AS
SELECT C0 AS ID, C1, C2, C3
     , (CASE WHEN C1 < TRUNC(SYSDATE) THEN C4 + 1 ELSE C4 END) AS C4 --TEMP테이블 생성할때 변경된 값 입력
  FROM YOURTAB@RDS
 WHERE C0 IS NOT NULL
   AND C4 > 0;
 
--ALTER TABLE MYTAB_TEMP ADD CONSTRAINT MYTAB_TEMP_PK PRIMARY KEY(ID); PK제약 생성 후 INSERT하면 성능이 느려지므로 ID 중복 확인 후에 테이블에 입력함

DECLARE V_CNT NUMBER;
BEGIN
   /*INSERT INTO MYTAB_TEMP
   SELECT C0, C1, C2, C3, C4
     FROM YOURTAB@RDS
	WHERE C0 IS NOT NULL
	  AND C5 > 0;*/

--ID 중복 확인	  
SELECT COUNT(*) INTO V_CNT
  FROM (SELECT ID
          FROM MYTAB_TEMP
		 GROUP BY ID
		 HAVING COUNT(*) > 1);	  
	  
--UPDATE MYTAB_TEMP SET C4 = C4 + 1 WHERE C1 < TRUNC(SYSDATE);

----배치 프로그램을 재실행할 경우를 대비하기 위한 DELETE(보통 0건 삭제)
--DELETE FROM MYTAB WHERE DT = TO_CHAR(SYSDATE, 'YYYYMMDD');

IF V_CNT > 0 THEN
   INSERT_LOG(SYSDATE, 'INSERT MYTAB_TEMP', 'FAIL', '중복 데이터')
ELSE   
   DELETE FROM MYTAB WHERE DT = TO_CHAR(SYSDATE, 'YYYYMMDD');
   
INSERT INTO MYTAB (DT, ID, C1, C2, C3, C4)
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD'), A.*
  FROM MYTAB_TEMP A;

V_CNT := SQL%ROWCOUNT;
INSERT_LOG(SYSDATE, 'INSERT MYTAB_TEMP', 'SUCCESS', V_CNT || ' ROWS')

COMMIT;

--EXCEPTION WHEN dup_val_on_index
--INSERT_LOG(SYSDATE, 'INSERT MYTAB_TEMP', 'FAIL', '중복 데이터')

END;
/

DROP TABLE MYTAB_TEMP;