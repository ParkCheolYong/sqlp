
CREATE INDEX 고객_X1 ON 고객 (거주지역코드, 고객명)
CREATE INDEX 주문_X1 ON 주문 (고객번호, 주문일시) LOCAL

SELECT /*+ ORDERED USE_NL(O) INDEX(C 고객_X1) INDEX(O 주문_X1) */
  FROM 고객 C, 주문 O
 WHERE O.고객번호 = C.고객번호
   AND O.주문일시 BETWEEN TO_DATE('20150301','YYYYMMDD') AND TO_DATE('20150314235959', 'YYYYMMDDHH24MISS')
   AND (C.거주지역코드, C.고객명) IN (('02','김철수') , ('05','홍길동'))   
 ORDER BY
       O.주문일시, C.고객명 
   