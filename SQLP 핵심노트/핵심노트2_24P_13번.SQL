--상품 100개
--주문 1억건
--주문상품 2억건
--한달 주문건수 100만건
--거의 모든 상품에 골고루 주문 발생

--[인덱스 구성]
--주문_PK : 주문번호
--주문_X1 : 주문일자
--주문상품_PK : 주문번호 + 상품코드

--[변경전 SQL]
SELECT DISTINCT O.주문번호
     , O.주문금액
	 , O.결제구분코드
	 , O.주문매체코드
  FROM 주문 O, 주문상품 P
 WHERE O.주문일자 >= TRUNC(ADD_MONTHS(SYSDATE, -12))        
   AND P.주문번호 = O.주문번호
   AND P.상품코드 = :PRD_CD
   
   
--[변경후 SQL]
SELECT DISTINCT O.주문번호
     , O.주문금액
	 , O.결제구분코드
	 , O.주문매체코드
  FROM 주문 O, 주문상품 P --1200만건을 NL조인 처리하면 랜덤 액세스 및 소트부하가 너무 크기때문에 해시 조인으로 처리함
 WHERE O.주문일자 >= TRUNC(ADD_MONTHS(SYSDATE, -12)) -- 1년치 주문데이터 1200만건 이므로 FULL SCAN 유도        
   AND P.주문번호 = O.주문번호 -- 주문당 주문상품은 평균 2건(주문상품/주문) 이므로 EXISTS 부적절
   AND P.상품코드 = :PRD_CD --상품코드 조건을 만족하는 주문상품은 평균 200만건, PK가 주문번호 + 상품코드이기 때문에 주문번호에는 중복 없음 -> BUILD INPUT최적


--1안
--1)인덱스 추가
--주문상품_X1 : 상품코드 + 주문번호
--
--2)아래 힌트 추가
--/*+ LEADING(P) USE_HASH(O) FULL(O) INDEX(P 주문상품_X1) */


--2안
--주문상품 버퍼캐시히트율이 낮고 쿼리 수행빈도가 낮다면 인덱스를 추가하지 않고 FAST FULL SCAN유도
--아래힌트 추가
--/*+ LEADING(P) USE_HASH(O) FULL(O) INDEX_FFS(P 주문상품_PK) */
                            