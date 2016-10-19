#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function se2tosrd()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CSAVCUR1,CSAVROW1,CSAVCOL1,CSAVCOR1,CSAVSCR1,CSAVSCR2")
SetPrvt("ODLG,NOPCA,NLASTKEY,ACRA,ACA,CSAVCORM")
SetPrvt("NOMEPROG,NTOTREGS,LGERATIT,CARQUIVO,CLOTE,NTOTAL")
SetPrvt("LHEAD,LRODA,FILIALDE,FILIALATE,CCDE,CCATE")
SetPrvt("MATDE,MATATE,CNATUREZA,DDATADE,DDATAATE,CINICIO")
SetPrvt("CFIM,CINDEX,NSEQ,")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � SE2TOSRD � Autor � Marcos Machado        � Data � 20.11.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � TRAZ CONTAS A PAGAR PARA DIRF DE AUTONOMOS                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Chamada padr�o para programas em RDMake.                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RdMake                                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

IF !(SX1->(dbSeek("DIRFAU01",.F.)))
   GravaPerg()
EndIF

//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais do Programa                          �
//����������������������������������������������������������������
#IFNDEF WINDOWS
	cSavCur1:=""
	cSavRow1:=""
	cSavCol1:=""
	cSavCor1:=""
	cSavScr1:=""
	cSavScr2:=""
#ELSE
	oDlg:=""
#ENDIF

nOpca := 0
nLastKey  := 0

#IFDEF WINDOWS

	Pergunte("DIRFAU",.T.)

    #IFNDEF WINDOWS
		Inkey()
	   ALERT("CANCELADO PELO OPERADOR")
		If Lastkey() == 286
			Return  
		EndIf   
		If Lastkey() == 27
			Return  
		EndIf   
    #ENDIF

	LCTOProcessa()

#ELSE

	aCRA:= { "Confirma","Redigita","Abandona" }
	aCA := { "Continua","Abandona"}
	cSavCorM        := SetColor()

	//��������������������������������������������������������������Ŀ
	//� Salva a Integridade dos dados de Entrada                                     �
	//����������������������������������������������������������������
	cSavScr1 := SaveScreen(3,0,24,79)
	cSavCur1 := SetCursor(0)
	cSavRow1 := ROW()
	cSavCol1 := COL()
	cSavCor1 := SetColor("bg+/b,,,")

	DispBegin()
	ScreenDraw("SMT250", 3, 0, 0, 0)
	@ 03,01 Say "TRAZ CONTAS A PAGAR DE AUTONOMOS PARA DIRF" Color "b/w"
	SetColor("n/w,,,")
	@ 17,05 SAY Space(71)
	DispEnd()

	//��������������������������������������������������������������Ŀ
	//� Descricao generica do programa                                                               �
	//����������������������������������������������������������������
	SetColor("b/bg")
	@ 10,05 Say "TRAZ CONTAS A PAGAR DE AUTONOMOS PARA DIRF"
	Inkey(0)

	While .T.
		//��������������������������������������������������������������Ŀ
		//� Carrega as Perguntas selecionadas                                                    �
		//����������������������������������������������������������������
		PERGUNTE("DIRFAU",.T.)

		DispBegin()
		ScreenDraw("SMT250", 3, 0, 0, 0)
		@ 03,01 Say "TRAZ CONTAS A PAGAR DE AUTONOMOS PARA DIRF" Color "b/w"
		SetColor("n/w,,,")
		@ 17,05 SAY Space(71)
		DispEnd()

		//��������������������������������������������������������������Ŀ
		//� Descricao generica do programa                                                               �
		//����������������������������������������������������������������
		SetColor("b/bg")
		@ 10,05 Say "TRAZ CONTAS A PAGAR DE AUTONOMOS PARA DIRF"
		nOpcA:=menuh(aCRA,17,6,"b/w,w+/n,r/w","CRA","",1)
		If nOpcA == 2
			Loop
		Endif
		Exit
	EndDo
	If nOpca == 1
		LCTOProcessa()
	Endif
	RestScreen(3,0,24,79,cSavScr1)
	SetCursor(cSavCur1)
	DevPos(cSavRow1,cSavCol1)
	SetColor(cSavCor1)
#ENDIF



// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Function LCTOProcessa
Static Function LCTOProcessa()

nomeprog  := 'SE2TOSRD'

If nLastKey == 27
	ALERT("CANCELADO PELO OPERADOR")
	Return Nil
Endif

nTotregs := 0 //-- Regua.
lGeraTit := .F.
cArquivo :=""
cLote    :=Space(4)
nTotal   :=0
lHead           := .T.
lRoda           := .F.


//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
//������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                             �
//� mv_par01   a    //  Filial De                                    �
//� mv_par02   b    //  Filial Ate                                   �
//� mv_par03   c    //  Centro de Custo De                           �
//� mv_par04   d    //  Centro de Custo Ate                          �
//� mv_par05   e    //  Matricula De                                 �
//� mv_par06   f    //  Matricula Ate                                �
//� mv_par07   g    //  Natureza                                     �
//� mv_par08   h    //  Data Competencia De                          �
//� mv_par09   i    //  Data Competencia Ate                         �
//��������������������������������������������������������������������

FilialDe  := mv_par01
FilialAte := mv_par02
CcDe      := mv_par03
CcAte     := mv_par04
MatDe     := mv_par05
MatAte    := mv_par06
cNatureza := mv_par07
dDataDe   := mv_par08
dDataAte  := mv_par09

//��������������������������������������������������������������Ŀ
//� Selecionando a Ordem de impressao escolhida no parametro.    �
//����������������������������������������������������������������
dbSelectArea('SRA')
dbSetOrder(1)
dbSeek(FilialDe + MatDe,.T.)
cInicio := 'SRA->RA_FILIAL + SRA->RA_MAT'
cFim    := FilialAte + MatAte

//��������������������������������������������������������������Ŀ
//� Carrega Regua Processamento                                  �
//����������������������������������������������������������������
SetRegua(RecCount()) //-- Total de elementos da regua.

dbSelectArea("SE2")
cIndex:= CriaTrab(NIL,.F.)
INDEX ON E2_FORNECE+E2_LOJA+DToS(E2_EMIS1)+E2_PREFIXO+E2_NUM TO &CINDEX

dbGoTop()


dbSelectArea('SRA')
While !EOF() .And. &cInicio <= cFim
	
	//��������������������������������������������������������������Ŀ
	//� Movimenta Regua Processamento                                �
	//����������������������������������������������������������������
	IncRegua()  //-- Move a regua.

	//��������������������������������������������������������������Ŀ
	//� Cancela Processo ao se pressionar <ALT> + <A>                �
	//����������������������������������������������������������������

    #IFNDEF WINDOWS
		Inkey()
		If Lastkey() == 286
			Return  
		EndIf   
		If Lastkey() == 27
			Return  
		EndIf   
    #ENDIF

    SetRegua(RecCount())

	//��������������������������������������������������������������Ŀ
	//� Consiste Parametrizacao do Intervalo de Impressao            �
	//����������������������������������������������������������������
    If (SRA->RA_FILIAL < FILIALDE)    .Or. (SRA->RA_FILIAL > FILIALATE)    .Or. ;
	(SRA->RA_MAT < MatDe)     .Or. (SRA->RA_MAT > MatAte)     .Or. ;
	(SRA->RA_CC < CcDe)       .Or. (SRA->RA_CC > CcAte)
		SRA->(dbSkip(1))
		Loop
    EndIf
	
	
    nSEQ      := 1
    
    set softseek on
    dbSelectArea('SE2')
    dbSeek(SRA->RA_MAT+"01"+DTOS(dDataDe)+"         ")
    set softseek off
    
    While !EOF() .And. SE2->E2_FORNECE == SRA->RA_MAT .AND. DTOS(dDataAte) > DTOS(SE2->E2_EMIS1)

       If cNATUREZA <> "999999999"   
	  IF SE2->E2_NATUREZ <> cNatureza  
	     SE2->(dbSkip(1))
	     Loop
	  ENDIF
       EndIf
    
       dbSelectArea( "SRD" )
       dbSetOrder(1)
       dbSeek(XFilial("SRD")+SRA->RA_MAT+IIF(SE2->E2_EMIS1 > CTOD("30/04/00"),("20"+SUBS(DTOC(SE2->E2_EMIS1),7,2)+SUBS(DTOC(SE2->E2_EMIS1),4,2)),("20"+SUBS(DTOC(SE2->E2_VENCREA),7,2)+SUBS(DTOC(SE2->E2_VENCREA),4,2)))+"310  1")
       
       IF FOUND()
	  nSEQ := nSEQ + 1
       ELSE
	  nSEQ := 1
       ENDIF
       IF (SE2->E2_VALOR + SE2->E2_IRRF) > 0
	  dbSelectArea( "SRD" )
	  Reclock("SRD",.T.)

	  SRD->RD_FILIAL      := SRA->RA_FILIAL
	  SRD->RD_MAT         := SE2->E2_FORNECE
	  SRD->RD_PD          := "310" 
	  SRD->RD_DATARQ      := IIF(SE2->E2_EMIS1 > CTOD("30/04/00"),("20"+SUBS(DTOC(SE2->E2_EMIS1),7,2)+SUBS(DTOC(SE2->E2_EMIS1),4,2)),("20"+SUBS(DTOC(SE2->E2_VENCREA),7,2)+SUBS(DTOC(SE2->E2_VENCREA),4,2)))
	  SRD->RD_DATPGT      := IIF(SE2->E2_EMIS1 > CTOD("30/04/00"),SE2->E2_EMIS1,SE2->E2_VENCREA) 
	  SRD->RD_MES         := IIF(SE2->E2_EMIS1 > CTOD("30/04/00"),SUBS(DTOC(SE2->E2_EMIS1),4,2),SUBS(DTOC(SE2->E2_VENCREA),4,2)) 
	  SRD->RD_TIPO1       := "V"
	  SRD->RD_TIPO2       := "I"
	  SRD->RD_HORAS       := 0
	  SRD->RD_VALOR       := SE2->E2_VALOR + SE2->E2_IRRF
	  SRD->RD_STATUS      := "M"  
	  SRD->RD_SEQ         := STR(nSEQ,1,0)
       
	  SRD->(  dbUnlock() )

	  dbSelectArea( "SRD" )
	  Reclock("SRD",.T.)

	  SRD->RD_FILIAL      := SRA->RA_FILIAL
	  SRD->RD_MAT         := SE2->E2_FORNECE
	  SRD->RD_PD          := "711" 
	  SRD->RD_DATARQ      := IIF(SE2->E2_EMIS1 > CTOD("30/04/00"),("20"+SUBS(DTOC(SE2->E2_EMIS1),7,2)+SUBS(DTOC(SE2->E2_EMIS1),4,2)),("20"+SUBS(DTOC(SE2->E2_VENCREA),7,2)+SUBS(DTOC(SE2->E2_VENCREA),4,2)))
	  SRD->RD_DATPGT      := IIF(SE2->E2_EMIS1 > CTOD("30/04/00"),SE2->E2_EMIS1,SE2->E2_VENCREA) 
	  SRD->RD_MES         := IIF(SE2->E2_EMIS1 > CTOD("30/04/00"),SUBS(DTOC(SE2->E2_EMIS1),4,2),SUBS(DTOC(SE2->E2_VENCREA),4,2)) 
	  SRD->RD_TIPO1       := "V"
	  SRD->RD_TIPO2       := "I"
	  SRD->RD_HORAS       := 0
	  SRD->RD_VALOR       := SE2->E2_VALOR + SE2->E2_IRRF
	  SRD->RD_STATUS      := "M"  
	  SRD->RD_SEQ         := STR(nSEQ,1,0)
       
	  SRD->(  dbUnlock() )
       ENDIF
       
       IF SE2->E2_IRRF > 0
	  dbSelectArea( "SRD" )
	  Reclock("SRD",.T.)

	  SRD->RD_FILIAL      := SRA->RA_FILIAL
	  SRD->RD_MAT         := SE2->E2_FORNECE
	  SRD->RD_PD          := "405" 
	  SRD->RD_DATARQ      := IIF(SE2->E2_EMIS1 > CTOD("30/04/00"),("20"+SUBS(DTOC(SE2->E2_EMIS1),7,2)+SUBS(DTOC(SE2->E2_EMIS1),4,2)),("20"+SUBS(DTOC(SE2->E2_VENCREA),7,2)+SUBS(DTOC(SE2->E2_VENCREA),4,2)))
	  SRD->RD_DATPGT      := IIF(SE2->E2_EMIS1 > CTOD("30/04/00"),SE2->E2_EMIS1,SE2->E2_VENCREA) 
	  SRD->RD_MES         := IIF(SE2->E2_EMIS1 > CTOD("30/04/00"),SUBS(DTOC(SE2->E2_EMIS1),4,2),SUBS(DTOC(SE2->E2_VENCREA),4,2)) 
	  SRD->RD_TIPO1       := "V"
	  SRD->RD_TIPO2       := "I"
	  SRD->RD_HORAS       := 0
	  SRD->RD_VALOR       := SE2->E2_IRRF
	  SRD->RD_STATUS      := "M"  
	  SRD->RD_SEQ         := STR(nSEQ,1,0)
       
	  SRD->(  dbUnlock() )
       ENDIF

       dbSelectArea('SE2')
       dbSkip()
    Enddo 
	   
    dbSelectArea('SRA')
    dbSkip() 
Enddo 
	
Return 


*
*�����������������������������������������������������������������������������Ŀ
*�Grava as Perguntas utilizadas no Programa no SX1                             �
*�������������������������������������������������������������������������������*/
// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Function GravaPerg
Static Function GravaPerg()

dbSelectArea( "SX1" )
dbSetOrder( 1 )

SX1->( dbAppend() )
SX1->( rLock() )
SX1->X1_GRUPO   := "DIRFAU"
SX1->X1_ORDEM   := "01"
SX1->X1_PERGUNT := "Filial De     "
SX1->X1_VARIAVL := "mv_cha"
SX1->X1_TIPO    := "C"
SX1->X1_TAMANHO := 2
SX1->X1_DECIMAL := 0
SX1->X1_PRESEL  := 0
SX1->X1_GSC     := "G"
SX1->X1_VALID   := ""
SX1->X1_VAR01   := "mv_par01"
SX1->X1_DEF01   := ""
SX1->X1_CNT01   := ""
SX1->X1_VAR02   := ""
SX1->X1_DEF02   := ""
SX1->X1_CNT02   := ""
SX1->X1_VAR03   := ""
SX1->X1_DEF03   := ""
SX1->X1_CNT03   := ""
SX1->X1_VAR04   := ""
SX1->X1_DEF04   := ""
SX1->X1_CNT04   := ""
SX1->X1_VAR05   := ""
SX1->X1_DEF05   := ""
SX1->X1_CNT05   := ""
SX1->X1_F3      := ""
SX1->(  dbUnlock() )
SX1->( dbAppend() )
SX1->( rLock() )

SX1->X1_GRUPO   := "DIRFAU"
SX1->X1_ORDEM   := "02"
SX1->X1_PERGUNT := "Filial Ate    "
SX1->X1_VARIAVL := "mv_chb"
SX1->X1_TIPO    := "C"
SX1->X1_TAMANHO := 2
SX1->X1_DECIMAL := 0
SX1->X1_PRESEL  := 0
SX1->X1_GSC     := "G"
SX1->X1_VALID   := ""
SX1->X1_VAR01   := "mv_par02"
SX1->X1_DEF01   := ""
SX1->X1_CNT01   := ""
SX1->X1_VAR02   := ""
SX1->X1_DEF02   := ""
SX1->X1_CNT02   := ""
SX1->X1_VAR03   := ""
SX1->X1_DEF03   := ""
SX1->X1_CNT03   := ""
SX1->X1_VAR04   := ""
SX1->X1_DEF04   := ""
SX1->X1_CNT04   := ""
SX1->X1_VAR05   := ""
SX1->X1_DEF05   := ""
SX1->X1_CNT05   := ""
SX1->X1_F3      := ""
SX1->(  dbUnlock() )

SX1->( dbAppend() )
SX1->( rLock() )
SX1->X1_GRUPO   := "DIRFAU"
SX1->X1_ORDEM   := "03"
SX1->X1_PERGUNT := "C. de Custo De"
SX1->X1_VARIAVL := "mv_chc"
SX1->X1_TIPO    := "C"
SX1->X1_TAMANHO := 9
SX1->X1_DECIMAL := 0
SX1->X1_PRESEL  := 0
SX1->X1_GSC     := "G"
SX1->X1_VALID   := ""
SX1->X1_VAR01   := "mv_par03"
SX1->X1_DEF01   := ""
SX1->X1_CNT01   := ""
SX1->X1_VAR02   := ""
SX1->X1_DEF02   := ""
SX1->X1_CNT02   := ""
SX1->X1_VAR03   := ""
SX1->X1_DEF03   := ""
SX1->X1_CNT03   := ""
SX1->X1_VAR04   := ""
SX1->X1_DEF04   := ""
SX1->X1_CNT04   := ""
SX1->X1_VAR05   := ""
SX1->X1_DEF05   := ""
SX1->X1_CNT05   := ""
SX1->X1_F3      := "SI3"
SX1->(  dbUnlock() )

SX1->( dbAppend() )
SX1->( rLock() )
SX1->X1_GRUPO   := "DIRFAU"
SX1->X1_ORDEM   := "04"
SX1->X1_PERGUNT := "C. de Custo Ate" 
SX1->X1_VARIAVL := "mv_chd"
SX1->X1_TIPO    := "C"
SX1->X1_TAMANHO := 9
SX1->X1_DECIMAL := 0
SX1->X1_PRESEL  := 0
SX1->X1_GSC     := "G"
SX1->X1_VALID   := ""
SX1->X1_VAR01   := "mv_par04"
SX1->X1_DEF01   := ""
SX1->X1_CNT01   := ""
SX1->X1_VAR02   := ""
SX1->X1_DEF02   := ""
SX1->X1_CNT02   := ""
SX1->X1_VAR03   := ""
SX1->X1_DEF03   := ""
SX1->X1_CNT03   := ""
SX1->X1_VAR04   := ""
SX1->X1_DEF04   := ""
SX1->X1_CNT04   := ""
SX1->X1_VAR05   := ""
SX1->X1_DEF05   := ""
SX1->X1_CNT05   := ""
SX1->X1_F3      := "SI3"
SX1->(  dbUnlock() )

SX1->( dbAppend() )
SX1->( rLock() )
SX1->X1_GRUPO   := "DIRFAU"
SX1->X1_ORDEM   := "05"
SX1->X1_PERGUNT := "Maricula De   "
SX1->X1_VARIAVL := "mv_che"
SX1->X1_TIPO    := "C"
SX1->X1_TAMANHO := 6
SX1->X1_DECIMAL := 0
SX1->X1_PRESEL  := 0
SX1->X1_GSC     := "G"
SX1->X1_VALID   := ""
SX1->X1_VAR01   := "mv_par05"
SX1->X1_DEF01   := ""
SX1->X1_CNT01   := ""
SX1->X1_VAR02   := ""
SX1->X1_DEF02   := ""
SX1->X1_CNT02   := ""
SX1->X1_VAR03   := ""
SX1->X1_DEF03   := ""
SX1->X1_CNT03   := ""
SX1->X1_VAR04   := ""
SX1->X1_DEF04   := ""
SX1->X1_CNT04   := ""
SX1->X1_VAR05   := ""
SX1->X1_DEF05   := ""
SX1->X1_CNT05   := ""
SX1->X1_F3      := "SRA"
SX1->(  dbUnlock() )

SX1->( dbAppend() )
SX1->( rLock() )
SX1->X1_GRUPO   := "DIRFAU"
SX1->X1_ORDEM   := "06"
SX1->X1_PERGUNT := "Matricula Ate "
SX1->X1_VARIAVL := "mv_chf"
SX1->X1_TIPO    := "C"
SX1->X1_TAMANHO := 6
SX1->X1_DECIMAL := 0
SX1->X1_PRESEL  := 0
SX1->X1_GSC     := "G"
SX1->X1_VALID   := ""
SX1->X1_VAR01   := "mv_par06"
SX1->X1_DEF01   := ""
SX1->X1_CNT01   := ""
SX1->X1_VAR02   := ""
SX1->X1_DEF02   := ""
SX1->X1_CNT02   := ""
SX1->X1_VAR03   := ""
SX1->X1_DEF03   := ""
SX1->X1_CNT03   := ""
SX1->X1_VAR04   := ""
SX1->X1_DEF04   := ""
SX1->X1_CNT04   := ""
SX1->X1_VAR05   := ""
SX1->X1_DEF05   := ""
SX1->X1_CNT05   := ""
SX1->X1_F3      := "SRA"
SX1->(  dbUnlock() )

SX1->( dbAppend() )
SX1->( rLock() )
SX1->X1_GRUPO   := "DIRFAU"
SX1->X1_ORDEM   := "07"
SX1->X1_PERGUNT := "Natureza      "
SX1->X1_VARIAVL := "mv_chg"
SX1->X1_TIPO    := "C"
SX1->X1_TAMANHO := 9
SX1->X1_DECIMAL := 0
SX1->X1_PRESEL  := 0
SX1->X1_GSC     := "G"
SX1->X1_VALID   := ""
SX1->X1_VAR01   := "mv_par07"
SX1->X1_DEF01   := ""
SX1->X1_CNT01   := ""
SX1->X1_VAR02   := ""
SX1->X1_DEF02   := ""
SX1->X1_CNT02   := ""
SX1->X1_VAR03   := ""
SX1->X1_DEF03   := ""
SX1->X1_CNT03   := ""
SX1->X1_VAR04   := ""
SX1->X1_DEF04   := ""
SX1->X1_CNT04   := ""
SX1->X1_VAR05   := ""
SX1->X1_DEF05   := ""
SX1->X1_CNT05   := ""
SX1->X1_F3      := "SED"
SX1->(  dbUnlock() )

SX1->( dbAppend() )
SX1->( rLock() )
SX1->X1_GRUPO   := "DIRFAU"
SX1->X1_ORDEM   := "08"
SX1->X1_PERGUNT := "Data De     "
SX1->X1_VARIAVL := "mv_chh"
SX1->X1_TIPO    := "D"
SX1->X1_TAMANHO := 8
SX1->X1_DECIMAL := 0
SX1->X1_PRESEL  := 0
SX1->X1_GSC     := "G"
SX1->X1_VALID   := ""
SX1->X1_VAR01   := "mv_par08"
SX1->X1_DEF01   := ""
SX1->X1_CNT01   := ""
SX1->X1_VAR02   := ""
SX1->X1_DEF02   := ""
SX1->X1_CNT02   := ""
SX1->X1_VAR03   := ""
SX1->X1_DEF03   := ""
SX1->X1_CNT03   := ""
SX1->X1_VAR04   := ""
SX1->X1_DEF04   := ""
SX1->X1_CNT04   := ""
SX1->X1_VAR05   := ""
SX1->X1_DEF05   := ""
SX1->X1_CNT05   := ""
SX1->X1_F3      := ""
SX1->(  dbUnlock() )

SX1->( dbAppend() )
SX1->( rLock() )
SX1->X1_GRUPO   := "DIRFAU"
SX1->X1_ORDEM   := "09"
SX1->X1_PERGUNT := "Data Ate      "
SX1->X1_VARIAVL := "mv_chi"
SX1->X1_TIPO    := "D"
SX1->X1_TAMANHO := 8
SX1->X1_DECIMAL := 0
SX1->X1_PRESEL  := 0
SX1->X1_GSC     := "G"
SX1->X1_VALID   := ""
SX1->X1_VAR01   := "mv_par09"
SX1->X1_DEF01   := ""
SX1->X1_CNT01   := ""
SX1->X1_VAR02   := ""
SX1->X1_DEF02   := ""
SX1->X1_CNT02   := ""
SX1->X1_VAR03   := ""
SX1->X1_DEF03   := ""
SX1->X1_CNT03   := ""
SX1->X1_VAR04   := ""
SX1->X1_DEF04   := ""
SX1->X1_CNT04   := ""
SX1->X1_VAR05   := ""
SX1->X1_DEF05   := ""
SX1->X1_CNT05   := ""
SX1->X1_F3      := ""
SX1->(  dbUnlock() )
// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> __Return( .T. )
Return( .T. )        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01
