--모든장비의 변경이력 출력

--윈도우함수 사용
SELECT P.장비번호
     , P.장비명
	 , P.장비구분코드
	 , H.상태코드 AS 최종상태코드
	 , H.변경일자 AS 최종변경일자
	 , H.변경순번 AS 최종변경순번
  FROM 장비 P
     , (SELECT 장비번호
	         , 변경일자
			 , 변경순번
			 , 상태코드
			 , ROW_NUMBER() OVER(PARTITION BY 장비번호 ORDER BY 변경일자 DESC, 변경순번 DESC) AS RNUM
		  FROM 상태변경이력) H
 WHERE H.장비번호 = P.장비번호
   AND H.RNUM = 1; 
   
--KEEP 사용
SELECT P.장비번호
     , P.장비명
	 , P.장비구분코드
	 , H.상태코드 AS 최종상태코드
	 , H.변경일자 AS 최종변경일자
	 , H.변경순번 AS 최종변경순번
  FROM 장비 P
     , (SELECT 장비번호
	         , MAX(변경일자)
			 , MAX(변경순번) KEEP (DENSE_RANK LAST ORDER BY 변경일자, 변경순번) 변경순번
			 , MAX(상태코드) KEEP (DENSE_RANK LAST ORDER BY 변경일자, 변경순번) 상태코드
		  FROM 상태변경이력
		 GROUP BY 장비번호) H
 WHERE H.장비번호 = P.장비번호
 
   