
CREATE INDEX 주문_X1 ON 주문 (주문일시);
CREATE INDEX 주문_X2 ON 주문 (고객번호,주문일시);

SELECT 고객번호, 주문일시, 주문금액, 우편번호, 배송지
   FROM 주문
  WHERE 주문일시 BETWEEN TO_DATE(:DT1, 'YYYYMMDD') AND TO_DATE(:DT2, 'YYYYMMDD')
    AND 고객번호 = NVL(:CUST_NO, 고객번호)
  ORDER BY 주문일시 DESC




  