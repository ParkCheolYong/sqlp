--실행계획 작성

--[인덱스 구성]
--계좌_PK : 계좌번호
--계좌_X1 : 개설일자
--고객변경이력_PK : 고객번호 + 변경일시

--[SQL]
SELECT /*+ ORDERED USE_NL(C) INDEX(A) INDEX(C) */
       A.계좌번호, A.계좌명, A.고객번호, C.고객명, C.고객상태코드, C.변경일시
  FROM 계좌 A, 고객변경이력 C
 WHERE A.개설일자 = :OPEN_DT
   AND C.고객번호 = A.고객번호
   AND C.변경일시 = (SELECT /*+ NO_UNNEST PUSH_SUBQ */
                         MAX(변경일시)
					FROM 고객변경이력 H
				   WHERE H.고객번호 = A.고객번호
				     AND H.고객상태코드 <> 'KZ8')   

/* NL조인
NESTED LOOPS
	TABLE ACCESS (BY INDEX ROWID) OF '계좌'
		INDEX (RANGE SCAN) OF '계좌_X1'			
	TABLE ACCESS (BY INDEX ROWID) OF '고객변경이력'
		INDEX (UNIQUE SCAN) OF '고객변경이력_PK'								
			SORT(AGGREGATE)
				TABLE ACCESS (BY INDEX ROWID) OF '고객변경이력'
					INDEX (RANGE SCAN) OF '고객변경이력_PK'			
*/

/* PREFETCH 실행계획
TABLE ACCESS (BY INDEX ROWID) OF '고객변경이력'
	NESTED LOOPS
		TABLE ACCESS (BY INDEX ROWID) OF '계좌'
			INDEX (RANGE SCAN) OF '계좌_X1'					
		INDEX (UNIQUE SCAN) OF '고객변경이력_PK'								
			SORT(AGGREGATE)
				TABLE ACCESS (BY INDEX ROWID) OF '고객변경이력'
					INDEX (RANGE SCAN) OF '고객변경이력_PK'	
*/					

/* 배치 I/O 실행계획
NESTED LOOPS
	NESTED LOOPS
		TABLE ACCESS (BY INDEX ROWID) OF '계좌'
			INDEX (RANGE SCAN) OF '계좌_X1'					
		INDEX (UNIQUE SCAN) OF '고객변경이력_PK'								
			SORT(AGGREGATE)
				TABLE ACCESS (BY INDEX ROWID) OF '고객변경이력'
					INDEX (RANGE SCAN) OF '고객변경이력_PK'	
	TABLE ACCESS (BY INDEX ROWID) OF '고객변경이력'					
*/			

/* 서브쿼리 PUSHING 하지 않았을 때
FILTER
	NESTED LOOPS
		TABLE ACCESS (BY INDEX ROWID) OF '계좌'
			INDEX (RANGE SCAN) OF '계좌_X1'			
		TABLE ACCESS (BY INDEX ROWID) OF '고객변경이력'
			INDEX (RANGE SCAN) OF '고객변경이력_PK'								
	SORT(AGGREGATE)
		TABLE ACCESS (BY INDEX ROWID) OF '고객변경이력'
			INDEX (RANGE SCAN) OF '고객변경이력_PK'			
*/					