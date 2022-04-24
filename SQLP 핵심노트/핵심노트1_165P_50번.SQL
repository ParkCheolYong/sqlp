-- 결과집합 모두 출력 
-- 주문상품은 월단위 파티션 테이블
-- 한 달 주문상품 100만건
-- 할인유형코드 만족하는데이터 비중 20%
-- 등록된 상품 2만개
-- 2만개 상품을 한 달에 한 개 이상 주문

--[변경전 SQL]
SELECT *
  FROM (SELECT P.상품코드
             , MIN(P.상품명)	상품명
        	 , MIN(P.상품가격)	상품가격
        	 , SUM(O.주문수량)	총주문수량
        	 , SUM(O.주문금액)	총주문금액
          FROM 주문상품 O, 상품 P
         WHERE O.주문일시 >= ADD_MONTHS(SYSDATE, -1)
           AND O.할인유형코드 = 'K890'
           AND P.상품코드 = 0.상품코드
         GROUP BY
               P.상품코드
         ORDER BY 
               총주문금액 DESC
             , 상품코드 	
		)
 WHERE ROWNUM <= 100

 
--[변경후 SQL]
SELECT /*+ LEADING(O) USE_NL(P) */ -- 상위 100개만 조인하므로 NL조인 유도
       P.상품코드
     , P.상품명
	 , P.상품가격
	 , O.총주문수량
	 , O.총주문금액
  FROM (SELECT /*+ FULL(A) */ --ORDER BY가 있는 인라인뷰는 MERGING 될 수 없으므로 NO_MERGE는 불필요
               A.상품코드
             , SUM(A.주문수량) 총주문수량
             , SUM(A.주문금액) 총주문금액
          FROM 주문상품 A
         WHERE A.주문일시 >= ADD_MONTHS(SYSDATE, -1)
           AND A.할인유형코드 = 'K890'
         GROUP BY
               A.상품코드
	     ORDER BY  --상위 100개만 추출해야하므로 인라인뷰 안에 ORDER BY 기술
               총주문금액 DESC
             , 상품코드 		 
	    ) O, 상품 P
 WHERE P.상품코드 = O.상품코드
   AND ROWNUM <= 100 
 ORDER BY   -- NL조인 과정에서 BATCH I/O가 작동할 수 있으므로 ORDER BY 한번 더 명시
       총주문금액 DESC
     , 상품코드 


--[변경후 SQL]배치 IO 방지
SELECT /*+ LEADING(O) USE_NL(P) NO_NLJ_BATCHING(P) */
       P.상품코드
     , P.상품명
	 , P.상품가격
	 , O.총주문수량
	 , O.총주문금액
  FROM (SELECT /*+ FULL(A) */
               A.상품코드
             , SUM(A.주문수량) 총주문수량
             , SUM(A.주문금액) 총주문금액
          FROM 주문상품 A
         WHERE A.주문일시 >= ADD_MONTHS(SYSDATE, -1)
           AND A.할인유형코드 = 'K890'
         GROUP BY
               A.상품코드
	     ORDER BY 
               총주문금액 DESC
             , 상품코드 		 
	    ) O, 상품 P
 WHERE P.상품코드 = O.상품코드
   AND ROWNUM <= 100 
	 	 