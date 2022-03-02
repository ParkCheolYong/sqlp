힌트지정 불가 조건에서 테이블이 배타적 관계일때

--인덱스 생성
--개통접수_X1 : 개통접수일시
--장애접수_X1 : 장애접수일시
--작업지시_X1 : 접수번호 + 작업구분코드

SELECT Y.작업일련번호
     , Y.작업자ID
	 , '개통' AS 작업구분
	 , X.고객번호
	 , X.주소
  FROM 개통접수 X, 작업지시 Y
 WHERE X.개통접수일시 >= TRUNC(SYSDATE)
   AND X.개통접수일시 < TRUNC(SYSDATE +1)
   AND Y.작업구분코드 = 'A'
   AND Y.접수번호 = X.개통접수번호
   
UNION ALL

SELECT Y.작업일련번호
     , Y.작업자ID
	 , '장애' AS 작업구분
	 , X.고객번호
	 , X.주소
  FROM 장애접수 X, 작업지시 Y
 WHERE X.장애접수일시 >= TRUNC(SYSDATE)
   AND X.장애접수일시 < TRUNC(SYSDATE +1)
   AND Y.작업구분코드 = 'B'
   AND Y.접수번호 = X.장애접수번호