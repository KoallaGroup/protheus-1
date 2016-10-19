#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function VALDTVEN()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("LOK,")

******************************************************************************
* Valida se o usuario este testa o dia do vencimento onde nao pode ser maior
* que 31.
****

lOk := .T.

If M->ZC_VENCFAT > "31"
   MsgStop("O Dia do Vencimento da Fatura deve ser menor que 31")
   lOk := .F.
EndIf

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> __Return(lOk)
Return(lOk)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01
