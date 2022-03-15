--[인덱스 구성]
--상품분류_PK : 상품분류코드
--상품_PK : 상품번호
--주문_PK : 고객번호 + 상품번호 + 주문일시
--주문_X1 : 상품번호 + 주문일시

--[변경 전 SQL]
SELECT COUNT(DISTINCT P.상품번호)
     , SUM(T.주문금액)
	 , SUM(T.주문수량)
	 , AVG(T.할인율)
  FROM 상품 P, 주문 T
 WHERE T.상품번호 = P.상품번호
   AND T.주문일시 >= TRUNC(SYSDATE -7)
   AND EXISTS(SELECT 'X'
                FROM 상품분류
			   WHERE 상품분류코드 = P.상품분류코드
			     AND 상위분류코드 = 'AK')
				 
				 
--[변경 후 SQL]
SELECT /*+ LEADING(P) USE_NL(T) */
       COUNT(DISTINCT P.상품번호)
     , SUM(T.주문금액)
	 , SUM(T.주문수량)
	 , AVG(T.할인율)
  FROM 상품 P, 주문 T
 WHERE T.상품번호 = P.상품번호
   AND T.주문일시 >= TRUNC(SYSDATE -7)
   AND EXISTS(SELECT /*+ NO_UNNEST PUSH_SUBQ */ --서브쿼리 필터기능을 먼저 처리
                     'X'
                FROM 상품분류
			   WHERE 상품분류코드 = P.상품분류코드
			     AND 상위분류코드 = 'AK')				 
				 
				 
				 