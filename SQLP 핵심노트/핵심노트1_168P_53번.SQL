--테이블이 배타적 관계일때 OUTER 조인

--작업자가 최근 한 달간 방문해서 처리한 작업지시 중 실제방문일자 역순으로 최근 10건 출력


--인덱스구성
--작업지시_X1 : 작업자ID + 실제방문일자

SELECT *
  FROM (
        SELECT /*+ ORDERED USE_NL(B) USE_NL(C) */
		       A.작업일련번호
             , A.실제방문일자
        	 , NVL2(B.개통접수번호, '개통', '장애')		접수구분
        	 , NVL2(B.개통접수번호, B.고객번호, C.고객번호)	고객번호
        	 , NVL2(B.개통접수번호, B.주소, C.주소)		주소
          FROM 작업지시 A, 개통접수 B, 장애접수 C
         WHERE A.작업자ID = 'Z123456'
           AND A.실제방문일자 >= TRUNC(ADD_MONTHS(SYSDATE, -1))
           AND B.개통접수번호(+) = A.작업일련번호
           AND C.장애접수번호(+) = A.작업일련번호
         ORDER BY
               A.실제방문일자 DESC
	   )
 WHERE ROWNUM <= 10	   