#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function INPVLORC()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,CCLIENTE,CLOJA,DDATA,CNOMECLI,")

If !Empty(cNum)

   cAlias := Alias()

   dbSelectArea("SCJ")
   dbSetOrder(1)
   dbSeek(xFilial("SCJ")+cNum)

   If !Eof()
      cCliente := SCJ->CJ_CLIENTE
      cLoja    := SCJ->CJ_LOJA
      dData    := SCJ->CJ_EMISSAO

      dbSelectArea("SA1")
      dbSetOrder(1)
      dbSeek(xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA)

      cNomeCli := SA1->A1_NOME

   EndIf

   dbSelectArea(cAlias)

Else

   MsgStop("Numero do Orcamento deve ser informado")
// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==>    __Return(.F.)
Return(.F.)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

EndIf

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> __Return(.T.)
Return(.T.)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

