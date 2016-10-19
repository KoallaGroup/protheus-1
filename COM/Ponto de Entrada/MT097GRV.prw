#Include 'RwMake.ch'
/*
+-----------------------------------------------------------------------+
�Programa  �           � Autor � Gilson Lucas          �Data �19.08.2011�
+----------+------------------------------------------------------------�
�Descricao �Flag o PC para bloqueio apos alteracao                      �
+----------+------------------------------------------------------------�
� Uso      � ESPECIFICO PARA A TSA                                      �
+-----------------------------------------------------------------------�
�           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            �
+-----------------------------------------------------------------------�
�PROGRAMADOR � DATA   � MOTIVO DA ALTERACAO                             �
+------------+--------+-------------------------------------------------�
�            �        �                                                 �
+-----------------------------------------------------------------------+
*/
User function MT120GRV
************************************************************************
*  
****   
Local  nXi      := 0           
Local  nYi      := 0
Local  cNumPed  := Paramixb[1]
Local  lInclui  := Paramixb[2] 
Local  lAltera  := Paramixb[3] 
Local  lDeleta  := Paramixb[4]
Local  aAreaOld := Getarea()
Local  aCpoVal  := {"C7_COND","C7_FILENT","C7_DATPRF","C7_CONTATO","C7_OBS","C7_MESENTR","C7_DETCD","C7_DETPZ","C7_DETGR","C7_DETPR","C7_DETIN","C7_DETOU","C7_DETLC","C7_DETCF","C7_DETFT","C7_DETDC","C7_DISCIPL","C7_GERENCI"}
                                                                                       
Local  aAreaSC7 := SC7->(GetArea())
Public aItenDiv := {}
Public aSC7Old  := {}

 
If lAltera        
	// Tratar aqui os campos diferentes.
	aSC7Old  := {}
	dbSelectArea("SC7")	
	SC7->(dbSetOrder(1))
	SC7->(dbSeek(xFilial("SC7")+cNumPed))
	While !SC7->(Eof()) .and. xFilial("SC7")== SC7->C7_FILIAL .And.  cNumPed== SC7->C7_NUM
		Aadd(aSC7Old,{SC7->(Recno()),SC7->C7_CONAPRO})	
		SC7->(dbSkip())
	End
	
	For nXi := 1 To Len(aCols)
		If GdDeleted(nXi)	
			Aadd(aItenDiv,{0,""})
		Else
			SC7->(dbSeek(xFilial("SC7")+cNumPed+GdFieldGet("C7_ITEM",nXi)))
			If SC7->(Eof())                   
				Aadd(aItenDiv,{0,""})
			Else     
				//AADD(aHeader,{Alltrim(X3TITULO()), X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
				For nYi := 1 To len(aHeader)
					If aHeader[nYi][10] # "V" 
						If aScan(aCpoVal,Alltrim(aHeader[nYi][2])) == 0
							If GdFieldGet(aHeader[nYi][2],nXi) # SC7->&(aHeader[nYi][2])
					    		Aadd(aItenDiv,{SC7->(Recno()),SC7->C7_CONAPRO})	
					    	EndIf
					    EndIf
				    EndIf
				Next nYi 
			EndIf			
		EndIf
	Next nXi 
Else
	aMantLib := {}
EndIf 


RestArea(aAreaOld)
RestArea(aAreaSC7) 
Return(.T.)


/*
+-----------------------------------------------------------------------+
�Programa  �           � Autor � Gilson Lucas          �Data �19.08.2011�
+----------+------------------------------------------------------------�
�Descricao �Indica se a rotina deve passar pela al�ada                  �
+----------+------------------------------------------------------------�
� Uso      � ESPECIFICO PARA A TSA                                      �
+-----------------------------------------------------------------------�
�           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            �
+-----------------------------------------------------------------------�
�PROGRAMADOR � DATA   � MOTIVO DA lSaidaCAO                             �
+------------+--------+-------------------------------------------------�
�            �        �                                                 �
+-----------------------------------------------------------------------+
*/
User Function MT097GRV
************************************************************************
*
****
Local lRet    := .T.
Local cQuery  := ""

If Funname() == 'MATA121'
	If Altera .and. Empty(aItenDiv)
		lRet := .F.
	EndIf
EndIf

Return(lRet)