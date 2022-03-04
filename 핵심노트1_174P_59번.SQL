장비구분코드가 'A001'인 장비의 최종 상태코드, 변경일자 출력
상태변경이력은 선분이력 테이블


--인덱스
--장비_X1 : 장비구분코드
--상태변경이력_PK : 장비번호 + 유효종료일시 + 유효시작일시



SELECT P.장비번호
     , P.장비명
	 , H.상태코드 AS 최종상태코드
	 , TO_CHAR(H.유효시작일시, 'yyyymmdd') AS 최종상태변경일자
  FROM 장비 P, 상태변경이력 H
 WHERE P.장비구분코드 = 'A001'
   AND H.장비번호 = P.장비번호
   AND SYSDATE BETWEEN H.유효시작일시 AND H.유효종료일시
 ORDER BY 
       P.장비번호