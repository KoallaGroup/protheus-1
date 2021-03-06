//|=====================================================================|//
//| Desenvolvedor: Clemilson Pena -> chr13.net                          |//
//| Data: 06/2014                                                       |//
//| Descricao: Banco de Horas                                           |//   
//| Alterado por Thiago Santos em 15/07/2016                                        |//
//|=====================================================================|//

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH" 
#include "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function GerBcHora() 

	Local cQuery := "" 
	Local nSeq   := 0
	Local nValor := 0
	Local aErros := {}
	Local cLote  := "95"+StrZero(0,4)
	Local lInserie := .T.
	Local nTam1 := 0,nTam2 := 0,nY := 0
	Local cErros := ""
	
	Local cGRUPG00  := Alltrim(GetMV("CN_BCHORA1")) 
	Local cGRUPG97  := Alltrim(GetMV("CN_BCHORA2"))
	
	Local cConta00  := Alltrim(GetMV("CN_BCHOCC1")) 
	Local cConta97  := Alltrim(GetMV("CN_BCHOCC2"))
	
/*	cQuery  := " DELETE "+RetSqlName("SZ0")
	cQuery  += " WHERE Z0_DTLANC >= '20070101' AND Z0_REVISAO='' AND Z0_VEICULO != 'S' AND Z0_LOTE = '"+cLote+"' "
	TCSQLExec(cQuery)*/ 
	
	U_Pn200CalMp()

	if select("TMP") <> 0
		TMP->(dbCloseArea())
	endif 	

	cQuery := " SELECT YEAR(PI_DATA) AS ANO, "
	cQuery += "        MONTH(PI_DATA) AS MES, "
	cQuery += "        PI_CC, " 
	cQuery += "        PI_PD, " 
	cQuery += "        PI_FILIAL, " 
	cQuery += "        SUM(PI_QUANTMP) AS PI_QUANT, "
	cQuery += "        (Round(SUM((PI_QUANTMP*(RA_SALARIO/RA_HRSMES))),2)*1.5)*(-1) AS VALOR "
	cQuery += " FROM "+RetSqlName("CBH")+" AS SPI "
	cQuery += " INNER JOIN "+RetSqlName("SRA")+" AS SRA ON RA_MAT = PI_MAT "
	cQuery += " WHERE PI_PD = '023' "      
	cQuery += " AND SPI.PI_DATA >= '20140801' " 
	cQuery += " AND SPI.D_E_L_E_T_ = '' " 
	cQuery += " AND SRA.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY YEAR(PI_DATA), MONTH(PI_DATA),PI_FILIAL,PI_CC,PI_PD,PI_CONTA "
	cQuery += " ORDER BY YEAR(PI_DATA), MONTH(PI_DATA),PI_FILIAL,PI_CC,PI_PD,PI_CONTA "
		
/*	cQuery := " SELECT * FROM "+RetSqlName("SPI")+" AS SPI "
	cQuery += " LEFT JOIN "+RetSqlName("SRA")+" AS SRA ON RA_MAT = PI_MAT " 
	cQuery += " LEFT JOIN "+RetSqlName("CTT")+" AS CTT ON PI_CC = CTT_CUSTO " 
	cQuery += " LEFT JOIN "+RetSqlName("SZ1")+" AS SZ1 ON Z1_COD = CTT_CODCON " 
	cQuery += " LEFT JOIN "+RetSqlName("SZA")+" AS SZA ON ZA_GRUPGER = '000008' " 
	cQuery += " LEFT JOIN "+RetSqlName("SP9")+" AS SP9 ON P9_CODIGO = PI_PD "
	cQuery += " WHERE SPI.D_E_L_E_T_ = '' "
	cQuery += " AND ISNULL(SRA.D_E_L_E_T_,'') = '' " 
	cQuery += " AND ISNULL(CTT.D_E_L_E_T_,'') = '' " 
	cQuery += " AND ISNULL(SZ1.D_E_L_E_T_,'') = '' " 
	cQuery += " AND ISNULL(SZA.D_E_L_E_T_,'') = '' " 
	cQuery += " AND ISNULL(SP9.D_E_L_E_T_,'') = '' " */
	
	//u_impt2(ChangeQuery(cQuery))
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,ChangeQuery(cQuery)),"TMP", .T., .F.)

	TMP->(dbGoTop())      
	
	While !(TMP->(eof())) 
				
		lInserie := .T.
		dbSelectArea("SP9")
		SP9->(dbSetOrder(1)) //P9_FILIAL+P9_CODIGO 
		if !(SP9->(dbSeek(xFilial("SP9")+TMP->PI_PD))) //P9_CODIGO = PI_PD 
			aadd(aErros,{"Procurar registro na SP9",xFilial("SP9")+TMP->PI_PD,TMP->MES,TMP->ANO,TMP->PI_CC,TMP->PI_PD})
			lInserie := .F.
		endif
		
		dbSelectArea("SZA")
		SZA->(dbSetOrder(1)) //ZA_FILIAL+ZA_GRUPGER
		if !(SZA->(dbSeek(xFilial("SZA")+IIF(TMP->PI_FILIAL=="97",cGRUPG97,cGRUPG00)))) //ZA_GRUPGER = '000008'
			aadd(aErros,{"Procurar registro na SZA",xFilial("SZA")+IIF(TMP->PI_FILIAL=="97",cGRUPG97,cGRUPG00),TMP->MES,TMP->ANO,TMP->PI_CC,TMP->PI_PD})
			lInserie := .F.
		endif
		
		dbSelectArea("CTT")
		CTT->(dbSetOrder(1)) //CTT_FILIAL+CTT_CUSTO 
		if !(CTT->(dbSeek(xFilial("CTT")+TMP->PI_CC))) //PI_CC = CTT_CUSTO
			aadd(aErros,{"Procurar registro na CTT",xFilial("CTT")+TMP->PI_CC,TMP->MES,TMP->ANO,TMP->PI_CC,TMP->PI_PD})
			lInserie := .F.
		endif
				
		dbSelectArea("SZ1")
		SZ1->(dbSetOrder(1)) //Z1_FILIAL+Z1_COD+Z1_CODCLI 
		if !(SZ1->(dbSeek(xFilial("SZ1")+CTT->CTT_CODCON))) //Z1_COD = CTT_CODCON
			aadd(aErros,{"Procurar registro na SZ1",xFilial("SZ1")+CTT->CTT_CODCON,TMP->MES,TMP->ANO,TMP->PI_CC,TMP->PI_PD})
			lInserie := .F.
		endif
				
		if lInserie

			nSeq += 1
		
			RecLock("SZ0",.T.)//FLUXO ECONOMICO               
				Replace Z0_FILIAL  with xFilial('SZ0') // Filial (C,  2,  0)* Campo n�o usado
				Replace Z0_LINHA   with 'PV' // Linha Doc. (C,  2,  0)
				//Replace Z0_REVISAO with 'Se estimado "AnoMes"' // REVISAO (C,  6,  0)
				//Replace Z0_VRPREV  with TMP->AK2_VALOR // Vlr Prev (N, 12,  2)
				Replace Z0_HIST    with SP9->P9_CODIGO + " - " + SP9->P9_DESC // Historico (C, 40,  0)
				Replace Z0_LOTE    with cLote // Lote (C,  6,  0)
				Replace Z0_DOC     with StrZero(nSeq,9) // Documento (C,  9,  0)
				Replace Z0_VALOR   with TMP->VALOR // Valor (N, 14,  2)
				Replace Z0_CUSTO   with TMP->VALOR // Custo (N, 14,  2)
				Replace Z0_CONTA   with IIF(TMP->PI_FILIAL=="97",cConta97,cConta00) // Conta (C, 20,  0)
				Replace Z0_CC      with TMP->PI_CC // Centro Custo (C, 20,  0)
				Replace Z0_GRUPGER with SZA->ZA_GRUPGER // Grupo Gerenc (C,  6,  0)
				Replace Z0_FATOR   with SZA->ZA_FATOR // Fator (N, 12,  2)
				Replace Z0_DESGER  with SZA->ZA_DESCRI // Desc Grupo (C, 40,  0)			
				Replace Z0_DESC01  with CTT->CTT_DESC01 // Desc. CCusto (C, 40,  0)
				Replace Z0_SITUACA with SZ1->Z1_SITUAC // Situacao (C, 45,  0)			
				Replace Z0_CLIENTE with SZ1->Z1_CLIENTE // Cliente (C, 40,  0)
				Replace Z0_CODCONT with CTT->CTT_CODCON // CodCont (C,  5,  0)
				Replace Z0_DTREF   with StrZero(TMP->MES,2)+"/"+right(cValToChar(TMP->ANO),2) // Dt. Refer. (C,  5,  0)
				Replace Z0_DTLANC  with Date() // Dt Lancament (D,  8,  0)
																
	/*			Replace Z0_DTREF   with CAMPO09 // Dt. Refer. (C,  5,  0)
				Replace Z0_DATA    with CAMPO10 // Data (C,  5,  0)
				Replace Z0_DTCAIXA with CAMPO11 // Dt. Caixa (C,  5,  0)
				Replace Z0_DTVENC  with CAMPO12 // Vencto (C,  5,  0)
				Replace Z0_SITUACA with CAMPO17 // Situacao (C, 45,  0)
				Replace Z0_RECEITA with CAMPO14 // Receita (N, 14,  2)
				Replace Z0_DTRF1   with CAMPO16 // DATA REF (C,  4,  0)
				Replace Z0_CLASSIF with CAMPO18 // CLASSIF (C, 45,  0)
				Replace Z0_GRUPO   with CAMPO19 // GRUPO_GERAL (C, 45,  0)
				Replace Z0_DRE     with CAMPO20 // DRE (C, 15,  0)
				Replace Z0_DTLANC  with CAMPO21 // Dt Lancament (D,  8,  0)
				Replace Z0_FATORE  with CAMPO27 // Fator Receit (N, 12,  2)
				Replace Z0_SITUAC  with CAMPO29 // Sit. Contrat (C,  1,  0)
				Replace Z0_PROP    with CAMPO30 // Prop (C, 20,  0)
				Replace Z0_OS      with CAMPO31 // os (C,  2,  0)
				Replace Z0_SETOR   with CAMPO32 // Setor (C,  5,  0)
				Replace Z0_DESCSET with CAMPO33 // Setor (C, 40,  0)
				Replace Z0_SUBCTA  with CAMPO35 // SubCta (C,  6,  0)
				Replace Z0_SETORIG with CAMPO36 // Setor Origem (C,  5,  0)
				Replace Z0_VEICULO with CAMPO37 // Veiculos (C,  1,  0)
				Replace Z0_DESC2   with CAMPO40 // Desc.Despesa (C, 40,  0)
				Replace Z0_CODPLA  with CAMPO41 // Planilha (C, 15,  0) */
			MsUnLock("SZ0")      

		Endif
		
		TMP->(dbSkip())
		
	EndDo
	
	if select("TMP") <> 0
		TMP->(dbCloseArea())
	endif 
	
	if Len(aErros) != 0
	
		for nY := 1 To len(aErros)
			nTam1 := MAX(nTam1,Len(aErros[nY][1]))
			nTam2 := MAX(nTam2,Len(aErros[nY][2]))
		Next
		
		cErros += PADC("Erro",nTam1,Space(1))
		cErros += Space(1)	
		cErros += PADC("Indice",nTam2,Space(1))
		cErros += Space(1)	
		cErros += PADC("Mes",4,Space(1))
		cErros += Space(1)	
		cErros += PADC("Ano",4,Space(1))
		cErros += Space(1)	
		cErros += PADC("CC",Len(aErros[1][5]),Space(1))
		cErros += Space(1)	
		cErros += PADC("Verba",Len(aErros[1][6]),Space(1))
		cErros += chr(13)+chr(10)		
		
		cErros := upper(cErros)
		
		for nY := 1 To len(aErros)
			aErros[nY][1] := PADL(aErros[nY][1],nTam1,Space(1))
			aErros[nY][2] := PADL(aErros[nY][2],nTam2,Space(1)) 
	
			aErros[nY][3] := PADC(StrZero(aErros[nY][3],2),4,Space(1)) 
			aErros[nY][4] := StrZero(aErros[nY][4],4)
			
			cErros += aErros[nY][1]	
			cErros += Space(1)	
			cErros += aErros[nY][2]
			cErros += Space(1)	
			cErros += aErros[nY][3]	
			cErros += Space(1)	
			cErros += aErros[nY][4]
			cErros += Space(1)	
			cErros += aErros[nY][5]	
			cErros += Space(1)	
			cErros += aErros[nY][6]
			cErros += chr(13)+chr(10)
			
		Next	
	
		U_MsgFull(cErros)
		
	endif

Return