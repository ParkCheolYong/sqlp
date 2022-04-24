--병렬쿼리 튜닝

--[인덱스]
--주문_PK : 고객번호 + 주문일자 + 주문순번

--[변경전 SQL]
ALTER SESSION ENABLE PARALLEL DML;

UPDATE /*+ PARALLEL(주문 4) */ 주문
   SET 주문일련번호 = ROWNUM
 WHERE 주문일자 = TO_CHAR(SYSDATE, 'YYYYMMDD');
 
--[변경후 SQL]
MERGE /*+ FULL(T1) PARALLEL(T1 4) */INTO 주문 T1
USING (SELECT /*+ FULL(주문) PARALLEL(주문 4) */
              고객번호, 주문순번
            , ROW_NUMBER() OVER(ORDER BY 고객번호,주문순번) AS 주문일련번호 --ROWNUM을 병렬프로세스가 처리하면 중복값이 생겨 UNIQUE한 값 생성을 위해 QC가 처리함 -> 병목현상 발생 -> ROW_NUMBER함수 사용
         FROM 주문
		WHERE 주문일자 = TO_CHAR(SYSDATE, 'YYYYMMDD')) T2 ON (   T1.고객번호 = T2.고객번호
		                                                   AND T1.주문일자 = TO_CHAR(SYSDATE, 'YYYYMMDD')
														   AND T1.주문순번 = T2.주문순번)
WHEN MATCHED THEN UPDATE
 SET T1.주문일련번호 = T2.주문일련번호;														   
		