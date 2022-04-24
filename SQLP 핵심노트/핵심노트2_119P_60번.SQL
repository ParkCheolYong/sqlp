--FULL OUTER JOIN
SELECT NVL(A.고객ID, B.고객ID) 고객ID
     , A.입금액
	 , B.출금액
  FROM (SELECT 고객ID, SUM(입금액) 입금액 FROM 입금 GROUP BY 고객ID) A
        FULL OUTER JOIN		 
	   (SELECT 고객ID, SUM(출금액) 출금액 FROM 출금 GROUP BY 고객ID) B
    ON A.고객ID = B.고객ID
	

--UNION ALL	
SELECT 고객ID
     , SUM(입금액) 입금액
	 , SUM(출금액) 출금액
  FROM (SELECT 고객ID, 입금액, TO_NUMBER(NULL) 출금액 FROM 입금
        UNION ALL
	    SELECT 고객ID, TO_NUMBER(NULL) 입금액, 출금액 FROM 출금)
 GROUP BY
       고객ID 




	