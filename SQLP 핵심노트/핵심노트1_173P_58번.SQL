장비구분코드가 'A001'인 장비의 최종 상태코드, 직전일의 마지막 상태코드, 변경일자, 변경순번 출력


--인덱스
--장비_X1 : 장비구분코드
--상태변경이력_PK : 장비번호 + 변경일자 + 변경순번


SELECT P.장비번호
     , P.장비명
	 , P.상태코드	최종상태코드
	 , H.상태코드	직전상태코드
	 , H.변경일자	직전변경일자
	 , H.변경순번	직전변경순번
  FROM 장비 P, 상태변경이력 H     
 WHERE P.장비구분코드 = 'A001'
   AND H.장비번호 = P.장비번호
   AND (H.변경일자, H.변경순번) = (SELECT 변경일자
                                   , 변경순번
								FROM (SELECT 변경일자
                                           , 변경순번
							            FROM 상태변경이력
								       WHERE 장비번호 = P.장비번호
									     AND 변경일자 < P.최종상태변경일자
							           ORDER BY
							                 변경일자 DESC
							               , 변경순번 DESC)
							   WHERE ROWNUM <= 1)
 ORDER BY
       P.장비번호