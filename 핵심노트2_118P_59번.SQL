--[문제점]
--SQL을 10번 실행하면서 같은범위(10만건)의 데이터를 반복 액세스
--조회 대상집합이 계속 증가하는 상황에서 데이터를 10번에 나눠 실행함으로써 ERRLOG테이블에 입력한 결과집합의 일관성 훼손
--SELECT와 DELETE 사이에 입력하S RSTLOG 데이터는 ERRLOG 입력 대상인지 확인하지 않은채 삭제

--[개선안]
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO ERRLOG
SELECT /*+ LEADING(A) USE_NL(B) */
       TO_CHAR(SYSDATE, 'YYYYMMDDHH24') AS CH_DTH
	 , 'E' || LPAD(NO, 2, '0') AS ERRCD
	 , RNO
  FROM RSTLOG A
     , (SELECT ROWNUM AS NO FROM DUAL CONNECT BY LEVEL <= 10) B
 WHERE (   ST01 = 'A'
        OR ST02 = 'B'
		OR ST03 = 'C'
		OR ST04 = 'D'
		OR ST05 = 'E'
		OR ST06 = 'F'
		OR ST07 = 'G'
		OR ST08 = 'H'
		OR ST09 = 'I'
		OR ST10 = 'J')	 
   AND B.NO IN (  (CASE WHEN ST01 = 'A' THEN 1 END)		
                , (CASE WHEN ST02 = 'B' THEN 2 END)
				, (CASE WHEN ST03 = 'C' THEN 3 END)
				, (CASE WHEN ST04 = 'D' THEN 4 END)
				, (CASE WHEN ST05 = 'E' THEN 5 END)
				, (CASE WHEN ST06 = 'F' THEN 6 END)
				, (CASE WHEN ST07 = 'G' THEN 7 END)
				, (CASE WHEN ST08 = 'H' THEN 8 END)
				, (CASE WHEN ST09 = 'I' THEN 9 END)
				, (CASE WHEN ST10 = 'J' THEN 10 END));

DELETE FROM RSTLOG;

COMMIT;				

