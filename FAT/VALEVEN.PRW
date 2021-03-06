#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function VALEVEN()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("AARQ,LRET,NPOS4,NVLRTOT,NXK,")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � ValEven    � Autor 쿐duardo Carraro      � Data � 18.11.99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿣alidacao dos valores dos eventos digitados na multiline    낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Em conjunto com o InputCtr.prw - Exclusivo para EPC        낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
aArq := { Alias(), IndexOrd(), Recno() }
lRet :=.T.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� verifica se os Valores Nao estao Abusivos sobre o Contrato �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If Empty(M->Z3_VALOR)
   MsgStop("Valor do Evento Deve Ser Informado !")
   lRet:=.F.
EndIf
nPos4 := aScan(aHeader,{|aAux|alltrim(aAux[2]) == "Z3_VALOR"})
nVlrTot:=0
For nxk := 1 To Len(aCols)
    If ! aCols[nXK,Len(aHeader)+1] .and. nXK #n
       nVlrTot:=nVlrTot+aCols[nxK,nPos3]
    EndIf
Next

Do Case
   Case ! Empty(SZ1->Z1_VRPREV3)
      If nVlrTot+M->Z3_VALOR > SZ1->Z1_VRPREV3
         lRet:=.f.
         MsgBox("Somatorio de Valores dos Eventos Ultrapassam Valor Previsto do Contrato!","Erro!!!","STOP")
      EndIf
   Case ! Empty(SZ1->Z1_VRPREV2)
      If nVlrTot+M->Z3_VALOR > SZ1->Z1_VRPREV2
         lRet:=.f.
         MsgBox("Somatorio de Valores dos Eventos Ultrapassam Valor Previsto do Contrato!","Erro!!!","STOP")
      EndIf
   Case ! Empty(SZ1->Z1_VRPREV1)
      If nVlrTot+M->Z3_VALOR > SZ1->Z1_VRPREV1
         lRet:=.f.
         MsgBox("Somatorio de Valores dos Eventos Ultrapassam Valor Previsto do Contrato!","Erro!!!","STOP")
      EndIf
   Case ! Empty(SZ1->Z1_VRPREV)
      If nVlrTot+M->Z3_VALOR > SZ1->Z1_VRPREV
         lRet:=.f.
         MsgBox("Somatorio de Valores dos Eventos Ultrapassam Valor Previsto do Contrato!","Erro!!!","STOP")
      EndIf
EndCase
DbSelectArea(aArq[1])
DbSetOrder(aArq[2])
DbGoTo(aArq[3])

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> __Return(lRet)
Return(lRet)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01
