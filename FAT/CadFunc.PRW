#INCLUDE "rwmake.ch"

/*
+---------+----------+------+----------------------------------+-------+---------+
|Programa |CADFUNC   |Autor | Crislei Toledo							| Data  | 07/05/02|	
+---------+----------+------+----------------------------------+-------+---------+
|Descricao| Cadastro de funcionarios                                             |
+--------------------------------------------------------------------------------+
|							Alteracoes feitas desde a criacao									|
+-------------+-----------+------------------------------------------------------+
|Programador  |Data       |Descricao															|
+-------------+-----------+------------------------------------------------------+
|				  |           |																		|
+-------------+-----------+------------------------------------------------------+
*/

User Function CadFunc()


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cString
Private cString := "SZD"

dbSelectArea("SZD")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Funcionarios",cVldAlt,cVldExc)

Return
