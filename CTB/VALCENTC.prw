#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function VALCENTC()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("LRET,CALIVAL,")

******************************************************************************
* Valida o Campo de Custo do Orcamento.
****

lRet := .T.

If ! Empty(cContrato)

   cAliVal := Alias()

   dbSelectArea("SZ2")
   dbSetOrder(2)
   dbSeek(xFilial("SZ2")+cContrato+cCentCust)

   If Eof()
      MsgStop("Centro de Custo deve estar cadastrado no Contrato")
      lRet := .F.
   EndIf

   dbSelectArea(cAliVal)

Else
   MsgStop("Centro de Custo deve ser informado")
   lRet := .F.
EndIf

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> __Return(lRet)
Return(lRet)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01
