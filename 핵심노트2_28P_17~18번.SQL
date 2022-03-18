
--28P_17번
--상품번호 'ZE367'상품의 변경구분코드 'C2'인 최종변경일시 출력
--PK : 상품번호 + 변경일시
SELECT *
  FROM (SELECT 변경일시
          FROM 상품변경이력
         WHERE 상품번호 = 'ZE367'
           AND 변경구분코드 = 'C2'
		 ORDER BY
		       변경일시 DESC)
 WHERE ROWNUM <= 1			   
 
--28P_18번
--2021년 3월에 변겨오딘 상품 중 변경구분코드 'C2'인 최종변경일시와 상품번호 출력
--PK : 상품번호 + 변경일시 

--1안
SELECT 상품번호
     , 변경일시
  FROM (SELECT 상품번호
             , 변경일시
        	 , 변경구분코드
             , ROW_NUMBER() OVER(PARTITION BY 상품번호 ORDER BY 변경일시 DESC) AS NUM
          FROM 상품변경이력
         WHERE 변경일시 BETWEEN '20210301' AND'20210331')
 WHERE NUM = 1
   AND 변경구분코드 = 'C2'

--2안
SELECT 상품번호
     , MAX(변경일시) 변경일시
  FROM 상품변경이력
 WHERE 변경일시 BETWEEN '20210301' AND'20210331'
 GROUP BY
       상품번호
 HAVING MAX(변경구분코드) KEEP(DENSE_RANK FIRST ORDER BY 변경일시 DESC) = 'C2'	   
 
 