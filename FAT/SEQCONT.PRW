#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function SEQCONT()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CINICONTR,NCONTRATO,CCONTRATO,")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un놹o    쿞EQCONT   � Autor � Eduardo Carraro       � Data � 18-11-99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri눯o 쿎ontador do codigo do contrato da EPC/TSA                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       쿑un눯o disparada pelo Inicializador Padrao do Z1_COD        낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
// Buscar o 즠timo n즡ero do sequencial do Contrato,
// do grupo correspondente, na tabela 95
If SM0->M0_CODIGO == "03" //LYNX
   cIniContr := Tabela("94","LYNX")
Else
   cIniContr := Tabela("94","TSA")
EndIf

//Transformar o conte즔o de alfa para num굍ico e somar 1
nContrato := val(cIniContr)+1

//Retornar o contador para alfa, com zeros � esquerda
cContrato:=" "
cContrato:=StrZero(nContrato,4)

//Montar o c줰igo do Contrato, do tipo Empresa+Sequencial
If SM0->M0_CODIGO == "03" //LYNX
   cIniContr:= "L" + cContrato
Else
   cIniContr:= "T" + cContrato
EndIF

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> __Return(cIniContr)
Return(cIniContr)        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01
