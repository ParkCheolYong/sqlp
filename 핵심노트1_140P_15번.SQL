--[변경전 SQL]
SELECT ...
     , (SELECT CASE WHEN A.일할계산여부 = 'Y'
	                THEN NVL(A.총청구건수, 0) - NVL(A.청구횟수, 0)
				    ELSE B.할부개월수 - NVL(A.청구횟수, 0)
				END
		  FROM 서비스별할부 A, 할부계획 B
		 WHERE A.서비스계약번호 = MV.서비스계약번호
		   AND A.할부상태코드 = 'XR'
		   AND B.할부계회걍(+) = A.할부계획ID
		   AND ROWNUM <=1) AS 청구횟수
	 , ...
  FROM (...) MV
 WHERE ...


--문제점 : 일할계산여부가 'Y'가 아닐때만 할부계획과 조인이 필요한데, 현재는 'Y'일때도 조인을 수행하고 있음

--튜닝방안 : 일할계산여부가 'Y'가 아닐때만 조인하도록 조건절을 아래와 같이 수정

--[변경후 SQL]
SELECT ...
     , (SELECT CASE WHEN A.일할계산여부 = 'Y'
	                THEN NVL(A.총청구건수, 0) - NVL(A.청구횟수, 0)
				    ELSE B.할부개월수 - NVL(A.청구횟수, 0)
				END
		  FROM 서비스별할부 A, 할부계획 B
		 WHERE A.서비스계약번호 = MV.서비스계약번호
		   AND A.할부상태코드 = 'XR'
		   AND B.할부계회걍(+) = (CASE WHEN A.일할계산여부 = 'Y' END NULL ELSE A.할부계획ID END)
		   AND ROWNUM <=1) AS 청구횟수
	 , ...
  FROM (...) MV
 WHERE ...