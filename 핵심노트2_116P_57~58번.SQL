--GROUP BY / CASE 활용
SELECT A.고객번호
     , MIN(A.고객명) 고객명
	 , MIN(CASE WHEN B.연락처구분코드 = 'HOM' THEN B.연락처번호 END) AS 집
	 , MIN(CASE WHEN B.연락처구분코드 = 'OFC' THEN B.연락처번호 END) AS 사무실
	 , MIN(CASE WHEN B.연락처구분코드 = 'MBL' THEN B.연락처번호 END) AS 휴대폰
  FROM 고객 A, 고객연락처 B
 WHERE B.고객번호 = A.고객번호
   AND A.고객구분코드 = 'VIP'
 GROUP BY
       A.고객번호 
     	   
--PIVOT
SELECT A.고객번호
     , A.고객명
	 , B.집
	 , B.사무실
	 , B.휴대폰
  FROM 고객 A
     , 고객연락처 PIVOT (MIN(연락처번호) FOR 연락처구분코드 IN ('HOM' AS 집, 'OFC' AS 사무실, 'MBL' AS 휴대폰)) B
 WHERE B.고객번호 = A.고객번호
   AND A.고객구분코드 = 'VIP' 	 


--테이블 식별자 컬럼 값의 종류 개수 제한 없을때
SELECT A.고객번호
     , MIN(A.고객명)
	 , LISTAGG('(' || B.연락처구분코드 || ')' || B.연락처번호, ',') WITHIN GROUP (ORDER BY B.연락처구분코드) 연락처
  FROM 고객 A, 고객연락처 B
 WHERE B.고객번호 = A.고객번호
   AND A.고객구분코드 = 'VIP'	
 GROUP BY
       A.고객번호   