--상품 1000건
--계약 5000만건
--1년간 계약건수 500만건
--상품유형코드를 '=' 조건으로 검색할 때의 평균 카디널리티 100건

--[변경전 SQL]
SELECT DISTINCT P.상품번호
     , P.상품명
	 , P.상품가격
	 , P.상품분류코드
  FROM 상품 P, 계약 C
 WHERE P.상품유형코드 = :PCLSCD
   AND C.상품번호 = P.상품번호
   AND C.계약일자 >= TRUNC(ADD_MONTHS(SYSDATE, -12))
   


--[변경후 SQL]
SELECT /*+ LEADING P */ --UNNEST후 DRIVING테이블이 되도록
       P.상품번호
     , P.상품명
	 , P.상품가격
	 , P.상품분류코드
  FROM 상품 P
 WHERE P.상품유형코드 = :PCLSCD
   AND EXISTS(SELECT /*+ UNNEST NL_SJ */ --해시 세미조인으로 풀리면 원하는 효과를 얻을 수 없음(NL세미조인으로 조인에 성공하는 데이터가 있는지만 확인하면 되기 때문)
                     'X'
                FROM 계약
			   WHERE 상품번호 = P.상품번호
                 AND 계약일자 >= TRUNC(ADD_MONTHS(SYSDATE, -12)))


--[변경후 SQL]
SELECT --필터방식은 항상 메인쿼리 집합을 먼저 읽으므로 LEADING 불필요
       P.상품번호
     , P.상품명
	 , P.상품가격
	 , P.상품분류코드
  FROM 상품 P
 WHERE P.상품유형코드 = :PCLSCD
   AND EXISTS(SELECT /*+ NO_UNNEST */ --UNNESTING 하지 않으면 항상 필터방식으로 실행됨
                     'X'
                FROM 계약
			   WHERE 상품번호 = P.상품번호
                 AND 계약일자 >= TRUNC(ADD_MONTHS(SYSDATE, -12)))
				 
				 
--인덱스 변경
--계약_X2 : 상품번호 + 계약일자				 