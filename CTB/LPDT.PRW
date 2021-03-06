/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � LANPADDT � Autor � Eduardo Carraro       � Data � 24.01.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � RDMAKE para Gravacao das Datas de Caixa e Referencia       ���
���          � no lancamento padrao.                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ESPECIFICO PARA EPC                                        ���
�������������������������������������������������������������������������Ĵ��
��� EXEMPLO  � EXECBLOCK("LANPADDT",.F.,.F.,{"DATA REF.","DATA CX",       ���
���          � "ORIGEM"})                                                 ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������Ĵ��
���PROGRAMADOR � DATA  � MOTIVO DA ALTERACAO                              ���
�������������������������������������������������������������������������Ĵ��
���            �       �                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function LPDT()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

Local cHISTORICO

//TBH127 - AJUSTE NA REF. DATA CONTABIL
//Local cDataRF := SubStr(DTOC(PARAMIXB[1]),1,6)+SubStr(DTOC(PARAMIXB[1]),9,2)
//Local cDataCX := SubStr(DTOC(PARAMIXB[2]),1,6)+SubStr(DTOC(PARAMIXB[2]),9,2)
Local cDataRF := SubStr(DTOC(PARAMIXB[1]),1,6)+SubStr(DTOC(PARAMIXB[1]),7,2)
Local cDataCX := SubStr(DTOC(PARAMIXB[2]),1,6)+SubStr(DTOC(PARAMIXB[2]),7,2)

Local cHistor := PARAMIXB[3]
Local aArea   := GetArea()
Local _aArea   		:= {}
Local _aAlias  		:= {}

CtrlArea(1,@_aArea,@_aAlias,{"SF2","SF3","SF1","SA2","SE1","SE2","CT1","CT5","CTT"}) // GetArea

If SD1->D1_TIPO <> "D"
   // ALteracao efetuada por Tiago Augusto Gomes em 19/03/01
   // Foi constatado que para o lancamento 650-01 SE2 perdia o posicionamento 
   // correto entao foi criada a estrutur abaixo que permite sanar o problema.
   If !(Left(cHistor,3) $ "655/665/656")
      dbSelectArea("SE2")
      dbSetOrder(12)
      dbSeek(xFilial("SE2")+SF1->F1_SERIE+SF1->F1_DOC+"NF "+SF1->F1_FORNECE+SF1->F1_LOJA)
      //cHistorico:= "CX:" + SubStr(DTOC(SE2->E2_VENCREA),1,6)+SubStr(DTOC(SE2->E2_VENCREA),9,2) + " RF:" + cDataRF + " - " + cHistor
      cHistorico:= "CX:" + SubStr(DTOC(SE2->E2_VENCREA),1,6)+SubStr(DTOC(SE2->E2_VENCREA),7,2) + " RF:" + cDataRF + " - " + cHistor
   Else  
      cHistorico:= "CX:" + cDataCX + " RF:" + cDataRF + " - " + cHistor
   Endif
Else
   If !(Left(cHistor,3) $ "655/665/656")
      dbSelectArea("SE1")
      dbSetOrder(2)
      dbSeek(xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC)
   
      cHistorico:= "CX:" + SubStr(DTOC(SE1->E1_VENCREA),1,6)+SubStr(DTOC(SE1->E1_VENCREA),7,2) + " RF:" + cDataRF + " - " + cHistor   
   Else
      cHistorico:= "CX:" + cDataCX + " RF:" + cDataRF + " - " + cHistor   
   EndIf
EndIf



//Retaura o posicionamento das tabelas
CtrlArea(2,_aArea,_aAlias) // RestArea

//Restaurando Ambiente Anterior
RestArea(aArea)

Return(cHistorico)



Static Function CtrlArea(_nTipo,_aArea,_aAlias,_aArqs)                       
*******************************************************************************************************************
*
*
****
Local _nN                                                                    
	// Tipo 1 = GetArea()                                                      
	If _nTipo == 1                                                             
		_aArea   := GetArea()                                                   
		For _nN  := 1 To Len(_aArqs)                                            
			DbSelectArea(_aArqs[_nN])                                            
			AAdd(_aAlias,{ Alias(), IndexOrd(), Recno()})                        
		Next                                                                    
	// Tipo 2 = RestArea()                                                     
	Else                                                                       
		For _nN := 1 To Len(_aAlias)                                            
			DbSelectArea(_aAlias[_nN,1])                                         
			DbSetOrder(_aAlias[_nN,2])                                           
			DbGoto(_aAlias[_nN,3])                                               
		Next                                                                    
		RestArea(_aArea)                                                        
	Endif                                                                      
Return Nil                                                                   

