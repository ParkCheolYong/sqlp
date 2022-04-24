--1시간 주기 배치프로그램 튜닝 (평균 업데이트 8만건)

--[데이터]
--상품재고 10만개
--상품재고이력 8800만개

--[인덱스]
--상품재고_PK : 상품번호
--상품재고이력_PK : 상품번호 + 변경일자 + 변경순번

--[변경전 SQL]
UPDATE 상품재고 T
   SET T.품절유지일 = NVL((SELECT TRUNC(SYSDATE) - TO_DATE(MAX(A.변경일자), 'YYYYMMDD')
                          FROM 상품재고이력 A, 상품재고 B
						 WHERE A.상품번호 = B.상품번호
						   AND B.업체코드 = 'Z'
						   AND B.가용재고량 = 0
						   AND NVL(B.가상재고수량, 0) <= 0
						   AND A.상품번호 = T.상품번호
						 GROUP BY
						       A.상품번호)
				       , T.품절유지일)
 WHERE T.업체코드 = 'Z'
   AND T.가용재고량 = 0
   AND NVL(T.가상재고수량, 0) <= 0

--1안
UPDATE /*+ LEADING(T) */상품재고 T
   SET T.품절유지일 = (SELECT TRUNC(SYSDATE) - TO_DATE(MAX(A.변경일자), 'YYYYMMDD')
                      FROM 상품재고이력 A
					 WHERE A.상품번호 = T.상품번호)
 WHERE T.업체코드 = 'Z'
   AND T.가용재고량 = 0
   AND NVL(T.가상재고수량, 0) <= 0  
   AND EXISTS (SELECT /*+ UNNEST NL_SJ */'X'
                 FROM 상품재고이력
				WHERE 상품번호 = T.상품번호)   

--2안
MERGE INTO 상품재고 X 
USING (SELECT /*+ LEADING(A) USE_NL(B) NO_MERGE(B) PUSH_PRED(B) */
              A.상품번호, B.신규_품절유지일
         FROM 상품재고 A
            , (SELECT 상품번호
			        , (TRUNC(SYSDATE) - TO_DATE(MAX(변경일자), 'YYYYMMDD')) 신규_품절유지일
                 FROM 상품재고이력 
				GROUP 상품번호) B
		WHERE A.업체코드 = 'Z'
          AND A.가용재고량 = 0
		  AND NVL(A.가상재고수량, 0) <= 0	
		  AND A.상품번호 = B.상품번호
		  AND A.품절유지일 <> B.신규_품절유지일) Y ON (X.상품번호 = Y.상품번호)
WHEN MATCHED THEN UPDATE
 SET X.품절유지일 = Y.품절유지일;		  
   		  
				
							
							
							
							
							
							
							
							
							
							
							