#INCLUDE "rwmake.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �PMSCADFIN � Autor � Crislei de A. Toledo � Data �  04/07/07   ���
���������������������������������������������������������������������������͹��
���Descricao � Cadastro de Finalidade da GRD                                ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO EPC                                               ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

User Function PMSCADFIN()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZZ2"

dbSelectArea("ZZ2")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Finalidade da GRD",cVldExc,cVldAlt)

Return