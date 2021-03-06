#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF  

User Function CONR120B()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("TITULO,CDESC1,CDESC2,CDESC3,WNREL,CSTRING")
SetPrvt("ARETURN,NOMEPROG,ALINHA,NLASTKEY,CPERG,CABEC1")
SetPrvt("CABEC2,CCANCEL,TAMANHO,LI,M_PAG,CLOTEINI")
SetPrvt("CLOTEFIM,DDATADE,DDATAATE,CCODICONT,CMOED,CTIPORELA")
SetPrvt("LSALTPAGI,CTIPOIMPR,LDESMEMBRA,LIMITE,NTOTDEB,NTOTCRD")
SetPrvt("NTOTDIG,DDATAINI,CDOCANT,NTOTTINF,NTOTTDEB,NTOTTCRED")
SetPrvt("NTOTTDIG,NTOTTDIF,NVALLANC,NDIFDBCR,DDATAATU,CPER")
SetPrvt("CPERIODOI2,CPERIODO,CBTXT,CBCONT,NTOTRDDEB,NTOTRDCRD")
SetPrvt("NTOTDIAS,NTOTHIST,CRESDEB,CRESCRD,LCUSTO,CDIGVER")
SetPrvt("DDATA,CDEBITO,CCREDITO,CFILTRO,CFILTERUSER,LARQTMP")
SetPrvt("CMESATU17,CTOTINFO,CTOTDEBIT,CTOTDIGI,CTOTCREDI,CDIFER")
SetPrvt("CDIF,CTOTGER,CANALITICO,LEND,CLOTE,")

#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 25/06/01 ==> 	#DEFINE PSAY SAY
#ENDIF  
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � Conr120B � Autor � Alcides R. de Andrade � Data � 25.11.99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Rela뇙o de Lancamentos por Lote para EPC - Voucher         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � Conr120B                                                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          � Foi alterado o programa original CONR120, para se adaptar  낢�
굇� Uso      � ao lay-out do relatorio emitido pelo cliente, facilitando  낢�
굇�          � desta forma sua analise e conferencia.                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

titulo   := "Relacao de Lotes"
cDesc1   := "Este programa tem o objetivo de emitir a  rela뇙o  de  lotes"
cDesc2   := "digitados. Poder� ser emitido de forma Anal죜ica (todos lan-"
cDesc3   := "놹mentos) ou Sint굏ica (Apenas os totais do lote)."
wnrel    := "CONR120B"            //Nome Default do relatorio em Disco
cString  := "SI2"
aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nomeprog :="CONR120B"
aLinha   := { }
nLastKey := 0
cPerg    :="COR120"
cabec1   := " " 
cabec2   := " "
cCancel  := "***** CANCELADO PELO OPERADOR *****"
tamanho  := "M"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
li     := 80
m_pag  := 1

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
pergunte("COR120",.F.)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para parametros                         �
//� mv_par01      // do lote                                     �
//� mv_par02      // at� o lote                                  �
//� mv_par03      // da data                                     �
//� mv_par04      // ate a data                                  �
//� mv_par05      // Cod Conta ou Reduzido                       �
//� mv_par06      // Moeda                                       �
//� mv_par07      // Tipo do Relatorio (Analitico ou Sintetico)  �
//� mv_par08      // Salta pagina por lote                       �
//� mv_par09      // Imprime? Lancamento / Pre-Lancamento        �
//� mv_par10      // Desmembra ?                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸




//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wnrel :="CONR120B"            //Nome Default do relatorio em Disco
WnRel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

cLoteIni   := mv_par01
cLoteFim   := mv_par02
dDataDe    := mv_par03
dDataAte   := mv_par04
cCodiCont  := mv_par05
cMoed      := mv_par06
cTipoRela  := mv_par07
lSaltPagi  := mv_par08
cTipoImpr  := mv_par09
lDesmembra := mv_par10

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
Endif


#IFDEF WINDOWS
       RptStatus({|| Cr120Imp()})// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==>        RptStatus({|| Execute(Cr120Imp)})
#ELSE
       Cr120Imp()
#ENDIF
   

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컴쩡컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇� Fun뇚o    � Cr120Imp � Autor � Wagner Xavier         � Data � 05/11/93 낢�
굇쳐컴컴컴컴컴탠컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇� Descri뇚o � Relacao de Lotes                                           낢�
굇쳐컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇� Sintaxe   � Cr120Imp(lEnd,wnRel,cString)                               낢�
굇쳐컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇� Uso       � SIGACON                                                    낢�
굇쳐컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇쿌lteracoes � Alterador por Alcides R. de Andrade em 25.11.99            낢�
굇읕컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Function Cr120Imp
Static Function Cr120Imp()

limite      := 132
nTotDeb     := 0
nTotCrd     := 0
nTotDig     := 0
dDataIni    := Periodo(dDataDe,cMoed)
cDocAnt     := " "
nTotTInf    := 0
nTotTDeb    := 0
nTotTCred   := 0
nTotTDig    := 0
nTotTDif    := 0
nValLanc    := 0
nDifDbCr    := 0
dDataAtu    := dDataDe
cPer        := " "
//cPeriodoI2  := " "
cPeriodo    := " "
cbtxt       := SPACE(10)
cbcont      := 0
nTotRdDeb   := 0
nTotRdCrd   := 0
nTotDias    := 0
nTotHist    := 0
cResDeb     := " "
cResCrd     := " "
lCusto      := .F.
cDigVer     := GetMv("MV_DIGVER")
dData       := ctod ("  /  /  ")
cDebito     := " "
cCredito    := " "
cFiltro     := " "
cFilterUser := " " 
lArqTmp     := .F.
cMesAtu17   := " " 
cTotInfo    := "Total Informado : "
cTotDebit   := "Total Debito :"
cTotDigi    := "Total Digitado  :"
cTotCredi   := "Total Credito:"
cDifer      := "Diferenca Total:"
cDif        := "Dif Debito/Credito:"
cTotGer     := "TOTAL GERAL ----->"
cAnalitico  := " - Analitico"

cabec1 :="Conta     Nome Conta                 Lancto. Historico                                        Debito        Credito   C.Custo "
cabec2 := " " 

dDataAtu := dDataAte

// Se a moeda escolhida, nao esta em uso -> sai do programa.
If Empty(GetMv("MV_MOEDA"+Str(cMoed,1)))
	Set Filter To
	Return
End

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Calcula o Periodo do relatorio                               �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dDataIni:=Periodo(dDataDe,cMoed)

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("I2_CCD")
If X3Uso(X3_USADO)
	 lCusto := .T.
End
dbSetOrder(1)


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Localiza Lancamento inicial                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

dbSelectArea("SI2")
Set Softseek On
dbSetOrder(1)
dbSeek(xFilial("SI2")+cloteini,.T.)

SetRegua(RecCount())

While  !Eof()                        .and.; 
       I2_FILIAL  == xFilial("SI2")  .and.;
       I2_LOTE    >= cLoteIni        .and.;
       I2_LOTE    <= cLoteFim        .and.;
       I2_DATA    >= dDataDe         .and.;
       I2_DATA    <= dDataAte        .and.;
       IncRegua()

	#IFNDEF WINDOWS
		Inkey()
		If Lastkey() == K_ALT_A
			lEnd := .T.
		EndIf
	#ENDIF

	IF lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	EndIF

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Considera filtro do usuario                                  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If !Empty(cFilterUser).and.!(&cFilterUser)
		dbSkip()
		Loop
	Endif

	cLote := I2_LOTE
	cPer  := I2_PERIODO

	IF li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
		li := li - 1
	ElseIf lSaltPagi == 1                                                            // quebra por lote
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
		li := li - 1 
	EndIF

	dbSelectArea("SI1")
	dbSetOrder(1)
	If SI2->I2_DC == "D" 
	   dbSeek(xFilial("SI1")+SI2->I2_DEBITO)
	   @li, 00 PSAY Substr(SI2->I2_DEBITO,1,8)
	   @li, 10 PSAY SI1->I1_DESC
	   @li, 38 PSAY SI2->I2_LINHA
	   @li, 45 PSAY SI2->I2_HIST
	   @li, 86 PSAY SI2->I2_VALOR Picture tm ( SI2->I2_VALOR, 14 )
	   @li,118 PSAY SI2->I2_CCD
	   nTotTDeb := nTotTDeb + SI2->I2_VALOR
	ElseIf SI2->I2_DC == "C" 
	   dbSeek(xFilial("SI1")+SI2->I2_CREDITO)
	   @li, 00 PSAY Substr(SI2->I2_CREDITO,1,8)
	   @li, 10 PSAY SI1->I1_DESC
	   @li, 38 PSAY SI2->I2_LINHA
	   @li, 45 PSAY SI2->I2_HIST
	   @li,102 PSAY SI2->I2_VALOR Picture tm ( SI2->I2_VALOR, 14 )
	   @li,118 PSAY SI2->I2_CCD
	   nTotTCred := nTotTCred + SI2->I2_VALOR
	EndIf
	If SI2->I2_DC == "X"
	   dbSeek(xFilial("SI1")+SI2->I2_DEBITO)
	   @li, 00 PSAY Substr(SI2->I2_DEBITO,1,8)
	   @li, 10 PSAY SI1->I1_DESC
	   @li, 38 PSAY SI2->I2_LINHA
	   @li, 45 PSAY SI2->I2_HIST
	   @li, 86 PSAY SI2->I2_VALOR Picture tm ( SI2->I2_VALOR, 14 )
	   @li,118 PSAY SI2->I2_CCD
	   li := li + 1
	   dbSeek(xFilial("SI1")+SI2->I2_CREDITO)
	   @li, 00 PSAY Substr(SI2->I2_CREDITO,1,8)
	   @li, 10 PSAY SI1->I1_DESC
	   @li, 38 PSAY SI2->I2_LINHA
	   @li, 45 PSAY SI2->I2_HIST
	   @li,102 PSAY SI2->I2_VALOR Picture tm ( SI2->I2_VALOR, 14 )
	   @li,118 PSAY SI2->I2_CCD
	   nTotTDeb := nTotTDeb + SI2->I2_VALOR
	   nTotTCred:= nTotTCred+ SI2->I2_VALOR
	EndIf
	If SI2->I2_DC == "-"
	   @li, 45 PSAY SI2->I2_HIST
	EndIf
       li := li + 1
       dbSelectArea("SI2")
       dbSkip()

End
ImpTot120()
roda(cbcont,cbtxt,Tamanho)

#IFNDEF WINDOWS
	Set Device To Screen
#ENDIF
dbSetOrder(1)
If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH()

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿔mpTot120 � Autor � Erick Nori Barbosa    � Data � 01.06.92 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿔MPRIMIR TOTAL DO RELATORIO                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe e � ImpTot120()                                                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros�                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Conr120                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Function ImpTot120
Static Function ImpTot120()

li := li + 2

If ( li > 55 )
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
End

@li,060 PSAY "TOTAIS ->"
@li,086 PSAY nTotTDeb               Picture TM(nTotTDeb,14)
@li,102 PSAY nTotTCred              Picture TM(nTotTCred,14)
Return(.T.)
