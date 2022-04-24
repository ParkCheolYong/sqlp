--29P_22번
--장비구분코드가 'A001'인 장비의 최종 상태코드,변경일자,변경순번 출력
--장비 PK : 장비번호
--상태변경이력 PK : 장비번호 + 변경일자 + 변경순번

--1안
SELECT 장비번호
     , 장비명
	 , SUBSTR(최종이력,1,8) 최종변경일자
	 , SUBSTR(최종이력,9,4) 최종변경순번
	 , SUBSTR(최종이력,13) 최종상태코드
  FROM (SELECT 장비번호
             , 장비명
             , (SELECT 변경일자 || LPAD(변경순번) || 상태코드 
        	     FROM (SELECT 상태코드
        	                 , 변경일자
        		         	 , 변경순번
        		          FROM 상태변경이력
        		         WHERE 장비번호 = P.장비번호
        		         ORDER BY
        		               변경일자 DESC
        		         	 , 변경순번 DESC))
                 WHERE ROWNUM <= 1) 최종이력					 
          FROM 장비 P
         WHERE 장비구분코드 = 'A001')

--2안
SELECT H.상태코드
     , H.변경일자
	 , H.변경순번
  FROM 장비 P, 상태변경이력 H
 WHERE H.장비번호 = P.장비번호
   AND P.장비구분코드 = 'A001'
   AND (P.변경일자, P.변경순번) = (SELECT 변경일자
                                  , 변경순번
                               FROM(SELECT 변경일자
							  	         , 변경순번
						                FROM 상태변경이력
                                       WHERE 장비번호 = P.장비번호
                                       ORDER BY
                                             변경일자 DESC
                                           , 변경순번 DESC)
                               WHERE ROWNUM <= 1)										   