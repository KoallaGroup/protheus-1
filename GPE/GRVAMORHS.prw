#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � GRVAMORHS   � Autor � TOTVS				 � Data � 27/01/12 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Grava o rateio da assist. medica/odontol. na RHS antes de   ���
��|          � de gerar a DIRF											   ���
��������������������������������������������������������������������������Ĵ��
���Parametros�															   ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � .T. se a gravacao foi bem sucedida						   ���
���          � .F. caso contrario										   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������/*/
User Function GRVAMORHS()

Local cCadastro   	:= ""
Local nOpca 		:= 	0
Local aSays			:=	{}
Local aButtons		:= 	{}

Private cAliasMap	:= "MpIRHS"	+ cEmpAnt	// Alias do arquivo de Mapa de Importacao do Plano de Saude
Private cNomeInMap	:= ""					// Nome do arquivo de Indice do Mapa de Importacao do Plano de Saude

Private aLog		:= {}
Private aTitle		:= {}
Private aTotRegs	:= array(10)         
Private cTextoLog	:= ""
Private	nContLid0	:= 0		// Contador de Registros Lidos Plano 0
Private	nContGrv0	:= 0		// Contador de Registros Gravados Plano 0
Private	nContLid1	:= 0		// Contador de Registros Lidos Plano 1
Private	nContGrv1	:= 0		// Contador de Registros Gravados Plano 1
Private nPosLog		:= 0

// Confirma abertura das Tabelas
DbSelectArea( "RCB" )	// Definicao de Tabelas
DbSetOrder( 1 )

DbSelectArea( "RCC" )	// Manutencao de Tabelas
DbSetOrder( 1 )

// Cria Consulta Padrao de Assist. Medica/Odontologica especifica para este processamento
AjustaSXB()

cCadastro := OemToAnsi( "Processamento - Grava Rateio Assist. M�d/Odont. no HIST.CALC.PLANO SAUDE (RHS)." )

AADD( aSays, OemToAnsi( "Processamento para grava��o do Rateio de desconto da Assist. M�d/Odont. dos Titulares, "	) )
AADD( aSays, OemToAnsi( "Dependentes e Agregados no HIST. CALC. PLANO DE SAUDE (RHS) para posterior " 				) )
AADD( aSays, OemToAnsi( "gera��o da Dirf 2012 Ano Base 2011."														) )
AADD( aSays, OemToAnsi( "Para o c�lculo do rateio, ser� utilizado o arquivo de Mapa de Importa��o permitindo o "	) )
AADD( aSays, OemToAnsi( "relacionamento entre os Planos de Sa�de dos antigos Par�metros 22 e 58 com os atuais "		) )
AADD( aSays, OemToAnsi( "Planos definidos em Tabelas. Para a regra do c�lculo do rateio utilizamos o mesmo "		) )
AADD( aSays, OemToAnsi( "crit�rio da Dirf anterior."																) )

AADD( aButtons, { 5, .T., {|| nOpca := 1, GeraMapImp( .T. ) }} )
AADD( aButtons, { 1, .T., {|o| nOpca := 2, FechaBatch() }} )
AADD( aButtons, { 2, .T., {|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	Processa( { |lEnd| GeraMapImp( @lEnd )},,, .T.)
ElseIf nOpca == 2
	Processa( { |lEnd| ProcGRVRHS( @lEnd )}, "Processando...", "Aguarde...", .T.) 
Endif

// - Fecha Mapa de Importacao se ainda estiver aberto
If Select( cAliasMap ) > 0
	(cAliasMap)->( dbCloseArea() )
	// Apaga Indice
	if File( cNomeInMap + OrdBagExt() )
		FErase( cNomeInMap + OrdBagExt() )
	EndIf
EndIf

Return Nil

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �ProcGRVRHS � Autor � TOTVS				� Data � 27/01/2012 ���
���������������������������������������������������������������������������͹��
���Desc.     � Executa o processamento.                                   	���
���������������������������������������������������������������������������͹��
���Uso       � GRVAMORHS                                                   	���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ProcGRVRHS( lCancel )

Local aArea			:= GetArea()
Local aCodFol		:= {}
Local aLogAux		:= {}
Local cChavePesq	:= ""			// Chave de pesquisa na RHS
Local aDados		:= {}	 		// Variavel contendo dados do Titular, Dependentes e Agregados para gravacao
Local cArqInd		:= ""	 		// Variavel para nome de arquivo de indice temporario da Tab. SRD em ambiente DBF
Local nIndex		:= ""	 		// Variavel para proxima ordem de indice temporario da Tab. SRD em ambiente DBF
Local nX			:= 0			// Variavel For Next
Local cQry			:= ""	 		// Query para execucao qdo TOP
Local cAnoMesPrc	:= ""			// Ano e Mes de processamento para ambientes TOP e DBF
Local cVerbaAM		:= ""			// Variavel de armazenamento da Verba de Assist. Medica do Titular
Local cVerbaAO		:= ""			// Variavel de armazenamento da Verba de Assist. Odontologica do Titular
Local lAchou		:= .F.			// Var de controle da definicao do Dep. ou Agreg. relacionado a Verba Acum. para amb. DBF

// Variaveis para gravacao de dados da Fase 1
Local cOrigem		:= ""	  					// Origem Titular
Local cCodDepend	:= "  "	 					// Codigo do Dependente ou Branco se for reg do Titular
Local cTpAssist		:= ""						// 1 - Plano, 2-Co-partic. ou 3-Reembolso
Local cFornec		:= ""						// Codigo Fornecedor
Local cTPlano		:= "" 						// Faixa salarial, Faixa Etaria
Local cPlano		:= ""						// Codigo do Plano
Local lLogLido		:= .F.						// Var de controle de geracao de log de registro lido para DBF
Local aPlanos		:= {}						// Var para definicao do Codigo de Fornecedor Plano 1
Local nLine			:= 0						// Linha da definicao do Codigo de Fornecedor Plano 1

// Variaveis de Mensagem de processamento
Local cMsgProc		:= ""
Local cMsgProcMt	:= ""

// Variaveis contendo as tabelas 22 e 58 para apuracao de valores de rateio
Local aAssMedTp1	:= {}
Local aAssMedTp2	:= {}

// Variaveis para criacao / abertura do arquivo de historico
Local aStruRHS		:= {}
Local cIndSrdRhs	:= ""
Local cChvSrdRhs	:= 'RHS_FILIAL+RHS_MAT+DTOS(RHS_DATA)+RHS_ORIGEM+RHS_CODIGO+RHS_PD+RHS_TPLAN+RHS_TPFORN+RHS_CODFOR+RHS_TPPLAN+RHS_PLANO'

// Monta o path do arquivo de acordo com SERVER.INI
Local cPath		:= GetPvProfString( GetEnvServer(), "RootPath"	, "", GetAdv97() )
Local cPath		+= GetPvProfString( GetEnvServer(), "StartPath"	, "", GetAdv97() )

// Variaveis de controle de leitura dos Acumulados (SRD) e gravacao de dados do historico
Private cNomSrdRhs	:= "SRDRHS"	+ cEmpAnt	// Alias da Query da tabela de historico na RHS
Private cAliasSRD 	:= "SRD"				// Alias da tabela de acumulados (SRD em DBF ou TOP)
Private cIdVerAO	:= "714" 				// Identificador de Calculo de Assistencia Odontologica do Funcionario (Titular)
Private cIdVerAM	:= "049" 				// Identificador de Calculo de Assistencia Medica do Funcionario (Titular)
Private lVerbaAM	:= .F.	 				// Indica se eh Verba de Assistencia Medica do Titular conforme o Identificador (cIdVerAM)

Aadd( aTitle, OemToAnsi( "Log da Migra��o dos Planos de Saude das Empresas" ) )
Aadd( aLog	, {} )
Aadd( aTitle, OemToAnsi( "Registros processados - Mapa de Importa��o (Plano 0)" ) )
Aadd( aLog	, {} )
Aadd( aTitle, OemToAnsi( "Inconsist�ncias encontradas (Plano 0)" ) )
Aadd( aLog	, {} )
Aadd( aTitle, OemToAnsi( "Registros processados (Plano 1)" ) )
Aadd( aLog	, {} )
Aadd( aTitle, OemToAnsi( "Inconsist�ncias encontradas (Plano 1)" ) )
Aadd( aLog	, {} )

// Prepara arquivo DBF para gravacao das informacoes do historico
DbSelectArea( "RHS" )
aStruRHS := RHS->( DbStruct() )
RHS->( DbCloseArea() )

cNomSrdRhs	:= Upper( cNomSrdRhs + GetDBExtension() )
cNomSrdRhs	:= RetArq( __LocalDriver, cNomSrdRhs, .T. )
cIndSrdRhs	:= FileNoExt( cNomSrdRhs ) + "I"	// Indice

If ! MSFile( cNomSrdRhs,, __LocalDriver )		// Cria se nao existir o arquivo
	DbCreate( cNomSrdRhs, aStruRHS )
	DbUseArea( .T., __LocalDriver, cNomSrdRhs, cNomSrdRhs, .F. )
	(cNomSrdRhs)->( dbCloseArea() )			// Fecha para reabrir abaixo com arquivo de indice
EndIf

// Aborta processamento se nao conseguir abrir o arquivo DBF para gravacao das informacoes do historico
If ! MsOpenDbf( .T. , __LocalDriver , cNomSrdRhs , cNomSrdRhs , .F. , .F. )
	Help( ,, 'HELP',, OemToAnsi( "N�o foi poss�vel abrir o arquivo " + cNomSrdRhs + " em modo exclusivo." + CRLF + ;
								  "Verifique se est� em uso por outro usu�rio ou se h� " + ;
								  "algum outro impedimento para a abertura do arquivo!"), 1, 0 )

	// Fecha o arquivo do Mapa de Importacao
	If Select( cAliasMap ) > 0
	
		(cAliasMap)->( dbCloseArea() )
	
		// Apaga Indice
		if File( cNomeInMap + OrdBagExt() )
			FErase( cNomeInMap + OrdBagExt() )
		EndIf
	EndIf

	Return
EndIf

// Cria Indice do Arquivo DBF para gravacao das informacoes do historico se conseguiu abrir
DbSelectArea( cNomSrdRhs )
IndRegua( cNomSrdRhs, cIndSrdRhs, cChvSrdRhs,,, "Indexando arquivo DBF do hist�rico de planos de sa�de..." )

// Valida se deseja Limpar a Tabela SRDRHS e eliminar qualquer sujeira que possa existir
If (cNomSrdRhs)->( Reccount( ) ) > 0

	// Valida se deseja Abrir o arquivo em Planilha do Excel somente para arquivo DBF
	If Upper(GetDBExtension()) == '.DBF' .and. ;
		MsgYesNo( "Existem informa��es de Hist�rico na tabela " + cNomSrdRhs + '.' + CRLF + ;
				  "Deseja abrir o arquivo em planilha do Excel para valida��o dos registros gerados?" )

		ShellExecute( "open", "excel", '"' + cPath + cNomSrdRhs + '"', "", 5 )                                                     	

		// - Mapa de Importacao
		If Select( cAliasMap ) > 0
			(cAliasMap)->( dbCloseArea() )
			// Apaga Indice
			if File( cNomeInMap + OrdBagExt() )
				FErase( cNomeInMap + OrdBagExt() )
			EndIf
		EndIf

		// - Arquivo de Gravacao das Informacoes do Historico para RHS
		If Select( cNomSrdRhs ) > 0
			(cNomSrdRhs)->( dbCloseArea() )
		EndIf

		Return

	// Se nao abrir no Excel, pergunta se limpa tudo
	ElseIf MsgYesNo( "Deseja excluir todo hist�rico j� existente antes de reiniciar o processamento?" )
		ZAP
		(cNomSrdRhs)->( DbCommit() )
	EndIf
EndIf

// Prepara indice temporario da tabela SRD para AMBIENTE DBF
#IFNDEF TOP
	DbSelectArea( cAliasSRD )

	// Cria Indice temporario da Tabela SRD
	cArqInd := CriaTrab( Nil, .F. )
	IndRegua( cAliasSRD, cArqInd, "RD_FILIAL+DTOS(RD_DATPGT)+RD_PD+RD_MAT",,,OemToAnsi("Criando �ndice Tempor�rio dos Acumulados - Tabela SRD..."))
	nIndex 	:= RetIndex( cAliasSRD )
	dbSetIndex( cArqInd + OrdBagExt() )
	(cAliasSRD)->( dbSetOrder( nIndex + 1 ) )
#ENDIF 

// Abre arquivo de Mapa de Importacao
If ! GeraMapImp( .F. )
	Help( ,, 'HELP',, OemToAnsi( "N�o foi poss�vel abrir o arquivo " + cAliasMap ), 1, 0 )
	Return
EndIf

DbSelectArea( cAliasMap )
(cAliasMap)->( DbGoTop() )

// Monta regua de processamento
ProcRegua( (cAliasMap)->( RecCount() ) )

cTimeIni := Time() 
aAdd(aLog[1], '- Inicio do processamento em '  + Dtoc(MsDate()) + ', as ' + cTimeIni + '.') // '- Inicio da Leitura/Apontamento em '

While (cAliasMap)->( ! Eof() )

	#IFDEF TOP

		cAliasSRD := "QSRD"

		If ( Select( cAliasSRD ) > 0 )
			(cAliasSRD)->( dbCloseArea() )
		EndIf 

		cQry := "SELECT SRD.RD_FILIAL, SRD.RD_DATARQ, SRD.RD_PD, SRD.RD_MAT, SRD.RD_DATPGT, SRD.RD_VALOR, SRD.RD_EMPRESA "
		cQry += "  FROM " + RetSqlname( "SRD" ) + ' SRD '
		cQry += "       INNER JOIN " + RetSqlName( "SRA" ) + " 	SRA ON SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT "
		cQry += " WHERE SRD.RD_FILIAL = '" + (cAliasMap)->FILMAP + "' "
		cQry += "   AND SRD.RD_DATPGT >= '" + (cAliasMap)->ANOMES + "01' "
		cQry += "   AND SRD.RD_DATPGT <= '" + (cAliasMap)->ANOMES + StrZero(f_UltDia(StoD((cAliasMap)->ANOMES + '01')),2) + "' "
		cQry += "   AND SRD.RD_PD = '" + (cAliasMap)->VERBA + "' "

		If ! Empty( (cAliasMap)->CODASMED )
			cQry += "   AND SRA.RA_ASMEDIC = '" + (cAliasMap)->CODASMED + "' "
		EndIf

		If TcSrvType() != "AS/400"
			cQry += "   AND SRA.D_E_L_E_T_ <> '*' 
			cQry += "   AND SRD.D_E_L_E_T_ <> '*' "
		Else
			cQry += "   AND SRA.@DELETED@ <> '*' "
			cQry += "   AND SRD.@DELETED@ <> '*' "
		EndIf

		cQry += " ORDER BY SRD.RD_FILIAL, SRD.RD_DATPGT, SRD.RD_PD, SRD.RD_MAT "

		cQry := ChangeQuery( cQry )

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasSRD )

	 	cAnoMesPrc := Substr( (cAliasSRD)->RD_DATPGT, 1, 6 )
	#ELSE

		DbSelectArea( cAliasSRD )
		(cAliasSRD)->( dbSetOrder( nIndex + 1 ) )

		// Posiciona no Primeiro registro para inicio de processamento
	 	(cAliasSRD)->( dbSeek( (cAliasMap)->FILMAP + (cAliasMap)->ANOMES ) )
	 	cAnoMesPrc := AnoMes( (cAliasSRD)->RD_DATPGT )

	 	While (cAliasSRD)->( ! Eof() ) .and.	(cAliasSRD)->RD_FILIAL	== (cAliasMap)->FILMAP .and. ;
												cAnoMesPrc				== (cAliasMap)->ANOMES .and. ;
												(cAliasSRD)->RD_PD 		<> (cAliasMap)->VERBA
			(cAliasSRD)->( DbSkip() )
		 	cAnoMesPrc := AnoMes( (cAliasSRD)->RD_DATPGT )
	 	EndDo

	#ENDIF 

	While (cAliasSRD)->( ! Eof() ) .and.	(cAliasSRD)->RD_FILIAL	== (cAliasMap)->FILMAP .and. ;
											cAnoMesPrc				== (cAliasMap)->ANOMES .and. ;
											(cAliasSRD)->RD_PD 		== (cAliasMap)->VERBA

		// Despreza registros vindos de outra empresa devido a transferencia do funcionario
		If ! Empty( (cAliasSRD)->RD_EMPRESA )

			#IFDEF TOP
			 	cAnoMesPrc := Substr( (cAliasSRD)->RD_DATPGT, 1, 6 )
			#ELSE
			 	cAnoMesPrc := AnoMes( (cAliasSRD)->RD_DATPGT )
			#ENDIF 

			(cAliasSRD)->( DbSkip() )	// Le o proximo registro
			Loop
		EndIf

        cMsgProc	:= "Fil: " + (cAliasMap)->FILMAP + " Ano/M�s: " + (cAliasMap)->ANOMES + " Verba: " + (cAliasMap)->VERBA + " 
		cMsgProcMt	:= " Matr: " + (cAliasSRD)->RD_MAT

		IncProc( OemToAnsi( cMsgProc + cMsgProcMt ) )

		#IFDEF TOP
			dDtPagto := StoD((cAliasSRD)->RD_DATPGT)
		#ELSE
			dDtPagto := (cAliasSRD)->RD_DATPGT

			// Validacao do Codigo da Assist. Medica antiga (Param 22 ou 58)
			If ! Empty( (cAliasMap)->CODASMED ) .and. (cAliasMap)->CODASMED <> SRA->RA_ASMEDIC

			 	cAnoMesPrc := AnoMes( (cAliasSRD)->RD_DATPGT )	// Atualiza Ano e Mes do Processamento
				(cAliasSRD)->( DbSkip() )						// Le o proximo registro

				Loop
			EndIf
		#ENDIF 

		aAdd(aLog[2], "" )
        cTextoLog := '- Registro lido (Fil: ' + (cAliasSRD)->RD_FILIAL + ' Matr: ' + (cAliasSRD)->RD_MAT + ' Verba: ' + (cAliasSRD)->RD_PD + ' Data Pagto: ' + DtoC( dDtPagto ) + ' Valor: R$ ' + Transform( (cAliasSRD)->RD_VALOR, "@E 999,999.99" ) + ')'
		aAdd(aLog[2], cTextoLog )
		nContLid0++

		// Posiciona no Funcionario em processamento
		DbSelectArea( 'SRA' )
		DbSetOrder( 1 )			// RA_FILIAL+RA_MAT
		If ! DbSeek( (cAliasSRD)->RD_FILIAL + (cAliasSRD)->RD_MAT )
			//Help( ,, 'HELP',, OemToAnsi( 'Matr�cula n�o encontrada no Cad. de Funcion�rio... ' + CRLF + cMsgProc + CRLF + cMsgProcMt ), 1, 0 )

            cTextoLog := '  -> Filial: ' + (cAliasSRD)->RD_FILIAL + " Matr�cula: " + (cAliasSRD)->RD_MAT + ' n�o encontrada no Cad. de Funcion�rio.'
			aAdd(aLog[2], cTextoLog )

			DbSelectArea( cAliasSRD )
			(cAliasSRD)->( DbSkip() )

			#IFDEF TOP
			 	cAnoMesPrc := Substr( (cAliasSRD)->RD_DATPGT, 1, 6 )
			#ELSE
			 	cAnoMesPrc := AnoMes( (cAliasSRD)->RD_DATPGT )
			#ENDIF 

			Loop
		EndIf

		// Retorna para area principal de processamento
		DbSelectArea( cAliasSRD )

		//Carrega as Configuracoes de Desconto de Assistencia Medica (TIPO 1 - Tabela 22)
		aAssMedTp1 := GPCfgDesAM( "1" )

		//Carrega as Configuracoes de Desconto de Assistencia Medica (TIPO 2 - Tabela 58)
		aAssMedTp2 := GPCfgDesAM( "2" )

		// Carrega Matriz com Titular, Dependentes e Agregados com suas respectivas informacoes de rateio e plano
		GPEVerDep( dDtPagto, @aDados, cAnoMesPrc )

		// Verifica se a verba em processamento eh igual a de Assist. Medica do Titular
		lVerbaAM := ((cAliasSRD)->RD_PD == PosSrv(cIdVerAM,(cAliasSRD)->RD_FILIAL,"RV_COD",RetOrdem("SRV","RV_FILIAL+RV_CODFOL"),.F.))

		// Verifica se eh Assistencia Medica TIPO 1 (Tabela 22 - Faixa Salarial) ou TIPO 2 (Tabela 58 - Faixa Etaria)
		// 		O antigo Parametro 22 (TIPO 1 - Faixa Salarial) corresponde a nova tabela S008 e;
		// 		O antigo Parametro 58 (TIPO 2 - Faixa Etaria) corresponde a nova tabela S009.

		if SubStr( SRA->RA_ASMEDIC,1,1 ) == "E"	//Assistencia Medica TIPO 2 (Tabela 58 - Faixa Etaria)
			nPlanAM := aScan( aAssMedTp2, { |x| x[1] == SRA->RA_ASMEDIC } )
			if nPlanAM > 0
				// Calcula o Rateio da Assistencia Medica TIPO 2 (Tabela 58 - Faixa Etaria)
				GPRatAMTp2( aAssMedTp2[nPlanAM], dDtPagto, (cAliasSRD)->RD_VALOR, @aDados, cAnoMesPrc )
			else
	            cTextoLog := '- Filial: ' + SRA->RA_FILIAL + " Matr�cula: " + SRA->RA_MAT + '. Assistencia medica: ' + SRA->RA_ASMEDIC + ' associada ao funcionario n�o foi encontrada." 
				IF ( nPosLog := aScan(aLog[3],{|x| x == cTextoLog}) ) == 0
					aAdd(aLog[3], cTextoLog )
				EndIF

			endif
		else // Assistencia Medica TIPO 1 (Tabela 22 - Faixa Salarial)
			nPlanAM := aScan( aAssMedTp1, { |x| x[1] == SRA->RA_ASMEDIC } )
			if nPlanAM > 0
				// Calcula o Rateio da Assistencia Medica TIPO 1 (Tabela 22 - Faixa Salarial)
				GPRatAMTp1( aAssMedTp1[nPlanAM], dDtPagto, (cAliasSRD)->RD_VALOR, @aDados, cAnoMesPrc )
			else
	            cTextoLog := '- Filial: ' + SRA->RA_FILIAL + " Matr�cula: " + SRA->RA_MAT + '. Assistencia medica: ' + SRA->RA_ASMEDIC + ' associada ao funcionario n�o foi encontrada." 
				IF ( nPosLog := aScan(aLog[3],{|x| x == cTextoLog}) ) == 0
					aAdd(aLog[3], cTextoLog )
				EndIF

			endif
		endif

		// Verifica Tipo da Assistencia nas novas tabelas
		IF ! U_fValPlaRHS( (cAliasMap)->TPASSIST, (cAliasMap)->FORNEC, (cAliasMap)->TPLANO, (cAliasMap)->PLANO, .F. )
			//Help( ,, 'HELP',, OemToAnsi( 'C�digo do Plano n�o encontrado... ' + CRLF + cMsgProc + CRLF + cMsgProcMt ), 1, 0 )
            
            cTextoLog := '- Filial: ' + SRA->RA_FILIAL + " Matr�cula: " + SRA->RA_MAT + '. C�digo do Plano n�o encontrado. Tp. Assist: ' + (cAliasMap)->TPASSIST + ' Fornec: ' + (cAliasMap)->FORNEC + ' Tp. Plano: ' + (cAliasMap)->TPLANO + ' Cod. Plano: ' + (cAliasMap)->PLANO
			IF ( nPosLog := aScan(aLog[3], {|x| x == cTextoLog}) ) == 0
				aAdd(aLog[3], cTextoLog )
			EndIF	
            
			DbSelectArea( cAliasSRD )
			(cAliasSRD)->( DbSkip() )    

			#IFDEF TOP
			 	cAnoMesPrc := Substr( (cAliasSRD)->RD_DATPGT, 1, 6 )
			#ELSE
			 	cAnoMesPrc := AnoMes( (cAliasSRD)->RD_DATPGT )
			#ENDIF 

			Loop
		EndIf

		// Efetiva a gravacao dos dados apurados
		FGRVDADOS( cAliasSRD, aDados, (cAliasMap)->TPASSIST, (cAliasMap)->FORNEC, (cAliasMap)->TPLANO, (cAliasMap)->PLANO, 0 )

		DbSelectArea( cAliasSRD )
		(cAliasSRD)->( DbSkip() )    

		#IFDEF TOP
		 	cAnoMesPrc := Substr( (cAliasSRD)->RD_DATPGT, 1, 6 )
		#ELSE
		 	cAnoMesPrc := AnoMes( (cAliasSRD)->RD_DATPGT )
		#ENDIF 
	EndDo

	DbSelectArea( cAliasMap )
	(cAliasMap)->( DbSkip() )
EndDo

//�����������������������������������������������������������������������������������������Ŀ
//� Apos o processamento das informacoes, conforme o Mapa de Importacao sera iniciado o		�
//� processamento da importacao do historico dos planos da Fase 1, onde sao definidos os	�
//� Fornecedores, Planos e Verbas independentes para cada Titular, Dependente e Agregado.	�
//� Este processamento sera realizado para toda DATA DE PAGAMENTO efetuada no ano de 2011.	�
//�������������������������������������������������������������������������������������������

// Carrega as duas verbas de assistencia (Medica e Odontologica) do Titular
cVerbaAM := PosSrv( cIdVerAM, xFilial( "SRD" ), "RV_COD", RetOrdem( "SRV", "RV_FILIAL+RV_CODFOL" ), .F. )
cVerbaAO := PosSrv( cIdVerAO, xFilial( "SRD" ), "RV_COD", RetOrdem( "SRV", "RV_FILIAL+RV_CODFOL" ), .F. )

#IFDEF TOP

	cAliasSRD := "QSRD"

	If ( Select( cAliasSRD ) > 0 )
		(cAliasSRD)->( dbCloseArea() )
	EndIf 

	// Monta query principal que recebera as selects com UNION
	cQry := "SELECT * From ( "
	
	// Busca as verbas dos Dependentes e Agregados nesta query
	cQry += " SELECT SRD.RD_FILIAL,SRD.RD_PD,SRD.RD_MAT "

	If ( "MSSQL" $ tcGetDB() )
		cQry += "       ,SUBSTRING(SRDA.RD_DATPGT,1,6) COMP"
	Else
		cQry += "       ,SUBSTR(SRDA.RD_DATPGT,1,6) COMP"
	EndIf

	cQry += "       ,SRDA.RD_DATARQ RD_DATARQ, SRDA.RD_DATPGT RD_DATPGT, SRDA.RD_VALOR RD_VALOR, SRB.RB_COD RB_COD"
	cQry += "       ,SRB.RB_NOME RB_NOME, SRB.RB_TPDEPAM RB_TPDEPAM, SRB.RB_TIPAMED RB_TIPAMED"
	cQry += "       ,SRB.RB_CODAMED RB_CODAMED,SRB.RB_VBDESAM RB_VBDESAM,SRB.RB_DTINIAM RB_DTINIAM"
	cQry += "       ,SRB.RB_DTFIMAM RB_DTFIMAM,SRB.RB_TPDPODO RB_TPDPODO,SRB.RB_TPASODO RB_TPASODO"
	cQry += "       ,SRB.RB_ASODONT RB_ASODONT,SRB.RB_VBDESAO RB_VBDESAO,SRB.RB_DTINIAO RB_DTINIAO"
	cQry += "       ,SRB.RB_DTFIMAO RB_DTFIMAO,SRA.RA_FILIAL RA_FILIAL,SRA.RA_MAT RA_MAT"
	cQry += "       ,SRA.RA_NOME RA_NOME,SRA.RA_TIPAMED RA_TIPAMED,SRA.RA_ASMEDIC RA_ASMEDIC"
	cQry += "       ,SRA.RA_TPASODO RA_TPASODO,SRA.RA_ASODONT RA_ASODONT "

	cQry += "  FROM  " + RetSqlname( "SRD" ) + " SRD "

	cQry += "       LEFT JOIN " + RetSqlname( "SRB" ) + " SRB ON SRD.RD_FILIAL = SRB.RB_FILIAL AND SRD.RD_MAT = SRB.RB_MAT "
	cQry += "		AND ((SRD.RD_DATPGT >= SRB.RB_DTINIAM AND ((SRD.RD_DATPGT <= SRB.RB_DTFIMAM) OR (SRB.RB_DTFIMAM = '        ' ))) "
	cQry += "            OR (SRD.RD_DATPGT >= SRB.RB_DTINIAO AND ((SRD.RD_DATPGT <= SRB.RB_DTFIMAO) OR (SRB.RB_DTFIMAO = '        ' ))))"
	cQry += "		INNER JOIN " + RetSqlname( "SRD" ) + " SRDA ON SRD.RD_FILIAL = SRDA.RD_FILIAL AND SRDA.RD_MAT = SRD.RD_MAT "
	cQry += "							  AND SRDA.RD_PD = SRD.RD_PD AND SRDA.R_E_C_N_O_ = SRD.R_E_C_N_O_ "
	cQry += "		INNER JOIN " + RetSqlname( "SRA" ) + " SRA ON SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT "

	cQry += " WHERE SRD.RD_FILIAL = '" + xFilial( "SRD" ) + "' "

	// Despreza registros vindos de outra empresa devido a transferencia do funcionario
	cQry += "   AND SRD.RD_EMPRESA = '" + Space( Len( cEmpAnt ) ) + "' "

	// Carrega Ano Completo dos Acumulados
	cQry += "   AND SRD.RD_DATPGT >= '20110101' AND SRD.RD_DATPGT <= '20111231' " 

	// Carrega as verbas dos respectivos dependentes
	cQry += "AND (SRD.RD_PD = SRB.RB_VBDESAM OR SRD.RD_PD = SRB.RB_VBDESAO ) "

	If TcSrvType() != "AS/400"
		cQry += "   AND SRD.D_E_L_E_T_ <> '*' "
		cQry += "   AND SRA.D_E_L_E_T_ <> '*' "
		cQry += "   AND SRB.D_E_L_E_T_ <> '*' "
	Else
		cQry += "   AND SRD.@DELETED@ <> '*' "
		cQry += "   AND SRA.@DELETED@ <> '*' "
		cQry += "   AND SRB.@DELETED@ <> '*' "
	EndIf

	cQry += " UNION ALL "

	// Busca as verbas dos ID's 049 e 717 do titular nesta query
	cQry += "SELECT SRD.RD_FILIAL,SRD.RD_PD,SRD.RD_MAT "

	If ( "MSSQL" $ tcGetDB() )
		cQry += "       ,SUBSTRING( SRDA.RD_DATPGT,1,6) COMP"
	Else
		cQry += "       ,SUBSTR( SRDA.RD_DATPGT,1,6) COMP"
	EndIf

	cQry += "       ,MAX(SRDA.RD_DATARQ) RD_DATARQ,MAX(SRDA.RD_DATPGT) RD_DATPGT,SUM(SRDA.RD_VALOR) RD_VALOR,'' RB_COD"
	cQry += "       ,MAX('') RB_NOME, MAX('') RB_TPDEPAM, MAX('') RB_TIPAMED"
	cQry += "       ,MAX('') RB_CODAMED,MAX('') RB_VBDESAM,MAX('') RB_DTINIAM"
	cQry += "       ,MAX('') RB_DTFIMAM,MAX('') RB_TPDPODO,MAX('') RB_TPASODO"
	cQry += "       ,MAX('') RB_ASODONT,MAX('') RB_VBDESAO,MAX('') RB_DTINIAO"
	cQry += "       ,MAX('') RB_DTFIMAO, MAX(SRA.RA_FILIAL) RA_FILIAL,MAX(SRA.RA_MAT) RA_MAT"
	cQry += "       ,MAX(SRA.RA_NOME) RA_NOME,MAX(SRA.RA_TIPAMED) RA_TIPAMED,MAX(SRA.RA_ASMEDIC) RA_ASMEDIC"
	cQry += "       ,MAX(SRA.RA_TPASODO) RA_TPASODO,MAX(SRA.RA_ASODONT) RA_ASODONT "

	cQry += "  FROM " + RetSqlname( "SRD" ) + " SRD "
	cQry += "		INNER JOIN " + RetSqlname( "SRD" ) + " SRDA ON SRD.RD_FILIAL = SRDA.RD_FILIAL AND SRDA.RD_MAT = SRD.RD_MAT "
	cQry += "                                 AND SRDA.RD_PD = SRD.RD_PD AND SRDA.R_E_C_N_O_ = SRD.R_E_C_N_O_ "
	cQry += "		INNER JOIN " + RetSqlname( "SRA" ) + " SRA ON SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT "

	cQry += " WHERE SRD.RD_FILIAL = '" + xFilial( "SRD" ) + "' "

	// Despreza registros vindos de outra empresa devido a transferencia do funcionario
	cQry += "   AND SRD.RD_EMPRESA = '" + Space( Len( cEmpAnt ) ) + "' "

	// Carrega Ano Completo dos Acumulados
	cQry += "   AND SRD.RD_DATPGT >= '20110101' AND SRD.RD_DATPGT <= '20111231' " 

	// Carrega as verbas dos respectivos dependentes
	cQry += "   AND (SRD.RD_PD = '" + cVerbaAM + "' OR SRD.RD_PD = '" + cVerbaAO + "' ) "

	If TcSrvType() != "AS/400"
		cQry += "   AND SRD.D_E_L_E_T_ <> '*' "
		cQry += "   AND SRA.D_E_L_E_T_ <> '*' "
	Else
		cQry += "   AND SRD.@DELETED@ <> '*' "
		cQry += "   AND SRA.@DELETED@ <> '*' "
	EndIf

	cQry += "GROUP BY SRD.RD_FILIAL, SRD.RD_PD, SRD.RD_MAT, SRDA.RD_DATPGT "

	cQry += ") SRDRHS "

	cQry += "ORDER BY SRDRHS.RD_FILIAL,SRDRHS.RD_MAT,SRDRHS.RD_DATPGT,SRDRHS.RB_COD,SRDRHS.RD_PD "

	cQry := ChangeQuery( cQry )

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasSRD )

	// Monta regua de processamento
	DbSelectArea( cAliasSRD )
	ProcRegua( (cAliasSRD)->( RecCount() ) )

	(cAliasSRD)->( DbGoTop() )

	While (cAliasSRD)->( ! Eof() ) .and. (cAliasSRD)->RD_FILIAL == xFilial( "SRD" )

		cMsgProc := "Fil: " + (cAliasSRD)->RD_FILIAL + " Ano/M�s: " + Substr((cAliasSRD)->RD_DATPGT,1,6) + " Verba: " + (cAliasSRD)->RD_PD
		cMsgProcMt := " Matr: " + (cAliasSRD)->RD_MAT

		// Limpa array de gravacao
		aDados := {}

		IncProc( OemToAnsi( cMsgProc + cMsgProcMt ) )

		// Atualiza var com a respectiva data de pagamento
		dDtPagto := StoD((cAliasSRD)->RD_DATPGT) 

		aAdd(aLog[4], "" )
		cTextoLog := '- Registro lido (Fil: ' + (cAliasSRD)->RD_FILIAL + " Matr: " + (cAliasSRD)->RD_MAT + " Verba: " + (cAliasSRD)->RD_PD + ' Data Pagto: ' + DtoC( dDtPagto ) + " Valor: R$ " + Transform( (cAliasSRD)->RD_VALOR, "@E 999,999.99" ) + ")"
		aAdd(aLog[4], cTextoLog )
		nContLid1++

		// Valida e despreza o registro se a Verba existir no Mapa de importacao para evitar duplicidade no lancamento do historico
		cChavePesq := (cAliasSRD)->RD_FILIAL
		cChavePesq += Substr( (cAliasSRD)->RD_DATPGT, 1, 6 )
		cChavePesq += (cAliasSRD)->RD_PD

		DbSelectArea( cAliasMap )	// Indice do arquivo = FILMAP+ANOMES+VERBA+ASMEDANT+CODASMED+ORIGEM+TPASSIST+FORNEC+PLANO

		// Basta encontrar Filial, DataArq e Codigo da Verba para desprezar a gravacao deste registro
		If (cAliasMap)->( DbSeek( cChavePesq ) )
			//Help( ,, 'HELP',, OemToAnsi( 'Verba processada no rateio conforme Mapa de Importa��o...' + CRLF + cMsgProc + CRLF + cMsgProcMt ), 1, 0 )

			cTextoLog := '  -> Este Lan�amento foi processado no rateio conforme Mapa de Importa��o. N�o pode ser considerado neste processamento.'
			aAdd(aLog[4], cTextoLog )

			DbSelectArea( cAliasSRD )
			(cAliasSRD)->( DbSkip() )
			Loop
		EndIf

		// Retorna para area principal de processamento
		DbSelectArea( cAliasSRD )

		// Variaveis para gravacao de dados da Fase 1
		cOrigem		:= ""						// Origem Titular
		cCodDepend	:= "  "						// Codigo do Dependente ou Branco se for reg do Titular
		cTpAssist	:= ""						// 1 - Plano, 2-Co-partic. ou 3-Reembolso
		cTPlano		:= ""						// Faixa salarial, Faixa Etaria
		cPlano		:= ""						// Codigo do Plano
		cFornec		:= ""						// Codigo Fornecedor

		// Carrega Planos de Saude para o Funcionario
 		BuscaForn( aPlanos  )

		// Define informacoes para gravacao
		If ! Empty( cVerbaAM ) .and. cVerbaAM == (cAliasSRD)->RD_PD

			cOrigem		:= "1"												// Origem Titular
			cCodDepend	:= "  "			   									// Codigo do Dependente ou Branco se for reg do Titular
			cTpAssist	:= "1"												// 1 - Plano, 2-Co-partic. ou 3-Reembolso
			cTPlano		:= (cAliasSRD)->RA_TIPAMED							// Faixa salarial, Faixa Etaria
			cPlano		:= (cAliasSRD)->RA_ASMEDIC							// Codigo do Plano

			If (cAliasSRD)->RA_TIPAMED == "1"
				nLine := aScan( aPlanos, { |x| x[1]=="S008" .and. x[3]==(cAliasSRD)->RA_ASMEDIC } )
			Else
				nLine := aScan( aPlanos, { |x| x[1]=="S009" .and. x[3]==(cAliasSRD)->RA_ASMEDIC } )
			EndIf

			If nLine > 0	// // Carrega Codigo Fornecedor se encontrou
				cFornec := aPlanos[ nLine, 2 ]	

				cTextoLog := '  -> Verba ' + (cAliasSRD)->RD_PD + ' de Assist. M�dica do Titular '
				cTextoLog += ' com Dt.Pgto ' + DtoC( dDtPagto ) + " Valor: R$ " + Transform( (cAliasSRD)->RD_VALOR, "@E 999,999.99" )
				aAdd(aLog[4], cTextoLog )
			Else
				cTextoLog := '  -> N�o Gravado. C�digo Fornec. da Assist. M�dica ' + (cAliasSRD)->RA_ASMEDIC + ' do Titular n�o foi localizado.'
				aAdd(aLog[4], cTextoLog )

				DbSelectArea( cAliasSRD )
				(cAliasSRD)->( DbSkip() )
				Loop
			EndIf

		ElseIf ! Empty( cVerbaAO ) .and. cVerbaAO == (cAliasSRD)->RD_PD

			cOrigem		:= "1"												// Origem Titular
			cCodDepend	:= "  "												// Codigo do Dependente ou Branco se for reg do Titular
			cTpAssist	:= "2"												// 1 - Plano, 2-Co-partic. ou 3-Reembolso
			cTPlano		:= (cAliasSRD)->RA_TPASODO							// Faixa salarial, Faixa Etaria
			cPlano		:= (cAliasSRD)->RA_ASODONT							// Codigo do Plano

			If (cAliasSRD)->RA_TPASODO == "1"
				nLine := aScan( aPlanos, { |x| x[1]=="S013" .and. x[3]==(cAliasSRD)->RA_ASODONT } )
			Else
				nLine := aScan( aPlanos, { |x| x[1]=="S014" .and. x[3]==(cAliasSRD)->RA_ASODONT } )
			EndIf

			If nLine > 0	// // Carrega Codigo Fornecedor se encontrou
				cFornec := aPlanos[ nLine, 2 ]	

				cTextoLog := '  -> Verba ' + (cAliasSRD)->RD_PD + ' de Assist. Odontol. do Titular '
				cTextoLog += ' com Dt.Pgto ' + DtoC( dDtPagto ) + " Valor: R$ " + Transform( (cAliasSRD)->RD_VALOR, "@E 999,999.99" )
				aAdd(aLog[4], cTextoLog )
			Else
				cTextoLog := '  -> N�o Gravado. C�digo Fornec. da Assist. Odontol. do ' + (cAliasSRD)->RA_ASODONT + ' Titular n�o foi localizado.'
				aAdd(aLog[4], cTextoLog )

				DbSelectArea( cAliasSRD )
				(cAliasSRD)->( DbSkip() )
				Loop
			EndIf

		ElseIf (cAliasSRD)->RD_PD == (cAliasSRD)->RB_VBDESAM

			cOrigem		:= (cAliasSRD)->RB_TPDEPAM							// Origem Dependente / Agregado Assis. Medica
			cOrigem		:= If(cOrigem == '1', '2', '3')
			cCodDepend	:= (cAliasSRD)->RB_COD								// Codigo do Dependente / Agregado Assis. Medica
			cTpAssist	:= "1"												// 1 - Plano, 2-Co-partic. ou 3-Reembolso
			cTPlano		:= (cAliasSRD)->RB_TIPAMED							// Faixa salarial, Faixa Etaria
			cPlano		:= (cAliasSRD)->RB_CODAMED							// Codigo do Plano

			If (cAliasSRD)->RB_TIPAMED == "1"
				nLine := aScan( aPlanos, { |x| x[1]=="S008" .and. x[3]==(cAliasSRD)->RB_CODAMED } )
			Else
				nLine := aScan( aPlanos, { |x| x[1]=="S009" .and. x[3]==(cAliasSRD)->RB_CODAMED } )
			EndIf

			If nLine > 0	// // Carrega Codigo Fornecedor se encontrou
				cFornec := aPlanos[ nLine, 2 ]	
			Else
				cTextoLog := '  -> N�o Gravado. C�digo Fornec. da Assist. M�dica ' + (cAliasSRD)->RB_CODAMED
				cTextoLog += ' do ' + If(cOrigem=="2", "Dependente ", "Agregado ") + cCodDepend + ' n�o foi localizado.'
				aAdd(aLog[4], cTextoLog )

				DbSelectArea( cAliasSRD )
				(cAliasSRD)->( DbSkip() )
				Loop
			EndIf

			// Despreza Registro acumulado caso a data nao esteja dentro da vigencia
			If 	(cAliasSRD)->RD_DATPGT <= (cAliasSRD)->RB_DTINIAM .or. ;
				( ! Empty( (cAliasSRD)->RB_DTFIMAM ) .and. (cAliasSRD)->RD_DATPGT >= (cAliasSRD)->RB_DTFIMAM )

	            cTextoLog := '  -> N�o Gravado. Dt.Pagto do ' + If(cOrigem=="2", "Dependente ", "Agregado ") + cCodDepend
	            cTextoLog += ' fora da vig�ncia da Assist. M�dica: '
	            cTextoLog += ' In�cio: ' + DtoC(StoD((cAliasSRD)->RB_DTINIAM)) + ' Fim: ' + DtoC(StoD((cAliasSRD)->RB_DTFIMAM))
				aAdd(aLog[4], cTextoLog )

				DbSelectArea( cAliasSRD )
				(cAliasSRD)->( DbSkip() )
				Loop
			Else
				cTextoLog := '  -> Verba de Assist. M�dica do ' 
				cTextoLog += If( cOrigem=="2", "Dependente ", "Agregado ") + cCodDepend
				cTextoLog += ' com Dt.Pgto ' + DtoC( dDtPagto ) + " Valor: R$ " + Transform( (cAliasSRD)->RD_VALOR, "@E 999,999.99" )
				aAdd(aLog[4], cTextoLog )
			EndIf

		ElseIf (cAliasSRD)->RD_PD == (cAliasSRD)->RB_VBDESAO
			cOrigem		:= (cAliasSRD)->RB_TPDPODO							// Origem Dependente / Agregado Assis. Odontologica
			cOrigem		:= If(cOrigem == '1', '2', '3')
			cCodDepend	:= (cAliasSRD)->RB_COD								// Codigo do Dependente / Agregado Assis. Odontologica
			cTpAssist	:= "2"												// 1 - Plano, 2-Co-partic. ou 3-Reembolso
			cTPlano		:= (cAliasSRD)->RB_TPASODO							// Faixa salarial, Faixa Etaria
			cPlano		:= (cAliasSRD)->RB_ASODONT							// Codigo do Plano

			If (cAliasSRD)->RB_TPASODO == "1"
				nLine := aScan( aPlanos, { |x| x[1]=="S013" .and. x[3]==(cAliasSRD)->RB_ASODONT } )
			Else
				nLine := aScan( aPlanos, { |x| x[1]=="S014" .and. x[3]==(cAliasSRD)->RB_ASODONT } )
			EndIf

			If nLine > 0	// // Carrega Codigo Fornecedor se encontrou
				cFornec := aPlanos[ nLine, 2 ]	
			Else
				cTextoLog := '  -> N�o Gravado. C�digo Fornec. da Assist. Odontol. ' + (cAliasSRD)->RB_ASODONT
				cTextoLog += ' do ' + If(cOrigem=="2", "Dependente ", "Agregado ") + cCodDepend + ' n�o foi localizado.'
				aAdd(aLog[4], cTextoLog )

				DbSelectArea( cAliasSRD )
				(cAliasSRD)->( DbSkip() )
				Loop
			EndIf

			// Despreza Registro acumulado caso a data nao esteja dentro da vigencia
			If 	(cAliasSRD)->RD_DATPGT <= (cAliasSRD)->RB_DTINIAO .or. ;
				( ! Empty( (cAliasSRD)->RB_DTFIMAO ) .and. (cAliasSRD)->RD_DATPGT >= (cAliasSRD)->RB_DTFIMAO )

	            cTextoLog := '  -> N�o Gravado. Dt.Pagto do ' + If(cOrigem=="2","Dependente ","Agregado ") + cCodDepend
	            cTextoLog += ' fora da vig�ncia da Assist. Odont.: '
	            cTextoLog += ' In�cio: ' + DtoC(StoD((cAliasSRD)->RB_DTINIAO)) + ' Fim: ' + DtoC(StoD((cAliasSRD)->RB_DTFIMAO))
				aAdd(aLog[4], cTextoLog )

				DbSelectArea( cAliasSRD )
				(cAliasSRD)->( DbSkip() )
				Loop
			Else
				cTextoLog := '  -> Verba de Assist. Odontol. do ' 
				cTextoLog += If( cOrigem=="2", "Dependente ", "Agregado ") + cCodDepend
				cTextoLog += ' com Dt.Pgto ' + DtoC( dDtPagto ) + " Valor: R$ " + Transform( (cAliasSRD)->RD_VALOR, "@E 999,999.99" )
				aAdd(aLog[4], cTextoLog )
			EndIf
		EndIf

   		// Caso cOrigem CONTINUE vazio indica que nao eh verba do titular, nem dep./agreg. e deve desprezar gravacao
		If ! Empty( cOrigem )

			// Alimenta array para gravacao
		                	//	Filial		 Mat. Func	  Cod Dep.	  Vlr Desc.		  Ass. Med.
							//	1			 2			  3           4				  5
			aAdd( aDados, { (cAliasSRD)->RD_FILIAL, (cAliasSRD)->RD_MAT, cCodDepend	, (cAliasSRD)->RD_VALOR, cOrigem } )//2=dependente;3=agregado

			// Efetiva a gravacao
		  	FGRVDADOS( cAliasSRD, aDados, cTpAssist, cFornec, cTPlano, cPlano, 1 )
		Else
            cTextoLog := '  -> N�o Gravado. N�o h� relacionamento desta verba com Assist. M�dica ou Odontol�gica'
			aAdd(aLog[4], cTextoLog )
		EndIf

		DbSelectArea( cAliasSRD )
		(cAliasSRD)->( DbSkip() )    
	EndDo

#ELSE	// Processamento Ambiente DBF

	// Em DBF o ponto de partida eh o cad. de funcionarios
	DbSelectArea( 'SRA' )
	dbSetOrder( 1 )

	// Monta regua de processamento
	ProcRegua( SRA->( RecCount() ) )

	SRA->( DbGoTop() )

	While SRA->( ! Eof() ) .and. SRA->RA_FILIAL == xFilial( "SRA" )

		cMsgProc := "Fil: " + SRA->RA_FILIAL + " Matr: " + SRA->RA_MAT

		IncProc( OemToAnsi( cMsgProc ) )

		// Despreza funcionario que nao tem plano de saude
		If Empty( SRA->RA_TIPAMED ) .or. Empty( SRA->RA_TPASODO )
			cTextoLog := '- Funcion�rio da Filial ' + AllTrim( SRA->RA_FILIAL ) + ' e Matr�cula ' + SRA->RA_MAT + ' sem plano de sa�de.'
			aAdd( aLog[5], cTextoLog )

			DbSelectArea( 'SRA' )
			SRA->( DbSkip() )
			Loop
		EndIf

		// Posiciona nos Lancamento Acumulados SRD do funcionario
		DbSelectArea( 'SRD' )
		DbSetOrder( 4 )			// RD_FILIAL+RD_MAT+DTOS(RD_DATPGT)+RD_PD+RD_SEMANA+RD_SEQ+RD_CC

		// Carrega Planos de Saude para o Funcionario
 		BuscaForn( aPlanos  )

		// Processar todo o ano do funcionario
		DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + '201101' )

		While SRD->( ! Eof() ) .and. SRA->(RA_FILIAL + RA_MAT) == SRD->(RD_FILIAL + RD_MAT) .and. ;
			  DtoS(SRD->RD_DATPGT) >= '20110101' .and. DtoS(SRD->RD_DATPGT) <= '20111231'

			// Despreza registros vindos de outra empresa devido a transferencia do funcionario
			If ! Empty( SRD->RD_EMPRESA )
				SRD->( DbSkip() )  			// Le o proximo registro
				Loop
			EndIf

			// Limpa Variaveis para gravacao de dados da Fase 1
			cOrigem		:= ""		// Origem Titular
			cCodDepend	:= "  "		// Codigo do Dependente ou Branco se for reg do Titular
			cTpAssist	:= ""		// 1 - Plano, 2-Co-partic. ou 3-Reembolso
			cFornec		:= ""		// Codigo Fornecedor
			cTPlano		:= ""		// Faixa salarial, Faixa Etaria
			cPlano		:= ""		// Codigo do Plano
			aDados		:= {}		// Array de Gravacao

			// Valida e despreza o registro se a Verba existir no Mapa de importacao para evitar duplicidade no lancamento do historico
			cChavePesq := SRD->RD_FILIAL
			cChavePesq += MesAno( SRD->RD_DATPGT )
			cChavePesq += SRD->RD_PD

			DbSelectArea( cAliasMap )	// Indice do arquivo = FILMAP + ANOMES + VERBA + ASMEDANT + CODASMED + ORIGEM + TPASSIST + FORNEC + PLANO

			// Basta encontrar Filial, DataArq e Codigo da Verba para desprezar a gravacao deste registro
			If (cAliasMap)->( DbSeek( cChavePesq ) )
				//Help( ,, 'HELP',, OemToAnsi( 'Verba processada no rateio conforme Mapa de Importa��o...' + CRLF + cMsgProc + CRLF + cMsgProcMt ), 1, 0 )

				aAdd(aLog[4], "" )
				cTextoLog := '- Registro lido (Fil: ' + SRA->RA_FILIAL + ' Matr: ' + SRA->RA_MAT + ' Verba: ' + SRD->RD_PD + ' com Dt.Pgto ' + DtoC(SRD->RD_DATPGT)  + " Valor: R$ " + Transform( SRD->RD_VALOR, "@E 999,999.99" ) + ')'
				aAdd(aLog[4], cTextoLog )
				nContLid1++

				cTextoLog := '  -> Esta verba foi processada conforme Mapa de Importa��o. N�o pode ser considerada neste processamento.'
				aAdd(aLog[4], cTextoLog )

				DbSelectArea( 'SRD' )
				SRD->( DbSkip() )
				Loop
			EndIf

			// Define informacoes para gravacao se a Verba for dos ID's 049 ou 714 do Titular
			If ! Empty( cVerbaAM ) .and. cVerbaAM == SRD->RD_PD

				cOrigem		:= "1"						// Origem Titular
				cCodDepend	:= "  "			   			// Codigo do Dependente ou Branco se for reg do Titular
				cTpAssist	:= "1"						// 1 - Plano, 2-Co-partic. ou 3-Reembolso
				cTPlano		:= SRA->RA_TIPAMED			// Faixa salarial, Faixa Etaria
				cPlano		:= SRA->RA_ASMEDIC		   	// Codigo do Plano

				aAdd(aLog[4], "" )
				cTextoLog := '- Registro lido (Fil: ' + SRA->RA_FILIAL + ' Matr: ' + SRA->RA_MAT + ' Verba: ' + SRD->RD_PD + ' com Dt.Pgto ' + DtoC(SRD->RD_DATPGT)  + " Valor: R$ " + Transform( SRD->RD_VALOR, "@E 999,999.99" ) + ')'
				aAdd(aLog[4], cTextoLog )
				nContLid1++

				If SRA->RA_TIPAMED == "1"
					nLine := aScan( aPlanos, { |x| x[1]=="S008" .and. x[3]==SRA->RA_ASMEDIC } )
				Else
					nLine := aScan( aPlanos, { |x| x[1]=="S009" .and. x[3]==SRA->RA_ASMEDIC } )
				EndIf

				If nLine > 0	// // Carrega Codigo Fornecedor se encontrou
					cFornec := aPlanos[ nLine, 2 ]	
				Else
					cTextoLog := '  -> N�o Gravado. C�digo Fornec. da Assist. M�dica ' + SRA->RA_ASMEDIC + ' do Titular n�o foi localizado. '
					aAdd(aLog[4], cTextoLog )

					DbSelectArea( 'SRD' )
					SRD->( DbSkip() )
					Loop
				EndIf

				cTextoLog := '  -> Verba de Assist. M�dica do Titular: ' + SRD->RD_PD + ' com Dt.Pgto ' + DtoC(SRD->RD_DATPGT) + " Valor: R$ " + Transform( SRD->RD_VALOR, "@E 999,999.99" )
				aAdd(aLog[4], cTextoLog )

			ElseIf ! Empty( cVerbaAO ) .and. cVerbaAO == SRD->RD_PD

				cOrigem		:= "1"						// Origem Titular
				cCodDepend	:= "  "						// Codigo do Dependente ou Branco se for reg do Titular
				cTpAssist	:= "2"						// 1 - Plano, 2-Co-partic. ou 3-Reembolso
				cTPlano		:= SRA->RA_TPASODO			// Faixa salarial, Faixa Etaria
				cPlano		:= SRA->RA_ASODONT			// Codigo do Plano

				aAdd(aLog[4], "" )
				cTextoLog := '- Registro lido (Fil: ' + SRA->RA_FILIAL + ' Matr: ' + SRA->RA_MAT + ' Verba: ' + SRD->RD_PD + ' com Dt.Pgto ' + DtoC(SRD->RD_DATPGT)  + " Valor: R$ " + Transform( SRD->RD_VALOR, "@E 999,999.99" ) + ')'
				aAdd(aLog[4], cTextoLog )
				nContLid1++

				If SRA->RA_TPASODO == "1"
					nLine := aScan( aPlanos, { |x| x[1]=="S013" .and. x[3]==SRA->RA_ASODONT } )
				Else
					nLine := aScan( aPlanos, { |x| x[1]=="S014" .and. x[3]==SRA->RA_ASODONT } )
				EndIf

				If nLine > 0	// // Carrega Codigo Fornecedor se encontrou
					cFornec := aPlanos[ nLine, 2 ]	
				Else
					cTextoLog := '  -> N�o Gravado. C�digo Fornec. da Assist. Odontol. ' + SRA->RA_ASODONT + ' do Titular n�o foi localizado. '
					aAdd(aLog[4], cTextoLog )

					DbSelectArea( 'SRD' )
					SRD->( DbSkip() )
					Loop
				EndIf

				cTextoLog := '  -> Verba de Assist. Odontol. do Titular ' + SRD->RD_PD + ' com Dt.Pgto ' + DtoC(SRD->RD_DATPGT) + " Valor: R$ " + Transform( SRD->RD_VALOR, "@E 999,999.99" )
				aAdd(aLog[4], cTextoLog )

			EndIf

			// Atualiza var com a respectiva data de pagamento
			dDtPagto := SRD->RD_DATPGT

    		// Caso cOrigem esteja vazio verifica se a verba eh de algum dep./agreg.
			If Empty( cOrigem )

				lAchou		:= .F.	// Var de pesquisa do Dep/Agreg
				lLogLido	:= .F.	// Var de controle de geracao de log de registro lido para DBF

				// Posiciona nos Depend/Agreg. do Funcionario conforme o Acumulado (SRD) em processamento
				DbSelectArea( 'SRB' )
				DbSetOrder( 1 )			// RB_FILIAL+RB_MAT
				SRB->( DbSeek( SRA->RA_FILIAL + SRA->RA_MAT ) )

				While SRB->( ! Eof() ) .and. SRA->(RA_FILIAL+RA_MAT) == SRB->(RB_FILIAL+RB_MAT) .and. ! lAchou

					// Se a Verba de Assist. Medica ou Odontologica for igual a verba em
					// processamento significa que esta posicionado no Dep./Agreg. correto,
					// pois nao pode haver mesma Verba para dois dependentes ou agregados
					If SRD->RD_PD == SRB->RB_VBDESAM
                                
						If ! lLogLido
							aAdd(aLog[4], "" )
							cTextoLog := '- Registro lido (Fil: ' + SRA->RA_FILIAL + ' Matr: ' + SRA->RA_MAT + ' Verba: ' + SRD->RD_PD + ' com Dt.Pgto ' + DtoC(SRD->RD_DATPGT)  + " Valor: R$ " + Transform( SRD->RD_VALOR, "@E 999,999.99" ) + ')'
							aAdd(aLog[4], cTextoLog )
							nContLid1++
							lLogLido := .T.		// Var de controle de geracao de log de registro lido para DBF
						EndIf

						If (dDtPagto >= SRB->RB_DTINIAM .and. ( Empty( SRB->RB_DTFIMAM ) .or. dDtPagto <= SRB->RB_DTFIMAM ))
							cCodDepend	:= SRB->RB_COD			// Codigo do Dependente / Agregado Assis. Medica
							cTpAssist	:= "1"					// 1 - Plano, 2-Co-partic. ou 3-Reembolso
							cTPlano		:= SRB->RB_TIPAMED		// Faixa salarial, Faixa Etaria
							cPlano		:= SRB->RB_CODAMED		// Codigo do Plano
							lAchou		:= .T.

							If SRB->RB_TIPAMED == "1"
								nLine := aScan( aPlanos, { |x| x[1]=="S008" .and. x[3]==SRB->RB_CODAMED } )
							Else
								nLine := aScan( aPlanos, { |x| x[1]=="S009" .and. x[3]==SRB->RB_CODAMED } )
							EndIf

							If nLine > 0	// // Carrega Codigo Fornecedor se encontrou e continua
								cOrigem := SRB->RB_TPDEPAM		// Origem Dependente / Agregado Assis. Medica
								cOrigem	:= If(cOrigem == '1', '2', '3')
								cFornec := aPlanos[ nLine, 2 ]	// Codigo Fornecedor

								cTextoLog := '  -> Verba de Assist. M�dica do ' 
								cTextoLog += If( cOrigem=="2", "Dependente ", "Agregado ") + cCodDepend
								cTextoLog += ' com Dt.Pgto ' + DtoC(SRD->RD_DATPGT) + " Valor: R$ " + Transform( SRD->RD_VALOR, "@E 999,999.99" )
								aAdd( aLog[4], cTextoLog )
							Else
								cTextoLog := '  -> N�o Gravado. C�digo Fornec. da Assist. M�dica ' + SRB->RB_CODAMED 
								cTextoLog += ' do ' + If( cOrigem=="2", "Dependente ", "Agregado ") + cCodDepend +' n�o foi localizado. '
								aAdd( aLog[4], cTextoLog )
							EndIf
						Else
				            cTextoLog := '  -> N�o Gravado. Dt.Pagto do Dep./Agreg. fora da vig�ncia da Assist. M�dica -'
			    	        cTextoLog += ' In�cio: ' + DtoC( SRB->RB_DTINIAM ) + ' Fim: ' + DtoC( SRB->RB_DTFIMAM )
							aAdd( aLog[4], cTextoLog )
						EndIf

					ElseIf SRD->RD_PD == SRB->RB_VBDESAO

						If ! lLogLido
							aAdd(aLog[4], "" )
							cTextoLog := '- Registro lido (Fil: ' + SRA->RA_FILIAL + ' Matr: ' + SRA->RA_MAT + ' Verba: ' + SRD->RD_PD + ' com Dt.Pgto ' + DtoC(SRD->RD_DATPGT)  + " Valor: R$ " + Transform( SRD->RD_VALOR, "@E 999,999.99" ) + ')'
							aAdd(aLog[4], cTextoLog )
							nContLid1++
							lLogLido := .T.		// Var de controle de geracao de log de registro lido para DBF
						EndIf

						IF (dDtPagto >= SRB->RB_DTINIAO .and. ( Empty( SRB->RB_DTFIMAO ) .or. dDtPagto <= SRB->RB_DTFIMAO ))
							cCodDepend	:= SRB->RB_COD					// Codigo do Dependente / Agregado Assis. Odontologica
							cTpAssist	:= "2"							// 1 - Plano, 2-Co-partic. ou 3-Reembolso
							cTPlano		:= SRB->RB_TPASODO				// Faixa salarial, Faixa Etaria
							cPlano		:= SRB->RB_ASODONT				// Codigo do Plano
							lAchou		:= .T.

							If SRB->RB_TPASODO == "1"
								nLine := aScan( aPlanos, { |x| x[1]=="S013" .and. x[3]==SRB->RB_ASODONT } )
							Else
								nLine := aScan( aPlanos, { |x| x[1]=="S014" .and. x[3]==SRB->RB_ASODONT } )
							EndIf

							If nLine > 0	// // Carrega Codigo Fornecedor se encontrou
								cOrigem := SRB->RB_TPDPODO			// Origem Dependente / Agregado Assis. Odontologica
								cOrigem	:= If(cOrigem == '1', '2', '3')
								cFornec := aPlanos[ nLine, 2 ]		// Codigo Fornecedor

								cTextoLog := '  -> Verba de Assist. Odontol. do ' 
								cTextoLog += If( cOrigem=="2", "Dependente ", "Agregado ") + cCodDepend
								cTextoLog += ' com Dt.Pgto ' + DtoC(SRD->RD_DATPGT) + " Valor: R$ " + Transform( SRD->RD_VALOR, "@E 999,999.99" )
								aAdd( aLog[4], cTextoLog )
							Else
								cTextoLog := '  -> N�o Gravado. C�digo Fornec. da Assist. Odontol. ' + SRB->RB_ASODONT 
								cTextoLog += ' do ' + If( cOrigem=="2", "Dependente ", "Agregado ") + cCodDepend +' n�o foi localizado. '
								aAdd( aLog[4], cTextoLog )
							EndIf
						Else
				            cTextoLog := '  -> N�o Gravado. Dt.Pagto do Dep./Agreg. fora da vig�ncia da Assist. Odont. -'
	    			        cTextoLog += ' In�cio: ' + DtoC( SRB->RB_DTINIAO ) + ' Fim: ' + DtoC( SRB->RB_DTFIMAO )
							aAdd(aLog[4], cTextoLog )
						EndIf
					EndIf

					If ! lAchou
						SRB->( DbSkip() )
					EndIf
				EndDo
			EndIf

    		// Caso cOrigem CONTINUE vazio indica que nao eh verba do titular, nem dep./agreg. e deve desprezar gravacao
			If ! Empty( cOrigem )

				// Alimenta array para gravacao
			                	//	Filial		 Mat. Func	  Cod Dep.	  Vlr Desc.		  Ass. Med.
								//	1			 2			  3           4				  5
				aAdd( aDados, { SRD->RD_FILIAL, SRD->RD_MAT, cCodDepend, SRD->RD_VALOR, cOrigem 	}  )//2=dependente;3=agregado

				// Efetiva a gravacao
			  	FGRVDADOS( 'SRD', aDados, cTpAssist, cFornec, cTPlano, cPlano, 1 )
			EndIf

			DbSelectArea( 'SRD' )
			SRD->( DbSkip() )
		EndDo

		// Apos processar todo o ano de um funcionario, vai para o proximo e comeca novamente
		DbSelectArea( 'SRA' )
		SRA->( DbSkip() )
	EndDo

#ENDIF 

// Valida se deseja Abrir o arquivo em Planilha do Excel somente para arquivo DBF
If Upper(GetDBExtension()) == '.DBF' .and. ;
	MsgYesNo( "Final de Processamento!!!" + CRLF + "Deseja abrir o arquivo em planilha do Excel para valida��o dos registros gerados?" )

	ShellExecute( "open", "excel", '"' + cPath + cNomSrdRhs + '"', "", 5 )                                                     	

EndIf

aAdd(aLog[1], "- Final do processamento em " + Dtoc(MsDate()) + ", as " + Time() + ".")
aAdd(aLog[1], "- Tempo decorrido: " + RemainingTime( cTimeIni , GetFirstRemaining() , .F. ) )
aAdd(aLog[1], "- Total de registros lidos - Mapa de Importa��o (Plano 0) : " + cValToChar(nContLid0) )
aAdd(aLog[1], "- Total de registros gravados - Mapa de Importa��o (Plano 0) : " + cValToChar(nContGrv0) )
aAdd(aLog[1], "- Total de registros lidos (Plano 1) : " + cValToChar(nContLid1) )
aAdd(aLog[1], "- Total de registros gravados (Plano 1) : " + cValToChar(nContGrv1) )

// - Fecha arquivo temporario da SRD
If Select( cAliasSRD ) > 0
	(cAliasSRD)->( dbCloseArea() )
	// Apaga Indice
	if File( cArqInd + OrdBagExt() )
		FErase( cArqInd + OrdBagExt() )
	EndIf
EndIf

// - Mapa de Importacao
If Select( cAliasMap ) > 0
	(cAliasMap)->( dbCloseArea() )
	// Apaga Indice
	if File( cNomeInMap + OrdBagExt() )
		FErase( cNomeInMap + OrdBagExt() )
	EndIf
EndIf

// - Arquivo de Gravacao das Informacoes do Historico para RHS
If Select( cNomSrdRhs ) > 0
	(cNomSrdRhs)->( dbCloseArea() )
/*	// Apaga Indice
	if File( cIndSrdRhs + OrdBagExt() )
		FErase( cIndSrdRhs + OrdBagExt() )
	EndIf*/
EndIf

fMakeLog(aLog,aTitle,,,"RateioAMO","Log de ocorr�ncias do Rateio de Assist. M�d/Odont.","M","P",,.F.) //"Log de ocorr�ncias da DIRF"

RestARea( aArea )

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � GeraMapImp	� Autor � TOTVS				   � Data � 27/01/2012 ���
������������������������������������������������������������������������������͹��
���Descricao � Geracao do arquivo Mapa de leitura da SRD para importacao na	   ���
���          � tabela RHS.                                                     ���
������������������������������������������������������������������������������͹��
���Parametros� 		                                                           ���
������������������������������������������������������������������������������͹��
���Uso       � GRVAMORHS                       	                               ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Static Function GeraMapImp( lGeraMapa )

Local lRet			:= .T.
Local cNomArq		:= ""
Local cIndChave		:= "FILMAP+ANOMES+VERBA+ASMEDANT+CODASMED+ORIGEM+TPASSIST+FORNEC+PLANO"	// Indice do arquivo
Local aFields		:= {}
Local oDlg			:= NIL
Local nX, nY		:= 0
Local lOk			:= .T.
Local cArqBkp		:= cAliasMap + '.BKP'
Local lGerMpOrig	:= .F.			// Var de backup da origem da chamada da funcao lGeraMapa Sim ou Nao

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local nMaxLim		:= 9999

Private oGetxA
Private aHeaderA	:= {}
Private aLbxA		:= {}
PRIVATE aTrocaF3	:= {}	// Var utilizada para trocar o F3 no aHeader

Default lGeraMapa := .F. // Somente gera mapa se usuario clicar no botao parametros. Caso contrario somente abre o arquivo.

// Guarda conteudo original na chamada da funcao lGeraMapa Sim ou Nao para manter aberto o arquivo qdo forcar a abertura
lGerMpOrig := lGeraMapa

//�����������������������������������������������������������������������������Ŀ
//� Cria matriz de estrutura do arquivo. Ao alterar a ordem de algum dos campos	�
//� abaixo, nao esqueca de ajustar a ordem tambem no AHEADERA logo mais abaixo.	�
//�������������������������������������������������������������������������������
//				  1-Campo	, 2-Tipo, 3-Tam	, 4-Dec	, 5-Titulo		, 6-Validacao  											, 7-ComboBox
AAdd( aFields, { 'FILMAP'	, 'C'	, 02	, 0		, "Filial"		, "NaoVazio() .and. ExistCpo('SM0',cEmpAnt+M->FILMAP)"	, ''				  					} )
AAdd( aFields, { 'ANOMES'	, 'C'	, 06	, 0		, "Ano/Mes"		, "NaoVazio()"											, ''				  					} )
AAdd( aFields, { 'VERBA'	, 'C'	, 03	, 0		, "Cod.Verba"	, "NaoVazio() .and. ExistCpo( 'SRV' )"					, ''				   					} )
AAdd( aFields, { 'ASMEDANT'	, 'C'	, 01	, 0		, "As.Med.Ant"	, "Pertence( '012' )"	  								, '0= ;1=Parametro 22;2=Parametro 58'	} )
AAdd( aFields, { 'CODASMED'	, 'C'	, 02	, 0		, "Cod.As.Med"	, ""					  								, ''									} )
AAdd( aFields, { 'ORIGEM'	, 'C'	, 01	, 0		, "Origem"		, "NaoVazio() .and. Pertence( '123' )"					, '1=Titular;2=Dependente;3=Agregado'	} )
AAdd( aFields, { 'TPASSIST'	, 'C'	, 01	, 0		, "Tp. Assist"	, "NaoVazio() .and. Pertence( '123456' )"				, '1=Medica;2=Odontologica;3=Co-Part. Med.;4=Co-Part. Odont.;5=Reemb. Med.;6=Reemb. Odont.'	} )
AAdd( aFields, { 'TPLANO'	, 'C'	, 01	, 0		, "Tp. Plano"	, "NaoVazio() .and. Pertence( '1234' )"					, '1=Faixa Salarial;2=Faixa Etaria;3=Valor Fixo;4=% S/ Salario'	} )
AAdd( aFields, { 'FORNEC'	, 'C'	, 03	, 0		, "Cod.Fornec"	, "NaoVazio() .AND. U_fValForRHS()"	 					, ''									} )
AAdd( aFields, { 'PLANO'	, 'C'	, 02	, 0		, "Cod.Plano"	, "NaoVazio() .AND. U_fValPlaRHS()"	 					, ''									} )

cNomArq		:= cAliasMap + GetDBExtension()
cNomArq		:= RetArq( __LocalDriver, cNomArq, .T. )
cNomeInMap	:= FileNoExt( cNomArq ) + "I"				// Indice

If ! MSFile( cNomArq,, __LocalDriver )	// Cria se nao existir o arquivo
	DbCreate( cNomArq, aFields )
	DbUseArea( .T., __LocalDriver , cNomArq, cAliasMap, .F. )
	lGeraMapa := .T.					// Forca geracao do mapa caso o arquivo seja criado
	(cAliasMap)->( dbCloseArea() )		// Fecha para reabrir abaixo com arquivo de indice
EndIf

// Apaga Indice se existir
If File( cNomeInMap + OrdBagExt() )
	FErase( cNomeInMap + OrdBagExt() )
EndIf

// Cria Backup do arquivo Mapa Importacao
__CopyFile( cNomArq, cArqBkp )

// Abre Arquivo
If ! MsOpenDbf( .T. , __LocalDriver , cNomArq , cAliasMap , .T. , .F. )
	Help( ,, 'HELP',, OemToAnsi( "N�o foi poss�vel abrir o arquivo " + cNomArq ), 1, 0 )
	lRet := .F.
EndIf

If lRet
	//Cria Indice do Arquivo se conseguiu abrir
	IndRegua( cAliasMap, cNomeInMap, cIndChave,,, "Indexando Arquivo de Mapa de Importa��o..." )
EndIf

If lRet .and. lGeraMapa

	aHeaderA := {}	// Monta Cabecalho do aHeaderA. A ordem dos elementos devem obedecer a sequencia da estrutura dos campos logo acima. aFields[0,6]
					// 	01-Titulo				, 02-Campo		, 03-Picture, 04-Tamanho	, 05-Decimal, 06-Valid		, 07-Usado	, 08-Tipo		, 09-F3		, 10-Contexto	, 11-ComboBox	, 12-Relacao	, 13-When		, 14-Visual	, 15-Valid Usuario
	aAdd( aHeaderA, {	aFields[01,5]+Space(20)	, aFields[01,1]	, '@!'		, aFields[01,3]	, 0			, aFields[01,6]	, ''		, aFields[01,2]	, 'SM0'		, 'R'			, aFields[01,7]	, ''			, ''   			, ''		, ''				} )
	aAdd( aHeaderA, {	aFields[02,5]+Space(20)	, aFields[02,1]	, '@!'		, aFields[02,3]	, 0			, aFields[02,6]	, ''		, aFields[02,2]	, ''		, 'R'			, aFields[02,7]	, ''			, ''  			, ''		, ''				} )
	aAdd( aHeaderA, {	aFields[03,5]+Space(20)	, aFields[03,1]	, '@!'		, aFields[03,3]	, 0			, aFields[03,6]	, ''		, aFields[03,2]	, 'SRV'		, 'R'			, aFields[03,7]	, ''			, '' 			, ''		, ''				} )
	aAdd( aHeaderA, {	aFields[04,5]+Space(20)	, aFields[04,1]	, '@!'		, aFields[04,3]	, 0			, aFields[04,6]	, ''		, aFields[04,2]	, ''		, 'R'			, aFields[04,7]	, '0'			, ''			, ''		, ''				} )
	aAdd( aHeaderA, {	aFields[05,5]+Space(20)	, aFields[05,1]	, '@!'		, aFields[05,3]	, 0			, aFields[05,6]	, ''		, aFields[05,2]	, 'X22'		, 'R'			, aFields[05,7]	, ''			, 'U_fRHSWhen()', ''		, ''				} )
	aAdd( aHeaderA, {	aFields[06,5]+Space(20)	, aFields[06,1]	, '@!'		, aFields[06,3]	, 0			, aFields[06,6]	, ''		, aFields[06,2]	, ''		, 'R'			, aFields[06,7]	, ''			, ''			, ''		, ''				} )
	aAdd( aHeaderA, {	aFields[07,5]+Space(20)	, aFields[07,1]	, '@!'		, aFields[07,3]	, 0			, aFields[07,6]	, ''		, aFields[07,2]	, ''		, 'R'	  		, aFields[07,7]	, ''			, ''			, ''		, ''				} )
	aAdd( aHeaderA, {	aFields[08,5]+Space(20)	, aFields[08,1]	, '@!'		, aFields[08,3]	, 0			, aFields[08,6]	, ''		, aFields[08,2]	, ''		, 'R'			, aFields[08,7]	, ''			, ''   			, ''		, ''				} )
	aAdd( aHeaderA, {	aFields[09,5]+Space(20)	, aFields[09,1]	, '@!'		, aFields[09,3]	, 0			, aFields[09,6]	, ''		, aFields[09,2]	, 'AMORHS'	, 'R'			, aFields[09,7]	, ''			, ''   			, ''		, ''				} )
	aAdd( aHeaderA, {	aFields[10,5]+Space(20)	, aFields[10,1]	, '@!'		, aFields[10,3]	, 0			, aFields[10,6]	, ''		, aFields[10,2]	, 'AMORHS'	, 'R'			, aFields[10,7]	, ''			, ''   			, ''		, ''				} )

	DbSelectArea( cAliasMap )
	(cAliasMap)->( DbGoTop() )

	aLbxA := {}
	While (cAliasMap)->( ! Eof() )
		aAux := {}
		For nX := 1 To Len( aHeaderA )
		    aAdd( aAux, &(aHeaderA[nX][2]) )
		Next                                 
		aAdd( aAux, .F. )
		Aadd( aLbxA, aAux )
		(cAliasMap)->( DbSkip() )
	EndDo

    If Empty( aLbxA )
	    aAux := {}
    	For nX := 1 To Len( aHeaderA )     
    		xAux := ''
    		If aHeaderA[nX][8] == 'C'
    			xAux := Space( aHeaderA[nX][4] )
    		ElseIf aHeaderA[nX][8] == 'N'
    			xAux := 0                
   			ElseIf aHeaderA[nX][8] == 'D'
	   			xAux := CToD( '' )
    		ElseIf aHeaderA[nX][8] == 'L'
	    		xAux := .F.
    		EndIf
		    aAdd( aAux, xAux )
		Next 
		aAdd( aAux, .F. )
		Aadd( aLbxA, aAux )
    Endif

	/*
	��������������������������������������������������������������Ŀ
	� Monta as Dimensoes dos Objetos         					   �
	����������������������������������������������������������������*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 0 , 0 }

	aAdd( aObjCoords , { 020, 001, .T. , .F. } )
	aAdd( aObjCoords , { 000, 000, .T. , .T. } )

	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi( "Mapa de Importa��o - Plano de Sa�de" ) From aAdvSize[7],0 TO aAdvSize[6]-10, aAdvSize[5] OF oMainWnd PIXEL //Style 128

								//  nTop		   nLeft		   nBottom			 nRight			 Controle da GetDado - nstyle		, LinOK			, TudoOk		, cIniCPOS	, aAlter, nfreeze, nMax		, cFieldOK	, uSuperDel	, uDelOK, oDialogo	, aHeader	, aCols )
  	oGetxA := MsNewGetDados():New( aObjSize[2,1], aObjSize[2,2], aObjSize[2,3]-10, aObjSize[2,4], GD_INSERT + GD_UPDATE + GD_DELETE	, 'U_MpAMOLinOk', 'U_MpAMOTudOk',			,		,		 , nMaxLim	, NIL		, NIL		, 		, oDlg		, aHeaderA	, aLbxA )

	bSet15	:= { || lOk := oGetxA:TudoOk(), If( lOk, oDlg:End(), .F. ) }
	bSet24	:= { || oDlg:End(), lOk := .F. }

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15, bSet24, NIL, {} ) CENTERED 

	If lOk

		DbSelectArea( cAliasMap )
		(cAliasMap)->( DbGoTop() )

		// Deleta todos os registros da tabela antes de gravar os do aCols
		While (cAliasMap)->( ! Eof() )
			RecLock( cAliasMap, .F. )
			DbDelete( )
			MsUnLock()
	  		(cAliasMap)->( DbSkip() )
		EndDo

		For nX := 1 TO Len( oGetxA:aCols )
	        // Pula se registro no aCols estiver Deletado
	        If ! oGetxA:aCols[ nX, Len( oGetxA:aCols[ nX ] ) ]
				// Inclui os registros do aCols na tabela
				(cAliasMap)->( RecLock( cAliasMap, .T. ) )
	        	For nY := 1 to Len( aFields )
			        cCampo    	:= Trim( aHeaderA[ nY ][ 2 ] )
		    	    &cCampo 	:= oGetxA:aCols[ nX, nY ]
                Next
				(cAliasMap)->( MsUnLock()	)
	        Endif
		Next
	EndIf
EndIf

If lGeraMapa .and. lGerMpOrig	 // Somente fecha o arquivo se a origem da chamada desta funcao for .T.
	// Fecha Arquivo
	If Select( cAliasMap ) > 0

		(cAliasMap)->( dbCloseArea() )

		// Apaga Indice
		if File( cNomeInMap + OrdBagExt() )
			FErase( cNomeInMap + OrdBagExt() )
		EndIf
	EndIf
EndIf

Return( lRet )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � fRHSWhen	   � Autor � TOTVS				 � Data � 27/01/12 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes de campos antes da digitacao.					   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GRVAMORHS												   ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � .T. Permite Digitacao									   ���
���          � .F. Nao Permite Digitacao								   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������/*/
User Function fRHSWhen( )
Local nPosASMEAN	:= GdFieldPos( 'ASMEDANT' )
Local lRet			:= .T.

If oGetxA:aCols[ oGetxA:oBrowse:nAt, nPosASMEAN ] == '1'
	aTrocaF3 := { { 'CODASMED', 'X22' } }
Else
	aTrocaF3 := { { 'CODASMED', 'X58' } }
EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPCfgDesAM�Autor  � TOTVS				 � Data � 27/01/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega as Configuracoes de Desconto de Assistencia Medica ���
���          � TIPO 1 - Tabela 22 e TIPO 2 - Tabela 58					  ���
�������������������������������������������������������������������������͹��
���Uso       � GRVAMORHS                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GPCfgDesAM( cTpAssMed )
Local aRet 		:= {}
Local cChaveSRX := ""
Local cCodPlan  := ""
Local nVlTitular:= 0
Local nVlrDepend:= 0
Local nPercAM	:= 0
Local nVlrPlano := 0
Local nLimSal1 	:= 0
Local nPercFun1 := 0
Local nPercDep1 := 0
Local nLimSal2 	:= 0
Local nPercFun2 := 0
Local nPercDep2 := 0
Local nLimSal3 	:= 0
Local nPercFun3 := 0
Local nPercDep3 := 0
Local nLimSal4 	:= 0
Local nPercFun4 := 0
Local nPercDep4 := 0
Local nLimSal5 	:= 0
Local nPercFun5 := 0
Local nPercDep5 := 0
Local nLimSal6 	:= 0
Local nPercFun6 := 0
Local nPercDep6 := 0

dbSelectArea("SRX")
SRX->( dbSetOrder(1) ) //RX_FILIAL+RX_TIP+RX_COD

// O antigo Parametro 22 (TIPO 1 - Faixa Salarial) corresponde a nova tabela S008 e;
// O antigo Parametro 58 (TIPO 2 - Faixa Etaria) corresponde a nova tabela S009.

if cTpAssMed == "1" // TIPO 1 (Tabela 22)

	//Busca Configuracoes de Desconto de Assistencia Medica TIPO 1 (Tabela 22)
	if SRX->( dbSeek(SRA->RA_FILIAL+"22") )
		cChaveSRX := SRA->RA_FILIAL+"22"
	elseif SRX->( dbSeek(Space(FWGETTAMFILIAL)+"22") )
		cChaveSRX := Space(FWGETTAMFILIAL)+"22"
	endif
	
	if SRX->(Found())
		while SRX->( !EoF() ) .and. SRX->(RX_FILIAL+RX_TIP) == cChaveSRX
			cCodPlan 	:= Right(Alltrim(SRX->RX_COD),2)
			nVlTitular	:= Val(SubStr(SRX->RX_TXT,21,12))
			nVlrDepend	:= Val(SubStr(SRX->RX_TXT,33,12))
			nPercAM		:= Val(SubStr(SRX->RX_TXT,45,07))
			aAdd( aRet, { cCodPlan, nVlTitular, nVlrDepend, nPercAM } )
			SRX->( dbSkip() )
		end
	endif

elseif cTpAssMed == "2" //TIPO 2 (Tabela 58)

	//Busca Configuracoes de Desconto de Assistencia Medica TIPO 2 (Tabela 58)
	if SRX->( dbSeek(SRA->RA_FILIAL+"58") )
		cChaveSRX := SRA->RA_FILIAL+"58"
	elseif SRX->( dbSeek(Space(FWGETTAMFILIAL)+"58") )
		cChaveSRX := Space(FWGETTAMFILIAL)+"58"
	endif

	if SRX->(Found())
		while SRX->( !EoF() ) .and. SRX->(RX_FILIAL+RX_TIP) == cChaveSRX
			cCodPlan := SubStr(Right(Alltrim(SRX->RX_COD),4),1,2)
			nVlrPlano := Val(SubStr(SRX->RX_txt,21,14))

			SRX->( dbSkip() )
			nLimSal1    := Val(SubStr(SRX->RX_txt,01,14))
			nPercFun1   := Val(SubStr(SRX->RX_txt,15,06))
			nPercDep1   := Val(SubStr(SRX->RX_txt,21,06))
			If nLimSal1 == 0
				nLimSal1 := 99999999999.99
			EndIf
			nLimSal2    := Val(SubStr(SRX->RX_TXT,27,14))
			nPercFun2   := Val(SubStr(SRX->RX_TXT,41,06))
			nPercDep2   := Val(SubStr(SRX->RX_TXT,47,06))
			If nLimSal2 == 0
				nLimSal2 := 99999999999.99
			EndIf
			SRX->( dbSkip() )
			nLimSal3    := Val(SubStr(SRX->RX_TXT,01,14))
			nPercFun3   := Val(SubStr(SRX->RX_TXT,15,06))
			nPercDep3   := Val(SubStr(SRX->RX_TXT,21,06))
			If nLimSal3 == 0
				nLimSal3 := 99999999999.99
			EndIf
			nLimSal4    := Val(SubStr(SRX->RX_TXT,27,14))
			nPercFun4   := Val(SubStr(SRX->RX_TXT,41,06))
			nPercDep4   := Val(SubStr(SRX->RX_TXT,47,06))
			If nLimSal4 == 0
				nLimSal4 := 99999999999.99
			EndIf
			SRX->( dbSkip() )
			nLimSal5    := Val(SubStr(SRX->RX_TXT,01,14))
			nPercFun5   := Val(SubStr(SRX->RX_TXT,15,06))
			nPercDep5   := Val(SubStr(SRX->RX_TXT,21,06))
			If nLimSal5 == 0
				nLimSal5 := 99999999999.99
			EndIf
			nLimSal6    := Val(SubStr(SRX->RX_TXT,27,14))
			nPercFun6   := Val(SubStr(SRX->RX_TXT,41,06))
			nPercDep6   := Val(SubStr(SRX->RX_TXT,47,06))
			If nLimSal6 == 0
				nLimSal6 := 99999999999.99
			EndIf

			aAdd( aRet, { cCodPlan, nVlrPlano,;
				{nLimSal1, nPercFun1, nPercDep1},;
				{nLimSal2, nPercFun2, nPercDep2},;
				{nLimSal3, nPercFun3, nPercDep3},;
				{nLimSal4, nPercFun4, nPercDep4},;
				{nLimSal5, nPercFun5, nPercDep5},;
				{nLimSal6, nPercFun6, nPercDep6} } )

			SRX->( dbSkip() )
		end
	endif

endif

Return aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEVerDep �Autor  � TOTVS				 � Data � 27/01/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     � Consiste os Dependentes Cadastrados.                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GRVAMORHS                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GPEVerDep( dDtPagto, aDados, cAnoMesRef )
Local cFilSRB 	:= (cAliasSRD)->RD_FILIAL
Local nIdade  	:= 0
Local dDtVlIdade:= cToD( "31/12/" + AllTrim(Str(Year( dDtPagto ))))	//Data a ser considerada para verificar a idade do Dependente

aDados := {}

                //	Filial        			Mat. Func   		Cod Depend.  Vlr Desc.	  Ass. Med. do Dependente
				//	1            			2            		3         	  4        	   5
aAdd( aDados, { (cAliasSRD)->RD_FILIAL, (cAliasSRD)->RD_MAT, "  "			, 0			, "1" } )

dbSelectArea("SRB")
SRB->( dbSetOrder(1) ) //RB_FILIAL+RB_MAT
if SRB->( dbSeek( cFilSRB + (cAliasSRD)->RD_MAT ) )
	while SRB->( !EoF() ) .and. SRB->(RB_FILIAL+RB_MAT) == (cAliasSRD)->RD_FILIAL+(cAliasSRD)->RD_MAT
		//Verifica se os NOVOS campos estao alimentados
		if Empty( SRB->RB_TPDEPAM )
			//aAdd( aLog, { SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_NOME, "--", oemtoansi("Informar se o Dependente "+SRB->RB_COD + "-" + Left(SRB->RB_NOME,15) + " � ou n�o dependente de Assist. M�dica") } )

            cTextoLog := '- Filial: ' + SRA->RA_FILIAL + ' Matr�cula: ' + SRA->RA_MAT + ". Informar se o Dependente "+SRB->RB_COD + "-" + AllTrim(Left(SRB->RB_NOME,15)) + " � ou n�o dependente de Assist�ncia M�dica"
			IF ( nPosLog := aScan(aLog[3],{|x| x == cTextoLog }) ) == 0
				aAdd(aLog[3], cTextoLog )
			EndIF

			SRB->( dbSkip() )
			Loop
		else 
			if SRB->RB_TPDEPAM $ "1|2" //1=Dependente; 2=Agregado

				//����������������������������������������������������������������������Ŀ
				//�Verifica se a Assist. Medica esta vigente na data de pagto. em questao�
				//������������������������������������������������������������������������
				if ! Empty( SRB->RB_DTINIAM ) .and. cAnoMesRef < AllTrim(Str(Year( SRB->RB_DTINIAM )))+StrZero(Month( SRB->RB_DTINIAM ),2)
					SRB->( dbSkip() )
					Loop
				endif

				if ! Empty( SRB->RB_DTFIMAM ) .and. cAnoMesRef > AllTrim(Str(Year( SRB->RB_DTFIMAM )))+StrZero(Month( SRB->RB_DTFIMAM ),2)
					SRB->( dbSkip() )
					Loop
				endif

				//Verifica a idade do dependente
				nIdade := Calc_Idade( dDtVlIdade , SRB->RB_DTNASC )

				                //Filial        Mat. Func   Cod Depend.  Vlr Desc.	  Ass. Med. do Dependente
								//   1            2            3    		4        	5
				aAdd( aDados, { SRB->RB_FILIAL, SRB->RB_MAT, SRB->RB_COD, 0		, If(SRB->RB_TPDEPAM=='1','2','3') } )
			endif
		endif
		SRB->( dbSkip() )
	enddo
endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPRatAMTp1�Autor  � TOTVS				 � Data � 27/01/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula o Rateio da Assistencia Medica (TIPO 1)            ���
���          � (tabela 22)                                                ���
�������������������������������������������������������������������������͹��
���Uso       � GRVAMORHS                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GPRatAMTp1( aAssistMed, dDtRefPag, nVlrAMLanc, aDados, cAnoMesRef )
Local nX			:= 0
Local nVlrTitula	:= aAssistMed[2]
Local nVlrDepend	:= aAssistMed[3]
Local nPercDesc		:= aAssistMed[4] / 100
Local nDescFunc		:= 0
Local nDescDep		:= 0
Local nTotDesDep	:= 0
Local nTotDesCal	:= 0
Local nPerRatFun	:= 0
Local nPerRatDep	:= 0
Local nDesRatFun	:= 0
Local nDesRatDep	:= 0
Local nTotRatDep	:= 0
Local nPos			:= 0

// Verifica se a verba em processamento eh igual a de Assist. Medica do Titular
// Se forem iguais devera processar o rateio. Se nao forem iguais indica que o Valor Total da SRD
// sera lancado conforme informado no arquivo de Mapa de Importacao.
//(Apenas para o 1=Titular ou 2=Dependente ou 3=Agregado ( aDados[ nX, 5 ] = 1, 2 ou 3 )
If ! lVerbaAM

	// Verifica em qual elemento de aDados vai lancar
	nPos := Ascan( aDados, {|X| X[5] == (cAliasMap)->ORIGEM } )	// 1 = Titular; 2 = Dependente; 3 = Agregado

	If nPos > 0
		aDados[ nPos ][ 4 ]	:= nVlrAMLanc	// Grava todo o valor conforme mapa de importacao
	Else
		aDados[ 1 ][ 4 ]	:= nVlrAMLanc	// Se NAO encontrou, grava todo o valor para o 1 elemento que eh o Titular
	EndIf

	Return
EndIf

//Calcula os valores de desconto do plano de Assis. Medica conforme esta configurado o Plano atualmente
nDescFunc := nVlrTitula * nPercDesc
nDescDep  := nVlrDepend * nPercDesc


//Totaliza o valor calculado de descontos de todos os dependentes do funcionario
nTotDesDep := nDescDep * (len(aDados)-1) //Multiplica o valor de desconto do dependente pelo numero de Dependentes

//Totaliza o Desconto Calculado (Funcionario + Dependentes)
nTotDesCal := nDescFunc + nTotDesDep


//Calcula o percentual de desconto a ser considerado para o Funcionario
nPerRatFun := nDescFunc / nTotDesCal

//Calcula o percentual de desconto a ser considerado para cada Dependente
nPerRatDep := nDescDep / nTotDesCal

//Valor de desconto rateado para o Funcionario
nDesRatFun := nVlrAMLanc * nPerRatFun

//Valor de desconto rateado para cada Dependente
nDesRatDep := nVlrAMLanc * nPerRatDep

//Valor do Funcionario (Titular)
aDados[1][4] := nDesRatFun

//Valor dos Dependentes
For nX := 2 to len( aDados )
	aDados[nX][4] := nDesRatDep
	nTotRatDep += nDesRatDep
Next nX

//TIRA TEIMA:
//Verificar se os valores Rateados equivale ao valor Total de Desconto de Assist. Medica Lancado na tabela SRD
if nVlrAMLanc <> (nTotRatDep + nDesRatFun)
    cTextoLog := '- Filial: ' + SRA->RA_FILIAL + ' Matr�cula: ' + SRA->RA_MAT + ". Valores Diferentes: Lan�ado(RD_VALOR)= "+AllTrim(Transform(nVlrAMLanc, "@E 999,999.99"))+ " # Total rateado(Func.+Dep.)= "+AllTrim(Transform(nTotRatDep+nDesRatFun, "@E 999,999.99"))
	IF ( nPosLog := aScan(aLog[3],{|x| x == cTextoLog }) ) == 0
		aAdd(aLog[3], cTextoLog )
	EndIF

endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPRatAMTp2�Autor  � TOTVS				 � Data � 27/01/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula o Rateio da Assistencia Medica (TIPO 2)            ���
���          � (tabela 58)                                                ���
�������������������������������������������������������������������������͹��
���Uso       � GRVAMORHS                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GPRatAMTp2( aAssistMed, dDtRefPag, nVlrAMLanc, aDados, cAnoMesRef )

Local nSalFunc 	:= fBuscaSal(dDtRefPag,,,.T.,) //Busca Salario do funcionario na data de referencia
Local nInd 		:= 0
Local nX 		:= 0
Local nValorPlan:= aAssistMed[2] //Valor do Plano
Local nPerDesFun:= 0
Local nPerDesDep:= 0
Local nVlrDesFun:= 0
Local nVlrDesDep:= 0
Local nTotDesDep:= 0
Local nTotRatDep:= 0
Local nTotDesCal:= 0
Local nPerRatFun:= 0
Local nPerRatDep:= 0
Local nDesRatFun:= 0	// Armazena o desconto rateado de Assis. Medica Lancado para o Funcionaio
Local nDesRatDep:= 0	// Armazena o desconto rateado de Assis. Medica Lancado para os Dependentes

// Verifica se a verba em processamento eh igual a de Assist. Medica do Titular
// Se forem iguais devera processar o rateio. Se nao forem iguais indica que o Valor Total da SRD
// sera lancado conforme informado no arquivo de Mapa de Importacao.
//(Apenas para o 1=Titular ou 2=Dependente ou 3=Agregado ( aDados[ nX, 5 ] = 1, 2 ou 3 )
If ! lVerbaAM

	// Verifica em qual elemento de aDados vai lancar
	nPos := Ascan( aDados, {|X| X[5] == (cAliasMap)->ORIGEM } )	// 1 = Titular; 2 = Dependente; 3 = Agregado

	If nPos > 0
		aDados[ nPos ][ 4 ]	:= nVlrAMLanc	// Grava todo o valor conforme mapa de importacao
	Else
		aDados[ 1 ][ 4 ]	:= nVlrAMLanc	// Se NAO encontrou, grava todo o valor para o 1 elemento que eh o Titular
	EndIf

	Return
EndIf

//Calcula os valores de desconto do plano de Assis. Medica conforme esta configurado o Plano atualmente
For nInd := 3 to 8
	If nSalFunc < aAssistMed[nInd][1]  //Faixa de Salario
		nPerDesFun := aAssistMed[nInd][2] / 100 //Percentual de Desconto Funcionario
		nPerDesDep := aAssistMed[nInd][3] / 100 //Percentual de Desconto Dependente
		
		nVlrDesFun := nValorPlan * nPerDesFun   //Calcula Valor de Desconto do Funcionario
		nVlrDesDep := nValorPlan * nPerDesDep   //Calcula Valor de Desconto do Dependente
		
		Exit
	EndIf
Next nX

//Totaliza o valor calculado de descontos de todos os dependentes do funcionario
nTotDesDep := nVlrDesDep * (len(aDados)-1) //Multiplica o valor de desconto do dependente pelo numero de Dependentes

//Totaliza o Desconto Calculado (Funcionario + Dependentes)
nTotDesCal := nVlrDesFun + nTotDesDep


//Calcula o percentual de desconto a ser considerado para o Funcionario
nPerRatFun := nVlrDesFun / nTotDesCal

//Calcula o percentual de desconto a ser considerado para cada Dependente
nPerRatDep := nVlrDesDep / nTotDesCal

//Valor de desconto rateado para o Funcionario
nDesRatFun := nVlrAMLanc * nPerRatFun

//Valor de desconto rateado para cada Dependente
nDesRatDep := nVlrAMLanc * nPerRatDep

//Valor do Funcionario (Titular)
aDados[1][4] := nDesRatFun

//Valor dos Dependentes
For nX := 2 to len( aDados )
	aDados[nX][4] := nDesRatDep
	nTotRatDep += nDesRatDep
Next nX

//TIRA TEIMA:
//Verificar se os valores Rateados equivale ao valor Total de Desconto de Assist. Medica Lancado na tabela SRD
if nVlrAMLanc <> (nTotRatDep + nDesRatFun)
    cTextoLog := '- Filial: ' + SRA->RA_FILIAL + ' Matr�cula: ' + SRA->RA_MAT + ". Valores Diferentes: Lan�ado(RD_VALOR)= "+AllTrim(Transform(nVlrAMLanc, "@E 999,999.99"))+ " # Total rateado(Func.+Dep.)= "+AllTrim(Transform(nTotRatDep+nDesRatFun, "@E 999,999.99"))
	IF ( nPosLog := aScan(aLog[3],{|x| x == cTextoLog }) ) == 0
		aAdd(aLog[3], cTextoLog )
	EndIF

endif

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � FGRVDADOS   � Autor � TOTVS				 � Data � 27/01/12 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os dados apurados na tabela SRDRHS.				   ���
��������������������������������������������������������������������������Ĵ��
���Parametros�															   ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum													   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������/*/
Static Function FGRVDADOS( cAlias, aDados, cTpAssist, cFornec, cTPlano, cPlano, nFaseProc )
Local nX			:= 0		// Variavel For Next
Local cChavePesq	:= ""		// Chave de pesquisa na RHS
Local cTipoAssis	:= ""		// 1-Plano, 2-Co-Partic., 3-Reembolso
Local cTipoForne	:= ""		// 1-Assist. Medica, 2-Assist. Odontologica

// TIPO DO PLANO conforme (cAliasMap)->TPASSIST
//		1=Medica 		ou 2=Odontologica	 corresponde a 1-PLANO
//		3=Co-Part. Med.	ou 4=Co-Part. Odont. corresponde a 2-CO-PARTICIPACAO
//		5=Reemb. Med.	ou 6=Reemb. Odont.	 corresponde a 3-REEMBOLSO

If cTpAssist $ '34'
	cTipoAssis := '2'
ElseIf cTpAssist $ '56'	
	cTipoAssis := '3'
Else
	cTipoAssis := '1'	// ASSUME (1-PLANO) para qualquer informacao diferente de '3456'
EndIf

// TIPO DO FORNECEDOR conforme (cAliasMap)->TPASSIST
//		1=Medica	   ou 3=Co-Part. Med.	ou 5=Reemb. Med.   corresponde a 1 - Assist. Medica
//		2=Odontologica ou 4=Co-Part. Odont. ou 6=Reemb. Odont. corresponde a 2 - Assist. Odontologica 

If cTpAssist $ '246'
	cTipoForne := '2'
Else
	cTipoForne := '1'	// ASSUME (1-Assist. Medica) para qualquer informacao diferente de '246'
EndIf

// Se aDados estiver com apenas um elemento, indica que todo o valor lancado na verba pertence ao Titular
For nX := 1 to Len( aDados )

	// Descarta gravacao se elemento referente ao valor apurado estiver zerado
	If aDados[ nX, 4 ] > 0
		cChavePesq := (cAlias)->RD_FILIAL + (cAlias)->RD_MAT + DtoS( dDtPagto )
		cChavePesq += aDados[ nX, 5 ]			// 1 = Titular; 2 = Dependente; 3 = Agregado
		cChavePesq += aDados[ nX, 3 ]			// Codigo de Sequencia do Dependente ou Agregado. Para o Titular sera BRANCOS.
		cChavePesq += (cAlias)->RD_PD

		DbSelectArea( cNomSrdRhs )
		If ! DbSeek( cChavePesq )		// RHS_FILIAL+RHS_MAT+DTOS(RHS_DATA)+RHS_ORIGEM+RHS_CODIGO+RHS_PD+RHS_TPLAN+RHS_TPFORN+RHS_CODFOR+RHS_TPPLAN+RHS_PLANO

			(cNomSrdRhs)->( RecLock( cNomSrdRhs, .T. ) )	// Cria novo registro se nao existir
		Else
			(cNomSrdRhs)->( RecLock( cNomSrdRhs, .F. ) )	// Atualiza registro se existir
		EndIf
	
		(cNomSrdRhs)->RHS_FILIAL	:= (cAlias)->RD_FILIAL
		(cNomSrdRhs)->RHS_MAT		:= (cAlias)->RD_MAT
		(cNomSrdRhs)->RHS_DATA		:= dDtPagto
		(cNomSrdRhs)->RHS_ORIGEM	:= aDados[ nX, 5 ]			// 1 = Titular; 2 = Dependente; 3 = Agregado
		(cNomSrdRhs)->RHS_CODIGO	:= aDados[ nX, 3 ]
		(cNomSrdRhs)->RHS_TPLAN		:= cTipoAssis				// 1-Plano, 2-Co-Partic., 3-Reembolso
		(cNomSrdRhs)->RHS_TPFORN	:= cTipoForne	   			// 1-Assist. Medica, 2-Assist. Odontologica
		(cNomSrdRhs)->RHS_CODFORN	:= cFornec					// Codigo Fornecedor
		(cNomSrdRhs)->RHS_TPPLAN	:= cTPlano					// 1 - Salarial, 2 - Etaria
		(cNomSrdRhs)->RHS_PLANO		:= cPlano
		(cNomSrdRhs)->RHS_PD		:= (cAlias)->RD_PD
		(cNomSrdRhs)->RHS_VLRFUN	:= aDados[ nX, 4 ]
		(cNomSrdRhs)->RHS_VLREMP	:= 0.00
		(cNomSrdRhs)->RHS_COMPPG	:= (cAlias)->RD_DATARQ

		// Libera o registro gravado / alterado
		(cNomSrdRhs)->( MsUnLock() )

        cTextoLog := '  -> Registro gravado (Fil: ' + (cAlias)->RD_FILIAL + " Matr: " + (cAlias)->RD_MAT + " Verba: " + (cAlias)->RD_PD + ' Data Pagto: ' + DtoC( dDtPagto ) + " Valor: R$ " + Transform( aDados[ nX, 4 ], "@E 999,999.99" ) + ")"

		// Valida a Fase para Contador
		If nFaseProc == 0
			aAdd( aLog[2], cTextoLog )
			nContGrv0++
		Else
			aAdd( aLog[4], cTextoLog )
			nContGrv1++
		EndIf

	EndIf
Next

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � fValPlaRHS � Autor � TOTVS			   � Data � 27/01/2012	���
���������������������������������������������������������������������������͹��
���Descricao � Validacao do Plano de Saude.									���
���������������������������������������������������������������������������͹��
���Uso       � GRVAMORHS                                                    ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
User Function fValPlaRHS( cTpForn, cCodFor, cTpPlano, cCodPlano, lHelp )

Local cCodTab := "" 
Local lRet 	  := .T.
Local nColFor := 0
Local nPosTab

DEFAULT cTpForn		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'TPASSIST') ]
DEFAULT cCodFor		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'FORNEC'	) ]
DEFAULT cTpPlano	:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'TPLANO'	) ]
DEFAULT cCodPlano	:= &( ReadVar() )
DEFAULT lHelp		:= .T.

// TIPO DO FORNECEDOR conforme (cAliasMap)->TPASSIST
//		1=Medica	   ou 3=Co-Part. Med.	ou 5=Reemb. Med.   corresponde a 1 - Assist. Medica
//		2=Odontologica ou 4=Co-Part. Odont. ou 6=Reemb. Odont. corresponde a 2 - Assist. Odontologica 

If cTpForn $ "135"
	If cTpPlano == "1"
		cCodTab := "S008"
		nColFor := 13
	ElseIf cTpPlano == "2"
		cCodTab := "S009"
		nColFor := 13
	ElseIf cTpPlano == "3"
		cCodTab := "S028"
		nColFor := 12
	ElseIf cTpPlano == "4"
		cCodTab := "S029"
		nColFor := 15
	EndIf
ElseIf cTpForn $ "246"
	If cTpPlano == "1"
		nColFor := 13
		cCodTab := "S013"
	ElseIf cTpPlano == "2"
		cCodTab := "S014"
		nColFor := 13
	ElseIf cTpPlano == "3"
		cCodTab := "S030"
		nColFor := 12
	ElseIf cTpPlano == "4"
		cCodTab := "S031"
		nColFor := 15
	EndIf
EndIf

nPosTab := fPosTab( cCodTab, cCodFor, "=", nColFor, cCodPlano, "=", 4 )

If nPosTab <= 0 
	If lHelp
		Help( ,, 'HELP',, OemToAnsi( 'C�digo do Plano n�o encontrado!' + CRLF + 'Informe um plano v�lido na tabela ' + cCodTab ), 1, 0 )
	EndIf
	lRet := .F.
EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fValForRHS � Autor � TOTVS			 � Data � 27/01/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao de Fornecedores de Assist. Medica / Odontol.	  ���
�������������������������������������������������������������������������͹��
���Uso       � GRVAMORHS                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function fValForRHS( )

Local aArea		:= GetArea()
Local lRet		:= .F.
Local nPosIni	:= 1
Local nLenCod
Local nOrdem
Local nX		:= 1
Local cCodTab	:= ""
Local cConteudo	:= &( ReadVar() )
Local cFilOrigem:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'FILMAP'	) ]
Local cTpForn	:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'TPASSIST') ]
              
// TIPO DO FORNECEDOR conforme (cAliasMap)->TPASSIST
//		1=Medica	   ou 3=Co-Part. Med.	ou 5=Reemb. Med.   corresponde a 1 - Assist. Medica
//		2=Odontologica ou 4=Co-Part. Odont. ou 6=Reemb. Odont. corresponde a 2 - Assist. Odontologica 

If cTpForn $ "135"
	cCodTab := "S016"
ElseIf cTpForn $ "246"
	cCodTab := "S017"
EndIf	

RCB->( dbSetOrder( 3 ) )
RCB->( dbSeek( xFilial( "RCB" ) + "CODIGO    " + cCodTab ) )

nLenCod	:= RCB->RCB_TAMAN
nOrdem	:= Val( RCB->RCB_ORDEM )

RCB->( dbSetOrder( 1 ) )
RCB->( dbSeek( xFilial( "RCB" ) + cCodTab ) )

While nX < nOrdem .and. RCB->RCB_CODIGO == cCodTab

	If Val( RCB->RCB_ORDEM ) < nOrdem
		nPosIni += RCB->RCB_TAMAN
		nX ++
	EndIf
	RCB->( DbSkip() )
EndDo

RCC->( dbSetOrder( 1 ) )

If RCC->( dbSeek( xFilial( "RCC" ) + cCodTab ) )
	While RCC->RCC_CODIGO == cCodTab .and. ! lRet
		If cConteudo == SubStr( RCC->RCC_CONTEU, nPosIni, nLenCod ) .and. ( Empty( RCC->RCC_FIL ) .or. RCC->RCC_FIL == cFilOrigem )
			lRet := .T.
		EndIf
		RCC->( DbSkip() )
	EndDo
EndIf

RestARea( aArea )

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fConAssRHS� Autor � TOTVS				 � Data � 27/01/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para Consulta Padrao de Assistencia Medica e Odonto-���
���          � Logica especifica para rotina da Geracao de Historico.	  ���
�������������������������������������������������������������������������͹��
���Uso       � GRVAMORHS                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function fConAssRHS()
Local cVar			:= Upper( Alltrim( ReadVar() ) )
Local cCons			:= ""
Local cCpoRet		:= "CODIGO"
Local cConteud		:= ""
Local cTpPlano		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'TPLANO'	) ]
Local cTpForn		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'TPASSIST') ]
Local cCodFor		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'FORNEC'	) ]
Local cCodPlano		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'PLANO'	) ]
Local cFilter		:= ""
Local nCPn			:= 0 // variavel utilizada quando eh aberta mais de uma getdados ao mesmo tempo
Local xRet
Local bFilterRCC	:= { || .T. }
Local cTempVar		:= cVar

// TIPO DO FORNECEDOR conforme (cAliasMap)->TPASSIST
//		1=Medica	   ou 3=Co-Part. Med.	ou 5=Reemb. Med.   corresponde a 1 - Assist. Medica
//		2=Odontologica ou 4=Co-Part. Odont. ou 6=Reemb. Odont. corresponde a 2 - Assist. Odontologica 

If cVar == "M->FORNEC"
	If cTpForn $ "135"
		cCons := "S016"
	ElseIf cTpForn $ "246"
		cCons := "S017"
	EndIf
Else

	// Altera variavel para permitir o filtro na funcao Gp310SXB
	__ReadVar		:= "M->CODFOR"
	&(__ReadVar)	:= cCodFor

	If cTpForn $ "135"
		If cTpPlano == "1"
			cCons	:= "S008"
			cFilter := "{ || Substr(RCC->RCC_CONTEU,92,3) == '" + cCodFor + "' }"
		ElseIf cTpPlano == "2"
			cCons	:= "S009"
			cFilter := "{ || Substr(RCC->RCC_CONTEU,83,3) == '" + cCodFor + "' }"
		ElseIf cTpPlano == "3"
			cCons	:= "S028"
			cFilter := "{ || Substr(RCC->RCC_CONTEU,95,3) == '" + cCodFor + "' }"
		ElseIf cTpPlano == "4"
			cCons	:= "S029"
			cFilter := "{ || Substr(RCC->RCC_CONTEU,110,3) == '" + cCodFor + "' }"
		EndIf
	ElseIf cTpForn $ "246"
		If cTpPlano == "1"
			cCons	:= "S013"
			cFilter := "{ || Substr(RCC->RCC_CONTEU,92,3) == '" + cCodFor + "' }"
		ElseIf cTpPlano == "2"
			cCons	:= "S014"
			cFilter := "{ || Substr(RCC->RCC_CONTEU,83,3) == '" + cCodFor + "' }"
		ElseIf cTpPlano == "3"
			cCons	:= "S030"
			cFilter := "{ || Substr(RCC->RCC_CONTEU,95,3) == '" + cCodFor + "' }"
		ElseIf cTpPlano == "4"
			cCons	:= "S031"
			cFilter := "{ || Substr(RCC->RCC_CONTEU,110,3) == '" + cCodFor + "' }"
		EndIf
	EndIf

	// Monta Filtro de acordo com o fornecedor informado
	bFilterRCC	:= &cFilter

EndIf

// n - vari�vel de posicionamento do objeto GetDados
// o trecho abaixo controla para que nao haja conflito entre 2 GetDados, caso seja 
// disparada uma consulta F3 entre 2 tabelas. Ex.: S008 faz consulta em S016
If Type( 'n' ) == "N"
	nCpn := n
EndIf

xRet := Gp310SXB( cCons, cCpoRet, bFilterRCC )
                
// Retorna para variavel correta e continuar
If cVar <> "M->FORNEC"
	__ReadVar	:= cTempVar
EndIf

If ValType( xRet ) <> "L" .or. ( ValType( xRet ) == "L" .and. ! xRet )
	VAR_IXB := &__READVAR
Endif

If nCpn > 0
	n := nCpn
EndIf

If ValType( xRet ) <> "L"
	xRet := .F.
EndIf

Return xRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � CriaSXBRHS � Autor � TOTVS			   � Data � 27/01/2012	���
���������������������������������������������������������������������������͹��
���Descricao � Inclusao de consulta padrao especifica para gravar historico ���
���			 � de Assist. Medica / Odontologica.							���
���������������������������������������������������������������������������͹��
���Uso       � GRVAMORHS                                                    ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function AjustaSXB()

Local aArea		:= GetArea()
Local aCampos	:= {}	// Array para receber a Nova Estrutura da SXB
Local nX		:= 0	// Variavel auxiliar
Local lIncluiSXB:= .F.

// Monta nova estrutura
			// { "XB_ALIAS", XB_TIPO, XB_SEQ, XB_COLUNA	, XB_DESCRI"				, "XB_DESCSPA"			, "XB_DESCENG"			, "XB_CONTEM"		, "XB_WCONTEM"	}
aAdd( aCampos, { "AMORHS", "1"		, "01"	, "RE"		, "Assis. Medica e Odont."	, "Asist Med y Odont"	,"Dental and Med. Care"	, "RCC"				, ""			} )
aAdd( aCampos, { "AMORHS", "2"		, "01"	, "01"		, ""						, ""					,""						, "U_fConAssRHS()"	, ""			} )
aAdd( aCampos, { "AMORHS", "5"		, "01"	, ""		, ""						, ""					,""						, "VAR_IXB"			, ""			} )

SXB->( DbSetorder( 1 ) )
SXB->( dbSeek( "AMORHS" ) )

// Varre SXB para conferir qtde de registros
While SXB->( ! Eof() ) .and. SXB->XB_ALIAS	== "AMORHS"
	nX++
	SXB->( DbSkip() )
EndDo
nx := 1 // forca exclusao para testar
// Se existir e for diferente desta estrutura deleta todos para criar novamente
if nX > 0 .and. nX <> Len( aCampos )
	While SXB->( dbSeek( "AMORHS" ) )
		SXB->( Reclock("SXB", .F. ) )
		SXB->( DbDelete() )
		SXB->( MsUnlock() )
	EndDo
EndIf

// Posiciona novamente no registro para definir se eh Inclusao ou Alteracao
lIncluiSXB := ! SXB->( dbSeek( "AMORHS" ) )

For nX := 1 To Len( aCampos )

	SXB->( Reclock("SXB", lIncluiSXB ) )

		SXB->XB_ALIAS	:= aCampos[ nX, 1 ]
		SXB->XB_TIPO	:= aCampos[ nX, 2 ]
		SXB->XB_SEQ		:= aCampos[ nX, 3 ]
		SXB->XB_COLUNA	:= aCampos[ nX, 4 ]
		SXB->XB_DESCRI	:= aCampos[ nX, 5 ]
		SXB->XB_DESCSPA	:= aCampos[ nX, 6 ]
		SXB->XB_DESCENG	:= aCampos[ nX, 7 ]
		SXB->XB_CONTEM	:= aCampos[ nX, 8 ]
		SXB->XB_WCONTEM	:= aCampos[ nX, 9 ]

	SXB->( MsUnlock() )
	
	// Avanca registro se for Alteracao
	If ! lIncluiSXB
		SXB->( DbSkip() )
	EndIf
Next nX	

RestARea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MpAMOLinOk� Autor � TOTVS					� Data � 27/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao dos dados da linha digitada.					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GRVAMORHS                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
User Function MpAMOLinOk( )
Local lRet := .T.

Local cFilOrigem	:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'FILMAP'	) ]
Local cAnoMes		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'ANOMES'	) ]
Local cVerba  		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'VERBA'	) ]
Local cOrigem 		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'ORIGEM'	) ]
Local cTpForn 		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'TPASSIST') ]
Local cTpPlano 		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'TPLANO'	) ]
Local cCodFor  		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'FORNEC'	) ]
Local cCodPlano		:= oGetxA:aCols[ oGetxA:oBrowse:nAt, GdFieldPos( 'PLANO'	) ]

Local cTitFil		:= Alltrim( oGetxA:aHeader[ GdFieldPos( 'FILMAP'	) , 1 ] )
Local cTitAnoMes	:= Alltrim( oGetxA:aHeader[ GdFieldPos( 'ANOMES'	) , 1 ] )
Local cTitVerba		:= Alltrim( oGetxA:aHeader[ GdFieldPos( 'VERBA'		) , 1 ] )
Local cTitOrigem	:= Alltrim( oGetxA:aHeader[ GdFieldPos( 'ORIGEM'	) , 1 ] )
Local cTitTpForn	:= Alltrim( oGetxA:aHeader[ GdFieldPos( 'TPASSIST'	) , 1 ] )
Local cTitTpPlan	:= Alltrim( oGetxA:aHeader[ GdFieldPos( 'TPLANO'	) , 1 ] )
Local cTitCodFor	:= Alltrim( oGetxA:aHeader[ GdFieldPos( 'FORNEC'	) , 1 ] )
Local cTitCodPla	:= Alltrim( oGetxA:aHeader[ GdFieldPos( 'PLANO'		) , 1 ] )
                           
// Se a linha estiver deletada retorna Verdadeiro e nao precisa testar nenhum campo
If GdDeleted()
	Return( .T. )
EndIf

If lRet .and. Empty( cFilOrigem )
	Help( ,, 'HELP',, OemToAnsi( "Informe a " + cTitFil + " !!!" ), 1, 0 )
	lRet := .F.
EndIf

If lRet .and. Empty( cAnoMes )
	Help( ,, 'HELP',, OemToAnsi( "Informe o " + cTitAnoMes + " !!!" ), 1, 0 )
	lRet := .F.
EndIf

If lRet .and. Empty( cVerba )
	Help( ,, 'HELP',, OemToAnsi( "Informe a " + cTitVerba + " !!!" ), 1, 0 )
	lRet := .F.
EndIf

If lRet .and. Empty( cOrigem )
	Help( ,, 'HELP',, OemToAnsi( "Informe a " + cTitOrigem + " !!!" ), 1, 0 )
	lRet := .F.
EndIf

If lRet .and. Empty( cTpForn )
	Help( ,, 'HELP',, OemToAnsi( "Informe o " + cTitTpForn + " !!!" ), 1, 0 )
	lRet := .F.
EndIf

If lRet .and. Empty( cTpPlano )
	Help( ,, 'HELP',, OemToAnsi( "Informe o " + cTitTpPlan + " !!!" ), 1, 0 )
	lRet := .F.
EndIf

If lRet .and. Empty( cCodFor )
	Help( ,, 'HELP',, OemToAnsi( "Informe o " + cTitCodFor + " !!!" ), 1, 0 )
	lRet := .F.
EndIf

If lRet .and. Empty( cCodPlano )
	Help( ,, 'HELP',, OemToAnsi( "Informe o " + cTitCodPla + " !!!" ), 1, 0 )
	lRet := .F.
EndIf

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MpAMOTudOk� Autor � TOTVS					� Data � 27/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao dos dados da linha digitada.					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GRVAMORHS                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
User Function MpAMOTudOk()

Local lRet	:= .T.
Local nX	:= 0

for nX := 1 to len( aCols )

	oGetxA:oBrowse:nAt := nX

	lRet := U_MpAMOLinOk()

	If ! lRet
		Exit
	EndIf
Next

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �BuscaForn � Autor � TOTVS					� Data � 28/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca Fornecedores Plano 1.								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GRVAMORHS                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function BuscaForn( aPlanos  )
Local aArea		:= GetArea()
Local cTab		:= ""
Local cCodFor	:= ""
Local cCodPlan	:= ""
Local nI		:= 0
Local nPos1		:= 0
Local nPos2		:= 0

aPlanos := {}

// Posiciona na tabela RCC
dbSelectArea( "RCC" )
RCC->( dbSetOrder(1) )
RCC->( dbGoTop() )

// Carregar todos os codigos de Planos e Fornecedores //
For nI := 1 To 4
    If nI == 1
   		cTab 	:= "S008"
   		nPos1	:= 92
   		nPos2	:= 3
   	ElseIf nI == 2
   		cTab := "S009"
   		nPos1	:= 83
   		nPos2	:= 3
   	ElseIf nI == 3 
   		cTab := "S013"
   		nPos1	:= 92
		nPos2	:= 3
   	ElseIf nI == 4
   		cTab := "S014"
   		nPos1	:= 83
   		nPos2	:= 3
   	EndIF

	dbSelectArea( "RCC" )
	dbSetOrder( 1 )
	RCC->( dbSeek( xFilial("RCC") + cTab ) )
	While RCC->( ! Eof() ) .And. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+cTab
		cCodFor 	:= Substr(RCC->RCC_CONTEUDO,nPos1,nPos2)
		cCodPlan 	:= Substr(RCC->RCC_CONTEUDO,1,2)
		If aScan( aPlanos, { |x| x[1] == cTab .and. x[2] == cCodFor .and. x[3] == cCodPlan } ) == 0
			aAdd( aPlanos, { cTab, cCodFor, cCodPlan } )
		EndIf

		RCC->( dBSkip() )
	EndDo

Next nI

RestARea( aArea )

Return
