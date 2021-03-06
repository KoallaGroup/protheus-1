#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function ACERC5()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("AARQ,CINDEX,NINDEX,")

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  � ACERC5   � Autor 쿐duardo Carraro        � Data � 01/09/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri놹o � Rotina para Acertos diversos no SC5 e SF2                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Especifico para EPC/TSA                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Processa( {|| Acerta() },"Acerto nos Pedidos de Venda","Acertando Registro ..." )// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Processa( {|| Execute(Acerta) },"Acerto nos Pedidos de Venda","Acertando Registro ..." )


*****************************************************************************
* Rotina de Acerto
********************


Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Function Acerta
Static Function Acerta()

aArq    := { Alias(), IndexOrd(), Recno() }

dbSelectArea("SD2")
cIndex:= CriaTrab(NIL,.F.)
IndRegua("SD2",cIndex,"D2_FILIAL+D2_PEDIDO+D2_CLIENTE+D2_LOJA",,,"Selecionando Registros ...")
nIndex:=RetIndex("SD2")
DbSetOrder(nIndex)

DbSelectArea("SC5") //Pedidos
DbSetOrder(1) //Filial+Pedido
DbGoTop()
ProcRegua(LastRec())
While ! Eof()
   IncProc("Acertando Registros")
   DbSelectArea("SD2") //Itens
   DbSetOrder(nIndex)
   If DbSeek(xFilial("SD2") + SC5->C5_NUM+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
      DbSelectArea("SC5")
      If RecLock("SC5",.f.)
         Replace C5_NOTA  With SD2->D2_DOC
         Replace C5_SERIE With SD2->D2_SERIE
         MsUnlock()
      EndIf
   EndIf
   DbSelectArea("SC5")
   DbSkip()
End

//Restaurando Ambiente
DbSelectArea(aArq[1])
DbSetOrder(aArq[2])
DbGoTo(aArq[3])
RetIndex("SF2")

MsgBox("Acerto Terminado Com Exito!","Termino","INFO")

Return
