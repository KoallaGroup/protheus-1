#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CADTPDOC  � Autor � Crislei Toledo     � Data �  28/08/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Tipos de Documento                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico EPC                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CadTpDoc()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZZ1"

dbSelectArea("ZZ1")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Tipos de Documento",cVldExc,cVldAlt)

Return
