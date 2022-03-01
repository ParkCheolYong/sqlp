인덱스 변경하지 않고 힌트지정 불가 조건에서 테이블이 배타적 관계일때

--인덱스 구성
--작업지시_X1 : 작업구분코드 + 방문예정일자

SELECT A.작업일련번호
     , A.작업자ID
	 , '개통' AS 작업구분
	 , B.고객번호
	 , B.주소
  FROM 작업지시 A, 개통접수 B
 WHERE A.방문예정일자 = TO_CHAR(SYSDATE, 'yyyymmdd')
   AND A.작업구분코드 = 'A'
   AND B.개통접수번호 = A.작업일련번호
   
UNION ALL

SELECT A.작업일련번호
     , A.작업자ID
	 , '장애' AS 작업구분
	 , C.고객번호
	 , C.주소
  FROM 작업지시 A, 장애접수 C
 WHERE A.방문예정일자 = TO_CHAR(SYSDATE, 'yyyymmdd')
   AND A.작업구분코드 = 'A'
   AND C.장애접수번호 = A.작업일련번호   