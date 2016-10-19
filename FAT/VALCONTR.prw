#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function VALCONTR()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("LRET,CALIVAL,CTIPOCONT,")

******************************************************************************
* Valida o Campo de Custo do Orcamento.
****

lRet := .T.

If !Empty(cContrato)

   cAliVal := Alias()

   dbSelectArea("SZ1")
   dbSetOrder(1)
   dbSeek(xFilial("SZ1")+cContrato)

   If !Eof()
      cTipoCont := SZ1->Z1_TIPO
   Else
      MsgStop("Contrato deve estar cadastrado")
      lRet := .F.
   EndIf

   dbSelectArea(cAliVal)

Else
   MsgStop("Contrato deve ser informado")
   lRet := .F.
EndIf

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> __Return(lRet)
Return(lRet)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01
