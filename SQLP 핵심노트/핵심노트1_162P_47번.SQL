-- 결과집합 모두 출력 
-- 주문상품은 비파티션 테이블
-- 한 달 주문상품 100만건
-- 할인유형코드 만족하는데이터 비중 20%
-- 등록된 상품 2만개
-- 2만개 상품을 고르게 주문


--[변경전 SQL]
SELECT P.상품코드
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


--[변경후 SQL]HASH JOIN 유도
SELECT /*+ LEADING(P) USE_HASH(O) INDEX(O 주문상품_X1) FULL(P) */
       P.상품코드
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
	 


--[변경후 SQL]GROUP BY로 조인횟수 감소
SELECT /*+ LEADING(O) USE_HASH(P) FULL(P) */
       P.상품코드
     , P.상품명
	 , P.상품가격
	 , O.총주문수량
	 , O.총주문금액
  FROM (SELECT /*+ INDEX(A 주문상품_X1) NO_MERGE */
               A.상품코드
             , SUM(A.주문수량) 총주문수량
             , SUM(A.주문금액) 총주문금액
          FROM 주문상품 A
         WHERE A.주문일시 >= ADD_MONTHS(SYSDATE, -1)
           AND A.할인유형코드 = 'K890'
         GROUP BY
               A.상품코드) O, 상품 P
 WHERE P.상품코드 = O.상품코드			   
 ORDER BY 
       총주문금액 DESC
     , 상품코드 		 

	 
/*******************
--인덱스 재구성
--주문상품_X1 : 할인유형코드 + 주문일시
*******************/	 