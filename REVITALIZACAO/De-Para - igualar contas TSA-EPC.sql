--CREATE TABLE ZTABCTB1 (ANTIGA VARCHAR(20), NOVA VARCHAR(20))

--CREATE TABLE ZTABCTB2 (ANTIGA VARCHAR(20), NOVA VARCHAR(20))

UPDATE CT2010
SET CT2_DEBITO = NOVA 
FROM CT2010 CT2 INNER JOIN ZTABCTB1 ON CT2_DEBITO = ANTIGA 
WHERE CT2.D_E_L_E_T_ <> '*'

UPDATE CT2010
SET CT2_CREDIT = NOVA 
FROM CT2010 CT2 INNER JOIN ZTABCTB1 ON CT2_CREDIT = ANTIGA 
WHERE CT2.D_E_L_E_T_ <> '*'


UPDATE CT2020
SET CT2_DEBITO = NOVA 
FROM CT2020 CT2 INNER JOIN ZTABCTB2 ON CT2_DEBITO = ANTIGA 
WHERE CT2.D_E_L_E_T_ <> '*'

UPDATE CT2020
SET CT2_CREDIT = NOVA 
FROM CT2020 CT2 INNER JOIN ZTABCTB2 ON CT2_CREDIT = ANTIGA 
WHERE CT2.D_E_L_E_T_ <> '*'
