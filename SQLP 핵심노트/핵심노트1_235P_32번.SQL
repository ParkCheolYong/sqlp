--[데이터]
--고객 : 100만건
--거래 : 1000만건

--[인덱스 구성]
--고객_PK : 고객번호
--거래_PK : 고객번호 + 거래일시

--[변경 전 SQL]
SELECT COUNT(*)
  FROM 고객 C
 WHERE C.가입일시 < TRUNC(ADD_MONTHS(SYSDATE, -1))
   AND NOT EXISTS(SELECT 'X'
                    FROM 거래
				   WHERE 고객번호 = C.고객번호
				     AND ROWNUM <= 1)
					 
					 
					 
--[변경 후 SQL]
SELECT /*+ FULL(C)*/ --가입후 1개월지난 데이터는 대부분일 것이므로 FULL SCAN
       COUNT(*)
  FROM 고객 C
 WHERE C.가입일시 < TRUNC(ADD_MONTHS(SYSDATE, -1))
   AND NOT EXISTS(SELECT /*+ UNNEST HASH_AJ INDEX_FFS(거래 거래_PK) */ --대량 테이블이므로 해시조인 유도, 인덱스만 빠르게 읽고 처리하기위해 FAST FULL SCAN 사용
                         'X'
                    FROM 거래
				   WHERE 고객번호 = C.고객번호
				     --AND ROWNUM <= 1  --UNNESTING을 위한 ROWNUM 삭제
				  )					 
					 
					 
					 
					 



