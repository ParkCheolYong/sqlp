
--[SQL 1]
SELECT 주문번호
     , 업체번호
	 , 주문일자
	 , 주문금액
     , COUNT(*) OVER (PARTITION BY 업체번호) 총주문번호
     , AVG(주문금액) OVER (PARTITION BY 업체번호) 평균주문금액
	 , MAX(주문금액) OVER (PARTITION BY 업체번호) 최대주문금액
  FROM 주문
 WHERE 주문일자 LIKE '201509%'
 ORDER BY 평균주문금액 DESC
 
 
--[SQL 2] 
SELECT 주문번호, 업체번호, 주문일자, 주문금액
  FROM (SELECT 주문번호, 업체번호, 주문일자, 주문금액
             , ROW_NUMBER() OVER(PARTITION BY 업체번호 ORDER BY 주문번호 DESC) RNUM
          FROM 주문
		 WHERE 주문일자 LIKE '201509%')
WHERE RNUM = 1;		  