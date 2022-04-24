--데이터복제
SELECT A.고객번호
     , A.고객명
	 , (CASE B.RNUM
	         WHEN 1 THEN '집전화번호'
			 WHEN 2 THEN '사무실전화번호'
			 WHEN 3 THEN '휴대폰번호'
		END) AS 연락처구분코드
	 , (CASE B.RNUM
	         WHEN 1 THEN A.집전화번호
			 WHEN 2 THEN A.사무실전화번호
			 WHEN 3 THEN A.휴대폰번호
		END) AS 연락처번호
  FROM 고객 A
     , (SELECT ROWNUM RNUM FROM DUAL CONNECT BY LEVEL <= 3) B
 WHERE A.고객구분코드 = 'VIP'
   AND B.RNUM IN (  (CASE WHEN A.집전화번호 IS NOT NULL THEN 1 END)
                  , (CASE WHEN A.사무실전화번호 IS NOT NULL THEN 2 END)
                  , (CASE WHEN A.휴대폰번호 IS NOT NULL THEN 3 END)
				 )
				 
--UNPIVOT사용
SELECT 고객번호
     , 고객명
	 , 컬럼명 AS 연락처구분
	 , 컬럼값 AS 연락처번호
  FROM 고객 UNPIVOT(컬럼값 FOR 컬럼명 IN (집전화번호, 사무실전화번호, 휴대폰번호)) A
 WHERE 고객구분코드 = 'VIP'
				 