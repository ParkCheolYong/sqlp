--SQL튜닝

--[인덱스 구성]
상담_PK : 상담원ID + 상담일자 + 상담시각
상담_X1 : 상담일자 + 상담조직코드
상담원_PK : 상담원ID
상담원_X1 : 상담원명

--[데이터]

상담 = 1000만 건
상담원 = 100명

하루 상담건수 = 1만건
상담원별 하루 평균 상담건수 = 200건
상담조직별 평균 상담원수 = 10명

--[변경전 SQL]
SELECT A.상담일자, A.처리완료일시, A.고객번호, A.상담유형코드, A.처리결과코드
     , B.상담원명, B.입사일자, B.역량코드
  FROM 상담 A, 상담원 B
 WHERE A.상담조직코드 = :CNSL_ORG_CD
   AND TO_CHAR(SYSDATE -2, 'YYYYMMDD') BETWEEN A.상담일자 AND TO_CHAR(A.처리완료일시, 'YYYYMMDD') 
   AND B.상담원ID = A.상담원ID
 ORDER BY
       A.상담일자
	 , A.처리완료일시


--[변경후 SQL]
--인덱스 추가 : 상담조직코드 + 처리완료일시
SELECT A.상담일자, A.처리완료일시, A.고객번호, A.상담유형코드, A.처리결과코드
     , B.상담원명, B.입사일자, B.역량코드
  FROM 상담 A, 상담원 B
 WHERE A.상담조직코드 = :CNSL_ORG_CD
   AND A.상담일자 < TO_CHAR(SYSDATE -2, 'YYYYMMDD')    
   AND A.처리완료일시  >= TRUNC(SYSDATE -2)
   AND B.상담원ID = A.상담원ID
 ORDER BY
       A.상담일자
	 , A.처리완료일시
