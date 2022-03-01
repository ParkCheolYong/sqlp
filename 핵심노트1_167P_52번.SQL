-- 결과집합 일부(보통 상위 100개) 출력 
-- 주문상품은 월 단위 파티션 테이블
-- 한 달 주문상품 100만건
-- 할인유형코드 만족하는데이터 비중 10%
-- 등록된 상품 50만개 / 속성 500개
-- 할인유형코드 = 'K890' 조건으로 판매되는 상품 5000개


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
SELECT /*+ LEADING(O) USE_NL(P) NO_NLJ_BATCHING(P) */
       P.상품코드
     , P.상품명
	 , P.등록일시
	 , P.상품가격
	 , P.공급자ID
	 , O.총주문수량
	 , O.총주문금액
  FROM (SELECT /*+ FULL(A) INDEX_FFS(B) LEADING(B) USE_HASH(A)*/ 
               -- 할인유형코드 = 'K890' 조건으로 판매되는 상품 5000개라 GROUP BY 한 집합과 조인을 할 수도 있지만 상품이 50만건이라 NL조인은 느림
			   -- 그렇다고 GROUP BY후에 HASH조인을 하면 50만개 모두 해시맵에 올려야해서 PGA공간이 부족할 수 있음
			   -- 등록일시 + 상품코드로 인덱스를 생성하고 인라인뷰 안에서 인덱스만 읽어 해시조인 하면 정렬기준으로 빠르게 집합을 얻을 수 있음
               A.상품코드
			 , MIN(B.등록일시)	등록일시			 
             , SUM(A.주문수량) 총주문수량
             , SUM(A.주문금액) 총주문금액
          FROM 주문상품 A, 상품 B
         WHERE A.주문일시 >= ADD_MONTHS(SYSDATE, -1)
           AND A.할인유형코드 = 'K890'
		   AND B.상품코드 = A.상품코드
         GROUP BY
               A.상품코드
	     ORDER BY
		       B.등록일시 DESC) O, 상품 P
 WHERE P.상품코드 = O.상품코드			   


--[변경후 SQL]ROWID로 조인
SELECT /*+ LEADING(O) USE_NL(P) */
       P.상품코드
     , P.상품명
	 , P.등록일시
	 , P.상품가격
	 , P.공급자ID
	 , O.총주문수량
	 , O.총주문금액
  FROM (SELECT /*+ FULL(A) INDEX_FFS(B) LEADING(B) USE_HASH(A)*/
               A.상품코드
			 , MIN(B.등록일시)	등록일시			 
			 , MIN(B.ROWID)	RID
             , SUM(A.주문수량) 총주문수량
             , SUM(A.주문금액) 총주문금액
          FROM 주문상품 A, 상품 B
         WHERE A.주문일시 >= ADD_MONTHS(SYSDATE, -1)
           AND A.할인유형코드 = 'K890'
		   AND B.상품코드 = A.상품코드
         GROUP BY
               A.상품코드
	     ORDER BY
		       B.등록일시 DESC) O, 상품 P
 WHERE P.ROWID = O.RID
 
 
--인덱스 재구성
--상품_X1 : 등록일시 + 상품코드
