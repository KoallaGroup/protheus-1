/*
+--------------------------------------------------------------------------+-------+-----------+
�Programa  �EPCPMS05  � Autor � Crislei de Almeida Toledo                  | Data  � 22.05.2006�
+----------+---------------------------------------------------------------+-------+-----------+
�Descri��o � Encapsula a rotina PMSA410 (Projetos Mod. 2) para inclusao de Investimento        � 
+----------+-----------------------------------------------------------------------------------+
� Uso      � ESPECIFICO PARA EPC                                                               �
+----------+-----------------------------------------------------------------------------------+
�           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                                   �
+------------+--------+------------------------------------------------------------------------+
�PROGRAMADOR � DATA   � MOTIVO DA ALTERACAO                                                    �
+------------+--------+------------------------------------------------------------------------+
�            �        �                                                                        �
+------------+--------+------------------------------------------------------------------------+
*/

#include "rwmake.ch"

User Function EPCPMS05()

dbSelectArea("AF8")
Set Filter to AF8->AF8_TIPOPJ $ "I"

//INVESTIMENTO
PMSA410()

dbSelectArea("AF8")
Set Filter to

Return