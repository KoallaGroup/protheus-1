/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CADCLIGED � Autor � Crislei Toledo     � Data �  21/05/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Clientes para o GED                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO PARA EPC                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

#INCLUDE "rwmake.ch"

User Function CadCliGED()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZS"

dbSelectArea("SZS")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Clientes - GED",cVldExc,cVldAlt)

Return