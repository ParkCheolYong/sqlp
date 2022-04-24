--12c 버전에서 부분범위 처리 가능하도록

--[변경전 SQL]
SELECT C.고객번호
     , C.고객명	 
     , (SELECT ROUND(AVG(거래금액), 2) 평균거래금액
          FROM 거래
      	 WHERE 거래일시 >= TRUNC(SYSDATE, 'mm')
      	   AND 고객번호 = C.고객번호)
  FROM 고객 C
 WHERE C.가입일시 >= TRUNC(ADD_MONTHS(SYSDATE, -1), 'mm')  


--[변경후 SQL]스칼라 서브쿼리 UNNESTING
SELECT C.고객번호
     , C.고객명	 
     , (SELECT /*+ NO_UNNEST */
	           ROUND(AVG(거래금액), 2) 평균거래금액
          FROM 거래
      	 WHERE 거래일시 >= TRUNC(SYSDATE, 'mm')
      	   AND 고객번호 = C.고객번호)
  FROM 고객 C
 WHERE C.가입일시 >= TRUNC(ADD_MONTHS(SYSDATE, -1), 'mm')  


--[변경후 SQL]서브쿼리 PUSHDOWN
SELECT /*+ ORDERED USE_NL(T) */
       C.고객번호
     , C.고객명	      
	 , T.평균거래금액
  FROM 고객 C
     , (SELECT /*+ NO_MERGE PUSH_PRED */
	           고객번호
	         , ROUND(AVG(거래금액), 2) 평균거래금액
          FROM 거래
      	 WHERE 거래일시 >= TRUNC(SYSDATE, 'mm')
		 GROUP BY
		       고객번호
      	) T
 WHERE C.가입일시 >= TRUNC(ADD_MONTHS(SYSDATE, -1), 'mm')        
   AND T.고객번호(+) = C.고객번호
   
/***************************
--인덱스 추가
--고객_X1 : 가입일시
--거래_X2 : 고객번호 + 거래일시
****************************/   