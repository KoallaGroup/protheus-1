/*
+---------+----------+------+----------------------------------+-------+---------+
|Programa |CADCALCON |Autor | Crislei Toledo							| Data  | 02/05/02|	
+---------+----------+------+----------------------------------+-------+---------+
|									Especifico para EPC												|
+--------------------------------------------------------------------------------+
|							Alteracoes feitas desde a criacao									|
+-------------+-----------+------------------------------------------------------+
|Programador  |Data       |Descricao															|
+-------------+-----------+------------------------------------------------------+
|				  |           |																		|
+-------------+-----------+------------------------------------------------------+
*/

#INCLUDE "rwmake.ch"
User Function CadCalCon()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cString

Private cString := "SZJ"

dbSelectArea("SZJ")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Calendario/Contrato",cVldAlt,cVldExc)

Return
