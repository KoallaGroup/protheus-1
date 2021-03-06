#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

User Function SPDR002()

Private oReport
Private cTRAB := GetNextAlias()

//Define as Perguntas
Private cPerg     := "SPR002"
PutSx1(cPerg,"01",OemToAnsi("Informe Plano Ref."),OemToAnsi("Informe Plano Ref."),OemToAnsi("Informe Plano Ref."),"mv_ch1","C",03,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{ OemToAnsi("Informe o Plano Referencial"),OemToAnsi("a ser utilizado")}, {}, {} )
Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

Return


Static Function ReportDef()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎riacao do componente de impressao                                      �
//�                                                                        �
//쿟Report():New                                                           �
//쿐xpC1 : Nome do relatorio                                               �
//쿐xpC2 : Titulo                                                          �
//쿐xpC3 : Pergunte                                                        �
//쿐xpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//쿐xpC5 : Descricao                                                       �
//�                                                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oReport := TReport():New("SPDR002","Inconsist�ncia de Referencias SPED",cPerg, {|oReport| ReportPrint(oReport,cTRAB)},"Inconsist�ncia de Referencias SPED")
//oReport:SetPortrait() 
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎riacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//쿟RSection():New                                                         �
//쿐xpO1 : Objeto TReport que a secao pertence                             �
//쿐xpC2 : Descricao da se�ao                                              �
//쿐xpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se豫o.                   �
//쿐xpA4 : Array com as Ordens do relat�rio                                �
//쿐xpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//쿐xpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oCabec := TRSection():New(oReport,"",{"CT1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oCabec:SetLineStyle(.F.)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎riacao da celulas da secao do relatorio                                �
//�                                                                        �
//쿟RCell():New                                                            �
//쿐xpO1 : Objeto TSection que a secao pertence                            �
//쿐xpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//쿐xpC3 : Nome da tabela de referencia da celula                          �
//쿐xpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//쿐xpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//쿐xpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//쿐xpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//쿐xpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Secao 1 - Cabecalho do Pedido                                          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oConta := TRCell():New(oCabec,"CONTA"		,/*Tabela*/	,"Conta Contabil"	,"@!"	,TamSx3("CT1_CONTA")[1],.F.,{|| (cTRAB)->CT1_CONTA})
oDescr := TRCell():New(oCabec,"DESCRICAO"	,/*Tabela*/	,"Descri豫o"		,		,TamSx3("CT1_DESC01")[1],.F.,{||(cTRAB)->CT1_DESC01})
oCtaRef:= TRCell():New(oCabec,"REFERENCIA"	,/*Tabela*/	,"Conta Refer�ncia"	,"@!"	,TamSx3("CVN_CTAREF")[1],.F.,{||(cTRAB)->CVN_CTAREF})
oDscRef:= TRCell():New(oCabec,"DESCREF"		,/*Tabela*/	,"Descri豫o"		,		,TamSx3("CVN_DSCCTA")[1],.F.,{||(cTRAB)->CVN_DSCCTA})
oDtaVig:= TRCell():New(oCabec,"VIGENCIA"	,/*Tabela*/	,"Data Vig�ncia"	,"@!"	,TamSx3("CVN_DTVIGF")[1],.F.,{||(cTRAB)->CVN_DTVIGF})
oNtaCta:= TRCell():New(oCabec,"NATUREZA"	,/*Tabela*/	,"Natureza"			,"@!"	,TamSx3("CT1_NTSPED")[1],.F.,{||(cTRAB)->CT1_NTSPED})

Return(oReport)


Static Function ReportPrint(oReport,cAliasSC9,cAliasSC5,cAliasSF2,cALiasSB1,cAliasSA1,cAliasSC6)
*************************************************************************************************
*
***
Local lFirst := .T.
Local cQuery := ""

cQuery += " SELECT CT1_CONTA, CT1_DESC01, ISNULL(CVN_CTAREF,'N홒 INFORMADO') AS CVN_CTAREF, ISNULL(CVN_DSCCTA,'') AS CVN_DSCCTA,"
cQuery += " CONVERT(VARCHAR,CAST(ISNULL(CVN_DTVIGF,'') AS SMALLDATETIME),3)AS CVN_DTVIGF, "
cQuery += " CT1_NTSPED+(CASE CT1_NTSPED 
cQuery += "               WHEN '01' THEN '-CONTA DE ATIVO' "
cQuery += "               WHEN '02' THEN '-CONTA DE PASSIVO' "
cQuery += "               WHEN '03' THEN '-PATRIMONIO LIQUIDO' "
cQuery += "               WHEN '04' THEN '-CONTA DE RESULTADO' "
cQuery += "               WHEN '05' THEN '-CONTA DE COMPENSACAO' "
cQuery += "               WHEN '09' THEN '-OUTRAS'"
cQuery += "               ELSE 'INV핶IDO OU N홒 INFORMADO' END) AS CT1_NTSPED"
cQuery += " FROM "+RetSqlName("CT1")+" A LEFT JOIN "+RetSqlName("CVD")+" B ON B.D_E_L_E_T_='' AND CVD_CONTA=CT1_CONTA AND CVD_FILIAL=CT1_FILIAL AND CVD_CODPLA='"+MV_PAR01+"'"

cQuery += " LEFT JOIN "+RetSqlName("CVN")+" C ON C.D_E_L_E_T_='' AND CVD_CTAREF=CVN_CTAREF"
cQuery += " WHERE A.D_E_L_E_T_=''"
cQuery += " AND CT1_FILIAL='"+xFilial("CT1")+"'"
cQuery += " AND CT1_CLASSE='2'"
cQuery += " AND (CVN_CTAREF IS NULL OR ISNULL(CVN_DTVIGF,'')='20081231') AND CT1_NATCTA < '05'" 
cQuery += " ORDER BY CT1_CONTA"


dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTRAB,.F.,.T.)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿔nicio da impressao do fluxo do relat�rio                               �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oReport:SetTitle(oReport:Title())
oReport:SetMeter((cTRAB)->(LastRec()))
oReport:Section(1):Init()

While !oReport:Cancel() .And. !(cTRAB)->(Eof())

	If oReport:Row() > 2500 .or. lfirst
		oReport:EndPage(.T.)
		oReport:SkipLine(1)
	EndIf	
	lFirst := .F.

    oReport:Section(1):PrintLine()

	dbSelectArea(cTRAB)
	dbSkip()

	oReport:IncMeter()

EndDo
oReport:Section(1):Finish()

Return