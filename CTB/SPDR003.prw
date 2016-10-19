#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
+----------+----------+-------------+------------------------------+-----+-----------+
| Programa | SPDR003  | Programador | Alcides Andrade - NM         |Data | 26/02/2011|
+----------+----------+-------------+------------------------------+-----+-----------+
| Rotina   | Relat�rio de Balancete em Reais no formato das contas da Receita Federal|
|          | conforme SPED - NOVO ECD.                                               |
+----------+-------------------------------------------------------------------------+
|                           Modificacoes desde a construcao Inicial                  |
+---------------+--------------+-----------------------------------------------------+
| Programador   | Data         | Motivo                                              |
+---------------+--------------+-----------------------------------------------------+
|               |              |                                                     |
+---------------+--------------+-----------------------------------------------------+
*/

User Function SPDR003()

Private oReport
Private cTRAB := GetNextAlias()

//Define as Perguntas
Private cPerg     := "SPR003"

PutSx1(cPerg,"01",OemToAnsi("Informe Revisao   "),OemToAnsi("Informe Revisao   "),OemToAnsi("Informe Revisao   "),"mv_ch1","C",06,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{ OemToAnsi("Informe o c�digo da Revis�o")       ,OemToAnsi("conforme gerado na rotina SPED - Escritura��o")}, {}, {} )
PutSx1(cPerg,"02",OemToAnsi("Data Inicial      "),OemToAnsi("Data Inicial      "),OemToAnsi("Data Inicial      "),"mv_ch3","D",08,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",{ OemToAnsi("Define a Data Inicial do Per�odo")  ,OemToAnsi("para Consulta")}, {}, {} )
PutSx1(cPerg,"03",OemToAnsi("Data Final        "),OemToAnsi("Data Final        "),OemToAnsi("Data Final        "),"mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",{ OemToAnsi("Define a Data Final do Per�odo")    ,OemToAnsi("para Consulta")}, {}, {} )
PutSx1(cPerg,"04",OemToAnsi("Lote/SBLote LP    "),OemToAnsi("Lote/SBLote LP    "),OemToAnsi("Lote/SBLote LP    "),"mv_ch5","C",30,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",{ OemToAnsi("Define o Lote/SBLote Lucros/Perdas"),OemToAnsi("a ser ignorado no movimento")}, {}, {} )

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
oReport := TReport():New("SPDR003","Balancete Verifica��o Receita","SPR003", {|oReport| ReportPrint(oReport,cTRAB)},"Balancete Verifica��o Receita")
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
oConta := TRCell():New(oCabec,"CONTA"		,/*Tabela*/	,"Conta Refer�ncia"	,,040,.F.,{|| (cTRAB)->CONTA})
oDescr := TRCell():New(oCabec,"DESCRICAO"	,/*Tabela*/	,"Descri��o"		,,080,.F.,{|| (cTRAB)->DESCRICAO})
oInici := TRCell():New(oCabec,"INICIAL"		,/*Tabela*/	,"Saldo Inicial"	,,030,.F.,{|| Transform(Abs((cTRAB)->INICIAL),"@E 999,999,999.99")+IIf((Left((cTRAB)->CONTA,1)='1' .And. (cTRAB)->INICIAL>=0) .Or. (Left((cTRAB)->CONTA,1)<>'1' .And. (cTRAB)->INICIAL<0),'D','C')},,,)
oDebit := TRCell():New(oCabec,"DEBITO"		,/*Tabela*/	,"D�bito"			,,030,.F.,{|| Transform((cTRAB)->DEBITO,"@E 999,999,999.99")},,,)
oCredi := TRCell():New(oCabec,"CREDITO"		,/*Tabela*/	,"Cr�dito"			,,030,.F.,{|| Transform((cTRAB)->CREDITO,"@E 999,999,999.99")},,,)
oMovim := TRCell():New(oCabec,"MOVIMENTO"	,/*Tabela*/	,"Movimento"		,,030,.F.,{|| Transform(Abs((cTRAB)->DEBITO-(cTRAB)->CREDITO),"@E 999,999,999.99")+IIf((cTRAB)->DEBITO>(cTRAB)->CREDITO,'D','C')},,,)
oFinal := TRCell():New(oCabec,"FINAL"		,/*Tabela*/	,"Saldo Final"		,,030,.F.,{|| Transform(Abs((cTRAB)->INICIAL+Iif(Left((cTRAB)->CONTA,1)='1',(cTRAB)->DEBITO-(cTRAB)->CREDITO,(cTRAB)->CREDITO-(cTRAB)->DEBITO)),"@E 999,999,999.99")},,,)


//Efetua Alinhamento dos Campos //1-Direita, 2-Centralizado, 3-Esquerda
oInici:SetAlign(1)
oDebit:SetAlign(1)
oCredi:SetAlign(1)
oMovim:SetAlign(1)
oFinal:SetAlign(1)

Return(oReport)


Static Function ReportPrint(oReport,cAliasSC9,cAliasSC5,cAliasSF2,cALiasSB1,cAliasSA1,cAliasSC6)

Local lFirst := .T.
Local cQuery := ""

cQuery := "if exists (select * from sysobjects where type = 'U' and name = 'NM_BALSPED') drop table NM_BALSPED"
TcSqlExec(cQuery)

cQuery += " SELECT CVN_CTAREF AS CONTA, CVN_DSCCTA AS DESCRICAO"
cQuery += " , SUM(CASE CSC_DTINI WHEN '"+DtoS(MV_PAR02)+"' THEN CASE WHEN (LEFT(CVN_CTAREF,1) IN ('2','3','5') AND D.CSC_INDINI='D') OR (LEFT(CVN_CTAREF,1) IN ('1') AND D.CSC_INDINI='C') THEN D.CSC_VALINI*-1 ELSE D.CSC_VALINI END ELSE 0 END) AS INICIAL"
cQuery += " , (SUM(CSC_VALDEB)-(SELECT ISNULL(SUM(E.CSB_VLPART),0) FROM "+RetSqlname("CSB")+" E WHERE E.D_E_L_E_T_='' AND E.CSB_DTLANC BETWEEN '"+DtoS(MV_PAR02)+"' AND '"+DtoS(MV_PAR03)+"' AND SUBSTRING(E.CSB_NUMLOT,11,9) IN ('"+AllTrim(MV_PAR04)+"') AND E.CSB_INDDC='D' AND E.CSB_CODREV=D.CSC_CODREV AND E.CSB_CODCTA=D.CSC_CONTA)) AS DEBITO"
cQuery += " , (SUM(CSC_VALCRE)-(SELECT ISNULL(SUM(E.CSB_VLPART),0) FROM "+RetSqlname("CSB")+" E WHERE E.D_E_L_E_T_='' AND E.CSB_DTLANC BETWEEN '"+DtoS(MV_PAR02)+"' AND '"+DtoS(MV_PAR03)+"' AND SUBSTRING(E.CSB_NUMLOT,11,9) IN ('"+AllTrim(MV_PAR04)+"') AND E.CSB_INDDC='C' AND E.CSB_CODREV=D.CSC_CODREV AND E.CSB_CODCTA=D.CSC_CONTA)) AS CREDITO"
cQuery += " INTO NM_BALSPED" //cria a tabela para Balancete do SPED
cQuery += " FROM "+RetSqlName("CVN")+" CVN "
cQuery += " INNER JOIN "+RetSqlName("CS4")+" A ON A.D_E_L_E_T_<>'*' AND A.CS4_CODREV='"+MV_PAR01+"' AND CVN_CTAREF=LEFT(A.CS4_CTAREF,LEN(CVN_CTAREF))"
cQuery += " INNER JOIN "+RetSqlName("CT1")+" C ON C.D_E_L_E_T_<>'*' AND C.CT1_FILIAL='"+xFilial("CT1")+"' AND LEN(C.CT1_CONTA)=1 AND LEFT(C.CT1_CONTA,1)=LEFT(A.CS4_CONTA,1)"
cQuery += " INNER JOIN "+RetSqlName("CSC")+" D ON D.D_E_L_E_T_<>'*' AND A.CS4_CODREV=D.CSC_CODREV AND A.CS4_CONTA=D.CSC_CONTA AND A.CS4_CCUSTO='' AND LEFT(CS4_CONTA,1) NOT IN ('3','4')"
cQuery += " WHERE CVN.D_E_L_E_T_<>'*'"
cQuery += " AND (CVN_DTVIGF='' OR CVN_DTVIGF>=D.CSC_DTINI)"
cQuery += " AND D.CSC_DTINI BETWEEN '"+DtoS(MV_PAR02)+"' AND '"+DtoS(MV_PAR03)+"'"
cQuery += " AND D.CSC_DTFIM BETWEEN '"+DtoS(MV_PAR02)+"' AND '"+DtoS(MV_PAR03)+"'"
cQuery += " GROUP BY CVN_CTAREF, CVN_DSCCTA, CSC_CODREV, CSC_CONTA"


cQuery += " UNION ALL"

cQuery += " SELECT CVN_CTAREF AS CONTA, CVN_DSCCTA AS DESCRICAO"
cQuery += " , SUM(CASE CSC_DTINI WHEN '"+DtoS(MV_PAR02)+"' THEN CASE WHEN (LEFT(CVN_CTAREF,1) IN ('2','3','5') AND D.CSC_INDINI='D') OR (LEFT(CVN_CTAREF,1) IN ('1') AND D.CSC_INDINI='C') THEN D.CSC_VALINI*-1 ELSE D.CSC_VALINI END ELSE 0 END) AS INICIAL"
cQuery += " , (SUM(CSC_VALDEB)-(SELECT ISNULL(SUM(E.CSB_VLPART),0) FROM "+RetSqlname("CSB")+" E WHERE E.D_E_L_E_T_='' AND E.CSB_DTLANC BETWEEN '"+DtoS(MV_PAR02)+"' AND '"+DtoS(MV_PAR03)+"' AND SUBSTRING(E.CSB_NUMLOT,11,9) IN ('"+AllTrim(MV_PAR04)+"') AND E.CSB_INDDC='D' AND E.CSB_CODREV=D.CSC_CODREV AND E.CSB_CODCTA=D.CSC_CONTA AND E.CSB_CCUSTO=D.CSC_CCUSTO)) AS DEBITO"
cQuery += " , (SUM(CSC_VALCRE)-(SELECT ISNULL(SUM(E.CSB_VLPART),0) FROM "+RetSqlname("CSB")+" E WHERE E.D_E_L_E_T_='' AND E.CSB_DTLANC BETWEEN '"+DtoS(MV_PAR02)+"' AND '"+DtoS(MV_PAR03)+"' AND SUBSTRING(E.CSB_NUMLOT,11,9) IN ('"+AllTrim(MV_PAR04)+"') AND E.CSB_INDDC='C' AND E.CSB_CODREV=D.CSC_CODREV AND E.CSB_CODCTA=D.CSC_CONTA AND E.CSB_CCUSTO=D.CSC_CCUSTO)) AS CREDITO"
cQuery += " FROM "+RetSqlName("CVN")+" CVN "
cQuery += " INNER JOIN "+RetSqlName("CS4")+" A ON A.D_E_L_E_T_<>'*' AND A.CS4_CODREV='"+MV_PAR01+"' AND CVN_CTAREF=LEFT(A.CS4_CTAREF,LEN(CVN_CTAREF))"
cQuery += " INNER JOIN "+RetSqlName("CT1")+" C ON C.D_E_L_E_T_<>'*' AND C.CT1_FILIAL='"+xFilial("CT1")+"' AND LEN(C.CT1_CONTA)=1 AND LEFT(C.CT1_CONTA,1)=LEFT(A.CS4_CONTA,1)"
cQuery += " INNER JOIN "+RetSqlName("CSC")+" D ON D.D_E_L_E_T_<>'*' AND A.CS4_CODREV=D.CSC_CODREV AND A.CS4_CONTA=D.CSC_CONTA AND A.CS4_CCUSTO=D.CSC_CCUSTO AND LEFT(CS4_CONTA,1) IN ('3','4')"
cQuery += " WHERE CVN.D_E_L_E_T_<>'*'"
cQuery += " AND (CVN_DTVIGF='' OR CVN_DTVIGF>=D.CSC_DTINI)"
cQuery += " AND D.CSC_DTINI BETWEEN '"+DtoS(MV_PAR02)+"' AND '"+DtoS(MV_PAR03)+"'"
cQuery += " AND D.CSC_DTFIM BETWEEN '"+DtoS(MV_PAR02)+"' AND '"+DtoS(MV_PAR03)+"'"
cQuery += " GROUP BY CVN_CTAREF, CVN_DSCCTA, CSC_CODREV, CSC_CONTA, CSC_CCUSTO"

cQuery += " ORDER BY CVN_CTAREF"

//ALCIDES - 11/06/2013 - Tratamento para a tabela NM_BALSPED criada
TcSqlExec(cQuery)

cQuery := "SELECT CONTA, DESCRICAO, SUM(INICIAL) AS INICIAL, SUM(DEBITO) AS DEBITO, SUM(CREDITO) AS CREDITO "
cQuery += " FROM NM_BALSPED"
cQuery += " GROUP BY CONTA, DESCRICAO "
cQuery += "ORDER BY CONTA"

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