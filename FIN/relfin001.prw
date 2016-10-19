/*
+-----------------------------------------------------------------------+
�Programa  �RELFIN001 � Autor �Crislei de A. Toledo   � Data |03/04/2007�
+----------+------------------------------------------------------------�
�Descri��o �Relatorio de Posicao de fornecedores por conta contabil     �
+----------+------------------------------------------------------------�
� Uso      � ESPECIFICO PARA TSA / EPC                                  �
+-----------------------------------------------------------------------�
�           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            �
+-----------------------------------------------------------------------�
�PROGRAMADOR � DATA   � MOTIVO DA ALTERACAO                             �
+------------+--------+-------------------------------------------------�
|            |        |                                                 |  
+-----------------------------------------------------------------------+
*/

#include "rwmake.ch"
#include "topconn.ch"

User Function RELFIN001()

Local cPerg     := "FINR01"
Local aPerg     := {}

Local cParam    := ""
Local dEmisInic := CTOD("")
Local dEmisFina := CTOD("")
Local dVencInic := CTOD("")
Local dVencFina := CTOD("")
Local dDataRefe := CTOD("")
Local cContInic := Space(20)
Local cContFina := Space(20)
Local cFornInic := Space(06)
Local cFornFina := Space(06)
Local cEmpresa  := Space(02)


/*BEGINDOC
//���������������������������������������������������������Ŀ
//�PARAMETROS DO RELATORIO:                                 �
//�                                                         �
//�MV_PAR01   Da Emissao                                    �
//�MV_PAR02   Ate Emissao                                   �
//�MV_PAR03   Do Vencimento                                 �
//�MV_PAR04   Ate Vencimento                                �
//�MV_PAR05   Data Referencia                               �
//�MV_PAR06   Da Conta Contabil                             �
//�MV_PAR07   Ate Conta Contabil                            �
//�MV_PAR08   Do Fornecedor                                 �
//�MV_PAR09   Ate Fornecedor                                �
//�MV_PAR10   Empresa                                       �
//�����������������������������������������������������������
ENDDOC*/

AADD(aPerg,{cPerg,"Da Emissao         ?","D",08,0,"G","","","","","","",""})
AADD(aPerg,{cPerg,"Ate Emissao        ?","D",08,0,"G","","","","","","",""})
AADD(aPerg,{cPerg,"Do Vencimento      ?","D",08,0,"G","","","","","","",""})
AADD(aPerg,{cPerg,"Ate Vencimento     ?","D",08,0,"G","","","","","","",""})
AADD(aPerg,{cPerg,"Data Base          ?","D",08,0,"G","","","","","","",""})
AADD(aPerg,{cPerg,"Da Conta Contabil  ?","C",20,0,"G","","CT1","","","","",""})
AADD(aPerg,{cPerg,"Ate Conta Contabil ?","C",20,0,"G","","CT1","","","","",""})
AADD(aPerg,{cPerg,"Do Fornecedor      ?","C",06,0,"G","","SA2","","","","",""})
AADD(aPerg,{cPerg,"Ate Fornecedor     ?","C",06,0,"G","","SA2","","","","",""})


If !Pergunte(cPerg,.T.)
	Return
EndIf

dEmisInic := MV_PAR01
dEmisFina := MV_PAR02
dVencInic := MV_PAR03
dVencFina := MV_PAR04
dDataRefe := MV_PAR05
cContInic := MV_PAR06
cContFina := MV_PAR07
cFornInic := MV_PAR08
cFornFina := MV_PAR09
cEmpresa  := SM0->M0_CODIGO


If TcSpExist('EPCFIN001')
   Processa({||TcSPExec ('EPCFIN001',DTOS(dEmisInic),DTOS(dEmisFina),DTOS(dVencInic),DTOS(dVencFina),DTOS(dDataRefe),cEmpresa)},"Gerando informacoes dos Fornecedores. Aguarde...")

   cParam := DTOC(dEmisInic)+";"+DTOC(dEmisFina)+";"+DTOC(dVencInic)+";"+DTOC(dVencFina)+";"+DTOC(dDataRefe)+";"+cContInic+";"+cContFina+";"+cFornInic+";"+cFornFina+";"+cEmpresa
   //cOptions := "1;0;1;POSI��O DOS T�TULOS PAGOS"
                
   CallCrys("FIN001",cParam) //,cOptions)   
Else
   MsgBox("Nao existe a sp 'EPCFIN001', portanto este relatorio nao podera ser gerado!","Mensagem do Administrador", "STOP")
EndIf

Return