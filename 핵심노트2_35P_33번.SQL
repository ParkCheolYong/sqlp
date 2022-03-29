--야간배치 프로그램 튜닝 (인덱스 추가, 변경 불가)

--[데이터]
--고객 100만명
--미성년자 2%
--법정대리인을 등록한 미성년자 50%

--[인덱스]
--고객_PK : 고객번호
--고객_X1 : 고객명
--고객_X2 : 연락처
--고객_X3 : 법정대리인_고객번호

--[변경전 SQL]
UPDATE 고객 C
   SET 법정대리인_연락처 = NVL((SELECT 연락처
                             FROM 고객
						    WHERE 고객번호 = C.법정대리인_고객번호)
						  , C.법정대리인_연락처)
 WHERE 성인여부 = 'N'


--[변경후 SQL]
--1안
UPDATE (SELECT /*+ LEADING(C) USE_NL(P) INDEX(C 고객_X3) INDEX(P 고객_PK) */
               C.법정대리인_연락처, P.연락처
          FROM 고객 C, 고객 P
		 WHERE C.성인여부 = 'N'
		   AND C.법정대리인_고객번호 IS NOT NULL --> 옵티마이저가 자동 생성함
		   AND P.고객번호 = C.법정대리인_고객번호
		   AND P.연락처 <> C.법정대리인_연락처
	    )
    SET 법정대리인_연락처 = 연락처
	
--2안
MERGE /*+ LEADING(C) USE_NL(P) INDEX(C 고객_X3) INDEX(P 고객_PK) */
      INTO 고객 C
USING 고객 P 
   ON (    C.성인여부 = 'N'
       AND C.법정대리인_고객번호 IS NOT NULL
	   AND P.고객번호 = C.법정대리인_고객번호)
WHEN MATCHED THEN UPDATE
 SET C.법정대리인_연락처 = P.연락처
WHERE C.법정대리인_연락처 <> P.연락처

--SQL SERVER
UPDATE C
   SET C.법정대리인_연락처 = P.연락처
  FROM 고객 C WITH(INDEX(고객_X3))
       INNER JOIN 고객 P WITH(INDEX(고객_PK)) ON C.성인여부 = 'N'
	                                       AND C.법정대리인_고객번호 IS NOT NULL
		                                   AND P.고객번호 = C.법정대리인_고객번호
		                                   AND P.연락처 <> C.법정대리인_연락처
 OPTION (FORCE ORDER, LOOP JOIN)										   