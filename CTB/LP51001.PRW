#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01
 
User Function LP51001()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CNATUREZ,CPROVISA,CTIPO,NVALOR,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � LP51001  � Autor �Tiago Augusto Gomes    � Data �09/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Este Rdmake tem apenas a funcao de validar se deve retor-  ���
���          � nar valores.  (criado porque no dia nao podia parar o pes- ���
���          � sol para aumentar o campo ).                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para EPC                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
cNaturez := SUBSTR(paramixb[1],1,3)
cProvisa := ALLTRIM(paramixb[2])
cTipo    := ALLTRIM(paramixb[3])
nValor   := paramixb[4]
CContabil := "21230002"
if cNaturez <> "118" .AND. cProvisa == "S" .AND. cTipo <> "TX"
   	    nValor := 0 
   else
   	    nValor := 0
endif

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> __Return(nValor)
Return(nValor)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

