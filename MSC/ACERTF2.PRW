#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function ACERTF2()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("AARQ,")

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  � ACERTF2  � Autor 쿐duardo Carraro        � Data � 01/09/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri놹o � Rotina para Acerto do F2 quanto ao Contrato                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Especifico para EPC/TSA                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Processa( {|| Acerta() },"Gravacao do Contrato nas Notas","Gravando Registro ..." )// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Processa( {|| Execute(Acerta) },"Gravacao do Contrato nas Notas","Gravando Registro ..." )


*****************************************************************************
* Rotina de Gravacao
********************


Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Function Acerta
Static Function Acerta()

aArq    := { Alias(), IndexOrd(), Recno() }

dbSelectArea("SF2")
DbSetOrder(1) //Doc +Serie
DbGoTop()
ProcRegua(LastRec())
While ! Eof()
    IncProc()
    DbSelectArea("SC5") //Pedido
    DbSetOrder(5) //Filial+Nota+Serie
    If DbSeek(xFilial("SC5")+SF2->F2_DOC+SF2->F2_SERIE)
       DbSelectArea("SF2")
       If RecLock("SF2",.f.)
          Replace F2_Contrat With SC5->C5_CONTRAT
          MsUnlock()
       EndIf
    EndIf
    DbSelectArea("SF2")
    DbSkip()
End

//Restaurando Ambiente
DbSelectArea(aArq[1])
DbSetOrder(aArq[2])
DbGoTo(aArq[3])
RetIndex("SF2")
MsgBox("Gravacao Terminada Com Exito!","Termino","INFO")

Return


