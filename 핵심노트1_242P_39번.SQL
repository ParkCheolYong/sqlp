--[인덱스 구성]
--고객_PK : 고객번호
--고객_X1 : 가입일시
--거래_PK : 거래번호
--거래_X1 : 거래일시
--거래_X2 : 고객번호 + 거래일시

--[변경 전 SQL]
SELECT C.고객번호
     , C.고객명
	 , T.평균거래
	 , T.최소거래
	 , T.최대거래
  FROM 고객 C
     , (SELECT 고객번호
	         , AVG(거래금액) 평균거래
			 , MIN(거래금액) 최소거래
			 , MAX(거래금액) 최대거래
		  FROM 거래
		 WHERE 거래일시 >= TRUNC(SYSDATE, 'MM')
		 GROUP BY
		       고객번호) T
 WHERE C.가입일시 >= TRUNC(ADD_MONTHS(SYSDATE -1), 'MM')
   AND T.고객번호 = C.고객번호 


--[변경 후 SQL](스칼라 서브쿼리 활용)
SELECT 고객번호
     , 고객명
	 , TO_NUMBER(SUBSTR(거래금액, 1, 10)) 평균거래
	 , TO_NUMBER(SUBSTR(거래금액, 11, 10)) 최소거래
	 , TO_NUMBER(SUBSTR(거래금액, 21)) 최대거래
  FROM (SELECT C.고객번호
             , C.고객명
        	 , (SELECT LPAD(AVG(거래금액), 10) || LPAD(MIN(거래금액), 10) || MAX(거래금액)
        		  FROM 거래
        		 WHERE 거래일시 >= TRUNC(SYSDATE, 'MM')
        		   AND 고객번호 = C.고객번호) 거래금액	 
          FROM 고객 C    
         WHERE C.가입일시 >= TRUNC(ADD_MONTHS(SYSDATE -1), 'MM'))
   
   
   
--[변경 후 SQL] (조인조건 PUSHDOWN 활용)
SELECT /*+ LEADING(C) USE_NL(T) INDEX(C 고객_X1) */
       C.고객번호
     , C.고객명
	 , T.평균거래
	 , T.최소거래
	 , T.최대거래
  FROM 고객 C
     , (SELECT /*+ NO_MERGE PUSH_PRED INDEX(거래 거래_X2) */
	           고객번호
	         , AVG(거래금액) 평균거래
			 , MIN(거래금액) 최소거래
			 , MAX(거래금액) 최대거래
		  FROM 거래
		 WHERE 거래일시 >= TRUNC(SYSDATE, 'MM')
		 GROUP BY
		       고객번호) T
 WHERE C.가입일시 >= TRUNC(ADD_MONTHS(SYSDATE -1), 'MM')
   AND T.고객번호 = C.고객번호    
   
   
 