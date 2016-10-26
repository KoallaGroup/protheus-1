#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function LANPADCX()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("AARQ,AARQSI5,CCONTACO,DDATACX,")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � LANPADCX � Autor � Eduardo Carraro       � Data � 24.01.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � RDMAKE para Gravacao das Datas de Caixa e Referencia       ���
���          � no lancamento padrao.                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ESPECIFICO PARA EPC                                        ���
�������������������������������������������������������������������������Ĵ��
��� EXEMPLO  � EXECBLOCK("LANPADCX",.F.,.F.,{"CONTA CONTABIL",            ���
���          � "DATA CAIXA"})                                             ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������Ĵ��
���PROGRAMADOR � DATA  � MOTIVO DA ALTERACAO                              ���
�������������������������������������������������������������������������Ĵ��
���            �       �                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
aArq      := { Alias(), IndexOrd(), Recno() }
aArqSI5   := { SI5->(IndexOrd()), SI5->(Recno()) }
cContaCo  := PARAMIXB[1]
dDataCX   := PARAMIXB[2]
DbSelectArea("SI5")
If RecLock("SI5",.f.)
   Replace I5_ITEMC With DTOC(dDataCX)
Else
   MSGSTOP("Nao Foi Possivel Alocar os Campos de Data Caixa e Referencia no Lancamento Padrao...")
EndIf

SI5->(DbSetOrder(aArqSI5[1]))
SI5->(DbGoTo(aArqSI5[2]))

DbSelectArea(aArq[1])
DbSetOrder(aArq[2])
DbGoTo(aArq[3])

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> __Return(cContaCo)
Return(cContaCo)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01