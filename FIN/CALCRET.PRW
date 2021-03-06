#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function CALCRET()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("AARQ,CROT,CCONTRATO,VRETURN,DDATAREF,")
Return()

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  �  CALCRET � Autor � Joao Carlos Fonseca   � Data � 14/01/04 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Rotina de Calculo dos Impostos Retidos COFINS, PIS e CLSS  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Especifico para EPC                                        낢�
굇�          � Usado sobre os LP`s                                       낢�
- EXECBLOCK("CALCRET",.F.,.F.,{"4",SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA)})
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
aArq:= { Alias() , IndexOrd() , Recno() }
aOrdSE1 := SE1->(IndexOrd()) 
aRecSE1 := SE1->(Recno()) 
vReturn := 0
/*
PARAMIXB = 1 = Calcula COFINS
PARAMIXB = 2 = Calcula PIS
PARAMIXB = 3 = Calcula CSLL
PARAMIXB = 4 = Calcula Todos
*/
dbSelectArea("SE1")
dbSetOrder(1)
dbSeek(PARAMIXB[2])
do While !eof() .And. ;
		PARAMIXB[2] = SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA)
		
	If PARAMIXB[1] $ "1_4" .AND. SE1->E1_TIPO == 'CF-'
		vReturn := vReturn + SE1->E1_VLCRUZ
	EndiF
	If PARAMIXB[1] $ "2_4" .AND. SE1->E1_TIPO == 'PI-'
		vReturn := vReturn + SE1->E1_VLCRUZ
	EndiF
	If PARAMIXB[1] $ "3_4" .AND. SE1->E1_TIPO == 'CS-'
		vReturn := vReturn + SE1->E1_VLCRUZ
	EndiF                                                       	
	
	dbSkip()
Enddo
// Voltando SE1
dbSetOrder(aOrdSE1)
dbGoto(aRecSE1)

dbSelectArea(aArq[1])
dbSetOrder(aArq[2])
dbGoTo(aArq[3])

Return(vReturn)