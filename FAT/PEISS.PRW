#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function PEISS()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("AARQ,NVALISS,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �  PEISS   � Autor � Eduardo Carraro       � Data � 23/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de Entrada p/ gravacao do ISS do SF2->F2_VALISS no   ���
���          � titulo financeiro gerado para o imposto(SE2)               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para EPC                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
aArq:={Alias(),IndexOrd(),Recno()}

nValIss  := 0

nValISS := SF2->F2_VALISS
msgstop(nValIss)

DbSelectArea(aArq[1])
DbSetOrder(aArq[2])
DbGoTo(aArq[3])

return(nValISS)