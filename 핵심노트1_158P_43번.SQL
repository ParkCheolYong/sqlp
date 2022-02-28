--부분범위 처리가 가능하도록 최적화

--[변경전 SQL]
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
		 WHERE 거래일시 > TRUNC(SYSDATE, 'mm')
		 GROUP BY
		       고객번호) T
 WHERE C.가입일시 >= TRUNC(ADD_MONTHS(SYSDATE, -1), 'mm')
   AND T.고객번호 = C.고객번호 
	
--[변경후 SQL]스칼라 서브쿼리
SELECT T.고객번호
     , T.고객명
	 , TO_NUMBER(SUBSTR(T.거래금액,1,10))	 	평균거래
	 , TO_NUMBER(SUBSTR(T.거래금액,11,10)) 	최소거래
	 , TO_NUMBER(SUBSTR(T.거래금액,21))		최대거래
  FROM (SELECT C.고객번호
             , C.고객명
          	 , (SELECT LPAD(AVG(거래금액), 10) || LPAD(MIN(거래금액), 10) || MAX(거래금액)
          	      FROM 거래
          		 WHERE 고객번호 = C.고객번호
          		   AND 거래일시 >= TRUNC(SYSDATE, 'mm')) 거래금액
            FROM 고객 C
           WHERE C.가입일시 >= TRUNC(ADD_MONTHS(SYSDATE, -1), 'mm')
		) T
		
		
		
--[변경후 SQL]조인조건 PUSHDOWN
SELECT /*+ORDERED USE_NL(T)*/
       C.고객번호
     , C.고객명
	 , T.평균거래
	 , T.최소거래
	 , T.최대거래
  FROM 고객 C
     , (SELECT /*+NO_MERGE PUSH_PRED*/
	           고객번호
	         , AVG(거래금액) 평균거래
			 , MIN(거래금액) 최소거래
			 , MAX(거래금액) 최대거래
	      FROM 거래
		 WHERE 거래일시 > TRUNC(SYSDATE, 'mm')
		 GROUP BY
		       고객번호) T
 WHERE C.가입일시 >= TRUNC(ADD_MONTHS(SYSDATE, -1), 'mm')
   AND T.고객번호 = C.고객번호 
		
		
		
  