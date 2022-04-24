--문제점
--1. TO_CHAR(입금일시, 'YYYMMDD') 인덱스 컬럼 변경으로 인한 INDEX RANGE SCAN 불가
--2. TO_NUMBER(수납일자) = 20210329 조건에 자동 형변환으로 인한 INDEX RANGE SCAN 불가
--3. LITERAL SQL로 인해 하드파싱 부하
--4. 절차적 루프 처리에 의한 반복적인 데이터베이스 CALL
--5. 루프 내에서 건건이 커밋


MERGE INTO 수납 X
USING (SELECT 고객ID, SUM(입금액) 입금액
         FROM 은행입금내역
		WHERE 입금일시 BETWEEN TO_DATE('20210329', 'YYYYMMDD') AND TO_DATE('20210330', 'YYYYMMDD') - 1/24/60/60
		GROUP BY 고객ID) Y ON (X.고객ID = Y.고객ID AND X.수납일자 = '20210329')
WHEN MATCHED THEN UPDATE		
 SET X.수납금액 = Y.입금액

WHEN NOT MATCHED THEN
INSERT (고객ID, 수납일자, 수납금액) VALUES (Y.고객ID, '20210329', Y.입금액);

COMMIT;

