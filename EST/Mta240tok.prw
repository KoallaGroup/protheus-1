User Function Mt240tok()
***********************************************************************************************************************
* Esta rotina tem como Objetivo validar o campo D3_CBASE(C�digo do Bem) para as requisi��es de amplia��o do BEM
*
*****
Local lRet:=.T.

If M->D3_TM$GetMv('MV_TMAMPL',,'801') .And. (Empty(M->D3_CODBEM))
	MsGBox('Para este tipo de Movimenta��o � necess�rio informar o c�digo do BEM')
	lRet:=.f.
Endif

Return(lRet)
