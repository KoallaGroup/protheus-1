#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function ACERTCT()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("NCONT,CSUBCTA,")

Processa( {|| RunProc() },"Acerto dos itens dos contratos","Acertando Registro ..." )// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Processa( {|| Execute(RunProc) },"Acerto dos itens dos contratos","Acertando Registro ..." )


Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Function RunProc
Static Function RunProc()

nCont:=0
dbSelectArea("SZ2")  // itens do contrato
DbSetOrder(3) //Filial+Sub-Conta
Copy to \dadosadv\itcttmp.dbf
dbGoTop()
ProcRegua(RecCount())
While ! Eof()
   cSubCta:=Z2_SUBC
   DbSkip()
   If Z2_SUBC == cSubCta
      RecLock("SZ2",.f.)
      Delete
      nCont:=nCont+1
   EndIF
EndDo
DbCommit()
MsgStop("Termino do Acerto de Itens "+StrZero(nCont,5))
RetIndex("SZ2")

Return
