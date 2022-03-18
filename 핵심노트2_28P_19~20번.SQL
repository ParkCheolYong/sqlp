--28P_19번
--상품번호 'R0014'상품의 2021년 3월 한달간 일별 최종 할인율(기준일자별 마지막 변경순번의 할인율) 출력
--PK : 상품번호 + 기준일자 + 변경순번

--1안
SELECT 기준일자
     , 할인율
  FROM (SELECT 기준일자
             , 할인율
        	 , ROW_NUMBER() OVER(PARTITION BY 기준일자 ORDER BY 변경순번 DESC) NO
          FROM 상품할인율
         WHERE 기준일자 BETWEEN '20210301' AND '20210331'
           AND 상품번호 = 'R0014')
  WHERE NO = 1
  ORDER BY
        기준일자  

--2안
SELECT 기준일자
     , MAX(할인율) KEEP (DENSE_RANK FIRST ORDER BY 변경순번 DESC) 할인율
  FROM 상품할인율
 WHERE 기준일자 BETWEEN '20210301' AND '20210331'
   AND 상품번호 = 'R0014'
 GROUP BY
       기준일자
 ORDER BY
       기준일자 
		
		
--29P_20번
--상품번호 'R0014'상품의 최종 할인율(마지막 기준일자의 마지막 변경순번의 할인율) 출력
--PK : 상품번호 + 기준일자 + 변경순번
SELECT *
  FROM (SELECT 할인율
          FROM 상품할인율
         WHERE 상품번호 = 'R0014'
         ORDER BY
               기준일자 DESC
             , 변경순번 DESC)
 WHERE ROWNUM <= 1			 