-- 결과집합 일부(보통 상위 100개) 출력 
-- 주문상품은 비파티션 테이블
-- 한 달 주문상품 100만건
-- 할인유형코드 만족하는데이터 비중 10%
-- 등록된 상품 50만개 / 속성 500개
-- 대부분 상품을 한 달에 한 개 이상 주문

--[변경전 SQL]
SELECT P.상품코드
     , MIN(P.상품명)	상품명
	 , MIN(P.등록일시) 등록일시	 
	 , MIN(P.상품가격)	상품가격
	 , MIN(P.공급자ID) 공급자ID
	 , SUM(O.주문수량)	총주문수량
	 , SUM(O.주문금액)	총주문금액
  FROM 주문상품 O, 상품 P
 WHERE O.주문일시 >= ADD_MONTHS(SYSDATE, -1)
   AND O.할인유형코드 = 'K890'
   AND P.상품코드 = 0.상품코드
 GROUP BY
       P.상품코드
 ORDER BY 
       등록일시 DESC


--[변경후 SQL]
SELECT /*+ LEADING(P) USE_NL(O) INDEX_DESC(P 상품_X1) */ --소트연산 생략을 위해 등록일시 역순으로 스캔
       P.상품코드
     , P.상품명
	 , P.등록일시
	 , P.상품가격
	 , P.공급자ID
	 , O.총주문수량
	 , O.총주문금액
  FROM (SELECT /*+ NO_MERGE PUSH_PRED INDEX(A 주문상품_X2) */ --GROUP BY로 조인횟수 감소, 부분범위 처리를 위해 조인조건 PUSH_PRED 힌트사용
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
       P.등록일시 DESC 	

--인덱스 재구성
--상품_X1 : 등록일시
--주문상품_X2 : 상품코드 + 할인유형코드 + 주문일시	   