


User function Mt241tok()
***********************************************************************************************************************
* Esta rotina tem como Objetivo validar o campo D3_CBASE(C�digo do Bem) para as requisi��es de amplia��o do BEM
*
*****
Local lRet:=.T.
For nLin:=1 to Len(aClos)
	If !GdDeleted(nLin)
		If GdFieldGet("D3_TM",nLin)$GetMv('MV_TMAMPL',,'801') .And. (Empty(GdFieldGet("D3_CODBEM",nLin)) .Or. Empty(GdFieldGet("D3_ITEMBEM",nLin)) )
			MsGBox('Para este tipo de Movimenta��o � necess�rio informar o c�digo do BEM')
			lRet:=.f.
		Endif
	Endif
Next nLin

Return(lRet)