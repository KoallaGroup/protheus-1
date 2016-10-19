#Include "RWMAKE.CH"

User Function Mt240tok()
***********************************************************************************************************************
* Esta rotina tem como Objetivo validar o campo D3_CBASE(C�digo do Bem) para as requisi��es de amplia��o do BEM
*
*****
Local lRet:=.T.

If M->D3_TM$GetMv('MV_TMAMPL',,'801') .And. (Empty(M->D3_CODBEM))
	MsGBox('Para este tipo de Movimenta��o � necess�rio informar o c�digo do BEM e ITEM')
	lRet:=.f.
Endif
If !M->D3_TM$GetMv('MV_TMAMPL',,'801') .And. (!Empty(M->D3_CODBEM) .Or. !Empty(M->D3_ITEMBEM))
	MsGBox('O c�digo do Bem deve ser informado apenas para o(s) tipo(s) de movimenta��o(s):'+GetMv('MV_TMAMPL',,'801'))
	lRet:=.f.	
Endif

Return(lRet)