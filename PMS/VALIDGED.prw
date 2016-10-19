/*
+-------------------------------------------------------------------------+-------+-----------+
�Programa  �VALIDGED � Autor � Crislei de Almeida Toledo                  | Data  � 28.08.2007�
+----------+--------------------------------------------------------------+-------+-----------+
�Descri��o � Validacoes especificas para o GED                                                � 
+----------+----------------------------------------------------------------------------------+
� Uso      � ESPECIFICO PARA EPC                                                              �
+----------+----------------------------------------------------------------------------------+
�           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                                  �
+------------+--------+-----------------------------------------------------------------------+
�PROGRAMADOR � DATA   � MOTIVO DA ALTERACAO                                                   �
+------------+--------+-----------------------------------------------------------------------+
�            �        �                                                                       �
+------------+--------+-----------------------------------------------------------------------+
*/
#include "rwmake.ch"
#include "topconn.ch"

User Function ValidGED(cTipo, cCampo)

Local lRet := .T.
Local aCaracInv := {":","\","/","<",">","*","?","|",'"',"'",";"}
Local nxI := 0 

Do Case
   Case cTipo $ "S" //Validacao da String contida em cCampo (Desc. do Projeto, Cliente, Tipo de Documento, Sub Disciplina)
        For nxI := 1 To Len(aCaracInv)
            If aCaracInv[nxI] $ &cCampo
               MsgBox(OemToAnsi("N�o � permitido utilizar caracteres como " + aCaracInv[nxI] + " nesta descri��o"))
               lRet := .F.
               Exit
            EndIf
        Next nxI
   Case cTipo $ "I"  //Garante a Integridade Referencial entre as tabelas especificas criadas
        
EndCase

Return(lRet)