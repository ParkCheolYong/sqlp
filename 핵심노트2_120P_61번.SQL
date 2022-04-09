--누적매출금액구하기

--분석함수 사용
SELECT 지점코드
     , 판매월
	 , 매출금액
	 , SUM(매출금액) OVER(PARTITION BY 지점코드 ORDER BY 판매월 RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 누적매출
  FROM 월별지점매출
  
--부등호조인 활용
SELECT T1.지점코드
     , T1.판매월
	 , MIN(T1.매출금액) 매출금액
	 , SUM(T2.매출금액) 누적매출금액
  FROM 월별지점매출 T1, 월별지점매출 T2
 WHERE T1.지점코드 = T2.지점코드
   AND T2.판매월 <= T1.판매월
 GROUP BY T1.지점코드, T1.판매월	   
 ORDER BY T1.지점코드, T1.판매월	   
   

       
