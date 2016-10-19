#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

User Function SPDR001()

Private oReport
Private cTRAB := GetNextAlias()

//Define as Perguntas
Private cPerg     := "SPR001"

PutSx1(cPerg,"01",OemToAnsi("Informe ID Empresa"),OemToAnsi("Informe ID Empresa"),OemToAnsi("Informe ID Empresa"),"mv_ch1","C",06,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{ OemToAnsi("Informe o ID da Empresa")         ,OemToAnsi("conforme gerado na rotina SPED - Escritura��o")}, {}, {} )
PutSx1(cPerg,"02",OemToAnsi("Ordem do Livro    "),OemToAnsi("Ordem do Livro    "),OemToAnsi("Ordem do Livro    "),"mv_ch2","N",05,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",{ OemToAnsi("Informe o Num Ordem Livro")       ,OemToAnsi("conforme gerado na rotina SPED - Escritura��o")}, {}, {} )
PutSx1(cPerg,"03",OemToAnsi("Data Inicial      "),OemToAnsi("Data Inicial      "),OemToAnsi("Data Inicial      "),"mv_ch3","D",08,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",{ OemToAnsi("Define a Data Inicial do Per�odo"),OemToAnsi("para Consulta")}, {}, {} )
PutSx1(cPerg,"04",OemToAnsi("Data Final        "),OemToAnsi("Data Final        "),OemToAnsi("Data Final        "),"mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",{ OemToAnsi("Define a Data Final do Per�odo")  ,OemToAnsi("para Consulta")}, {}, {} )
PutSx1(cPerg,"05",OemToAnsi("Lote Lucros/Perdas"),OemToAnsi("Lote Lucros/Perdas"),OemToAnsi("Lote Lucros/Perdas"),"mv_ch5","C",06,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",{ OemToAnsi("Define o Lote Lucros/Perdas")  ,OemToAnsi("a ser ignorado no movimento")}, {}, {} )

Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

Return


Static Function ReportDef()

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("SPDR001","Balancete Verifica��o Receita","SPR001", {|oReport| ReportPrint(oReport,cTRAB)},"Balancete Verifica��o Receita")
//oReport:SetPortrait() 
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oCabec := TRSection():New(oReport,"",{"CT1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oCabec:SetLineStyle(.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//� Secao 1 - Cabecalho do Pedido                                          �
//��������������������������������������������������������������������������
/*
oConta := TRCell():New(oCabec,"CONTA"		,	,"Conta Refer�ncia"	,"@!",TamSx3("CVN_CTAREF")[1],.F.,{||(cTRAB)->CONTA})
oDescr := TRCell():New(oCabec,"DESCRICAO"	,	,"Descri��o"		,	,TamSx3("CVN_DSCCTA")[1],.F.,{|| (cTRAB)->DESCRICAO})
oInici := TRCell():New(oCabec,"INICIAL"		,	,"Saldo Inicial"	,	,TamSx3("CT7_DEBITO")[1],.F.,{|| (cTRAB)->INICIAL},"RIGHT",,"RIGHT")
oDebit := TRCell():New(oCabec,"DEBITO"		,	,"D�bito"			,	,TamSx3("CT7_DEBITO")[1],.F.,{|| (cTRAB)->DEBITO},"RIGHT",,"RIGHT")
oCredi := TRCell():New(oCabec,"CREDITO"		,	,"Cr�dito"			,	,TamSx3("CT7_CREDIT")[1],.F.,{|| (cTRAB)->CREDITO},"RIGHT",,"RIGHT")
oMovim := TRCell():New(oCabec,"MOVIMENTO"	,	,"Movimento"		,	,TamSx3("CT7_DEBITO")[1],.F.,{|| (cTRAB)->MOVIMENTO},"RIGHT",,"RIGHT")
oFinal := TRCell():New(oCabec,"FINAL"		,	,"Saldo Final"		,	,TamSx3("CT7_DEBITO")[1],.F.,{|| (cTRAB)->FINAL},"RIGHT",,"RIGHT")
*/

oConta := TRCell():New(oCabec,"CONTA"		,/*Tabela*/	,"Conta Refer�ncia"	,,   ,.T.,{|| (cTRAB)->CONTA})
oDescr := TRCell():New(oCabec,"DESCRICAO"	,/*Tabela*/	,"Descri��o"		,,080,.F.,{|| (cTRAB)->DESCRICAO})
oInici := TRCell():New(oCabec,"INICIAL"		,/*Tabela*/	,"Saldo Inicial"	,,020,.F.,{|| Transform(Abs((cTRAB)->INICIAL),"@E 999,999,999.99")+IIf((Left((cTRAB)->CONTA,1)='1' .And. (cTRAB)->INICIAL>=0) .Or. (Left((cTRAB)->CONTA,1)<>'1' .And. (cTRAB)->INICIAL<0),'D','C')},"RIGHT",,"RIGHT")
oDebit := TRCell():New(oCabec,"DEBITO"		,/*Tabela*/	,"D�bito"			,,020,.F.,{|| Transform((cTRAB)->DEBITO,"@E 999,999,999.99")},"RIGHT",,"RIGHT")
oCredi := TRCell():New(oCabec,"CREDITO"		,/*Tabela*/	,"Cr�dito"			,,020,.F.,{|| Transform((cTRAB)->CREDITO,"@E 999,999,999.99")},"RIGHT",,"RIGHT")
oMovim := TRCell():New(oCabec,"MOVIMENTO"	,/*Tabela*/	,"Movimento"		,,020,.F.,{|| Transform(Abs((cTRAB)->DEBITO-(cTRAB)->CREDITO),"@E 999,999,999.99")+IIf((cTRAB)->DEBITO>(cTRAB)->CREDITO,'D','C')},"RIGHT",,"RIGHT")
oFinal := TRCell():New(oCabec,"FINAL"		,/*Tabela*/	,"Saldo Final"		,,020,.F.,{|| Transform(Abs((cTRAB)->INICIAL+Iif(Left((cTRAB)->CONTA,1)='1',(cTRAB)->DEBITO-(cTRAB)->CREDITO,(cTRAB)->CREDITO-(cTRAB)->DEBITO)),"@E 999,999,999.99")},"RIGHT",,"RIGHT")


//Efetua Alinhamento dos Campos //1-Direita, 2-Centralizado, 3-Esquerda
oInici:SetAlign(3)
oDebit:SetAlign(3)
oCredi:SetAlign(3)
oMovim:SetAlign(3)
oFinal:SetAlign(3)

Return(oReport)


Static Function ReportPrint(oReport,cAliasSC9,cAliasSC5,cAliasSF2,cALiasSB1,cAliasSA1,cAliasSC6)

Local lFirst := .T.
Local cQuery := ""

cQuery += " SELECT CVN_CTAREF AS CONTA, CVN_DSCCTA AS DESCRICAO"
//cQuery += " , CVN_DTVIGF AS LIMITE"
//cQuery += " , CONVERT(VARCHAR, CAST(D.DTINI AS SMALLDATETIME),103) AS DTINI"
//cQuery += " , CONVERT(VARCHAR, CAST(D.DTFIM AS SMALLDATETIME),103) AS DTFIN,"
cQuery += " , SUM(CASE WHEN D.DTINI<>'"+DtoS(MV_PAR03)+"' THEN 0 ELSE (CASE WHEN (LEFT(CVN_CTAREF,1) IN ('2','3','5') AND D.DCINI='D') OR (LEFT(CVN_CTAREF,1) IN ('1') AND D.DCINI='C') THEN D.VLSLDINI*-1 ELSE D.VLSLDINI END)END) AS INICIAL"
cQuery += " , (SUM(D.VLDEB)-(SELECT ISNULL(SUM(E.VALOR),0) FROM SPED220A E INNER JOIN SPED120 F ON F.CODCTA=E.CODCTA WHERE E.D_E_L_E_T_='' AND SUBSTRING(NUMLCTO,11,6)='"+MV_PAR05+"' AND CVN_CTAREF=LEFT(F.COD_CTAREF,LEN(CVN_CTAREF)) AND E.DC='D')) AS DEBITO"
cQuery += " , (SUM(D.VLCRED)-(SELECT ISNULL(SUM(E.VALOR),0) FROM SPED220A E INNER JOIN SPED120 F ON F.CODCTA=E.CODCTA WHERE E.D_E_L_E_T_='' AND SUBSTRING(NUMLCTO,11,6)='"+MV_PAR05+"' AND CVN_CTAREF=LEFT(F.COD_CTAREF,LEN(CVN_CTAREF)) AND E.DC='C')) AS CREDITO"
//cQuery += " , SUM(CASE WHEN (LEFT(CVN_CTAREF,1) IN ('1')) THEN D.VLDEB-D.VLCRED ELSE D.VLCRED-D.VLDEB END) AS MOVIMENTO"
//cQuery += " , SUM(CASE WHEN D.DTFIM<>'"+DtoS(MV_PAR04)+"' THEN 0 ELSE (CASE WHEN (LEFT(CVN_CTAREF,1) IN ('2','3','5') AND D.DCFIN='D') OR (LEFT(CVN_CTAREF,1) IN ('1') AND D.DCFIN='C') THEN D.VLSLDFIN*-1 ELSE D.VLSLDFIN END)END) AS FINAL"
cQuery += " FROM "+RetSqlName("CVN")+" CVN "
cQuery += " INNER JOIN SPED120 A ON A.D_E_L_E_T_='' AND A.ID_ENT='"+MV_PAR01+"' AND CVN_CTAREF=LEFT(A.COD_CTAREF,LEN(CVN_CTAREF))"
cQuery += " INNER JOIN "+RetSqlName("CT1")+" C ON C.D_E_L_E_T_='' AND C.CT1_FILIAL='"+xFilial("CT1")+"' AND LEN(C.CT1_CONTA)=1 AND LEFT(C.CT1_CONTA,1)=LEFT(A.CODCTA,1)"
cQuery += " INNER JOIN SPED210 D ON D.D_E_L_E_T_='' AND D.ORDEM="+AllTrim(Str(MV_PAR02,0))+" AND A.ID_ENT=D.ID_ENT AND A.CODCTA=D.CODCTA "
cQuery += " WHERE CVN.D_E_L_E_T_=''"
cQuery += " AND (CVN_DTVIGF='' OR CVN_DTVIGF>=D.DTINI)" //FILTRA CONTAS REFERENCIAIS VENCIDAS
cQuery += " AND D.DTINI BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'"
cQuery += " AND D.DTFIM BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'"
//cQuery += " GROUP BY CVN_CTAREF, CVN_DSCCTA, D.DTINI, D.DTFIM, CVN_DTVIGF"
cQuery += " GROUP BY CVN_CTAREF, CVN_DSCCTA"
cQuery += " ORDER BY CVN_CTAREF"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTRAB,.F.,.T.)

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
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