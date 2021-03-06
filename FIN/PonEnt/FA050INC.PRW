/*
+----------------------------------------------------------------------------+
�Programa  � F050INC  � Autor � Crislei de Almeida Toledo  � Data �21.02.2006�
+----------+-----------------------------------------------------------------+
�Descri��o � Ponto de Entrada na rotina de Inclusao  de Contas a Pagar       �
�          � Validar campos E2_DIRF e E2_CODRET                              �
+----------+-----------------------------------------------------------------+
� Uso      � ESPECIFICO PARA EPC                                             �
+----------------------------------------------------------------------------+
�           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                 �
+----------------------------------------------------------------------------+
�PROGRAMADOR � DATA   � MOTIVO DA ALTERACAO                                  �
+------------+--------+------------------------------------------------------+
�            �        �                                                      |
+----------------------------------------------------------------------------+
*/

#INCLUDE "RWMAKE.CH"

User Function FA050INC()

Private lRet    := .T.

//Valida��o para n�o permitir inclus�o ou altera��o do titulo sem informar o codigo de reten�ao
//se o campo Gera Dirf for igual a Sim.
If M->E2_DIRF $ "1"
	If AllTrim(M->E2_CODRET) == ""
		MsgBox(OemToAnsi("O campo 'Cd. Reten��o' precisa ser informado quando o campo 'Gera Dirf' for igual a 'Sim'."),"Gera Dirf","STOP")
		lRet := .F.
	EndIf
EndIf

If DDATABASE <= GETMV("MV_DATAFIN")
	MsgStop(OemToAnsi("Data Base p/ realiza��o de opera��es financeiras deve ser maior que: ")+DTOC(GETMV("MV_DATAFIN")))
	lRet := .F.
EndIf

If (ALLTRIM(M->E2_TIPO) $ "LSG/FIN") .And. M->E2_VJUREMP == 0
	MsgStop("Para t�tulos de tipo "+ALLTRIM(M->E2_TIPO)+" - "+IIF(ALLTRIM(M->E2_TIPO) = "LSG","(LEASING)","(FINANCIAMENTO)") + " dever� ser informado o campo Jur. LSG/FIN!" )
	lRet := .F.
EndIf

Return(lRet)
