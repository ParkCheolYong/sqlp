
--[변경전 SQL]
SELECT X.고객명, X.휴대폰번호, X.이용금액
  FROM (SELECT A.고객명,
             , B.고객번호
       	     , MIN(B.휴대폰번호) AS 휴대폰번호 
       	     , SUM(C.이용금액) AS 이용금액
          FROM 고객 A, 고객 B, 서비스이용명세
         WHERE A.고객구분코드 = 'INF'
           AND B.고객번호 = A.법정대리고객번호
      	   AND C.고객번호 = B.고객번호
      	   AND C.이용일자 BETWEEN :DT1 AND DT2
         GROUP BY 
		       A.고객명, B.고객번호) X
     , (SELECT DISTINCT 고객번호 FROM SMS거부등록 WHERE 거부여부 'Y') Y
 WHERE X.고객번호 = Y.고객번호(+)
   AND Y.고객번호 IS NULL; 
	
--1안
	
--인덱스추가
--고객_X1 : 고객구분코드
--SMS거부등록_X1 : 고객번호 + 거부여부
SELECT /*+ LEADING (A X@SUBQ B C) */
       A.고객명,
  	 , MIN(B.휴대폰번호) AS 휴대폰번호 
  	 , SUM(C.이용금액) AS 이용금액
  FROM 고객 A, 고객 B, 서비스이용명세
 WHERE A.고객구분코드 = 'INF'
   AND B.고객번호 = A.법정대리고객번호
   AND C.고객번호 = B.고객번호
   AND C.이용일자 BETWEEN :DT1 AND DT2
   AND NOT EXISTS (SELECT /*+ QB_NAME(SUBQ) */ 'X'		                         
                     FROM SMS거부등록 X
    	            WHERE X.거부여부 'Y'
                 	  AND X.고객번호 = A.법정대리고객번호)
 GROUP BY 
       A.고객명, B.고객번호
	   
--2안
	
--인덱스추가
--고객_X1 : 고객구분코드 + 법정대리고객번호
--SMS거부등록_X1 : 고객번호 + 거부여부
SELECT A.고객명,
  	 , MIN(B.휴대폰번호) AS 휴대폰번호 
  	 , SUM(C.이용금액) AS 이용금액
  FROM 고객 A, 고객 B, 서비스이용명세
 WHERE A.고객구분코드 = 'INF'
   AND B.고객번호 = A.법정대리고객번호
   AND C.고객번호 = B.고객번호
   AND C.이용일자 BETWEEN :DT1 AND DT2
   AND NOT EXISTS (SELECT /*+ NO_UNNEST PUSH_SUBQ */ 'X'		                         
                     FROM SMS거부등록 X
    	            WHERE X.거부여부 'Y'
                 	  AND X.고객번호 = A.법정대리고객번호)
 GROUP BY 
       A.고객명, B.고객번호	   
