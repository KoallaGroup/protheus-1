#INCLUDE "PONA200.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Pona200  � Autor � Aldo Marini Junior    � Data � 16.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao do Banco de Horas                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Marinaldo   �24/10/01�Melhor� Alteracao na Apresentacao da GetDados    ��� 
���Marinaldo   �03/06/02�Melhor�Dimensionamento Automatico do Dialogo    e���
���            �--------�------�da GetDados								  ���
���Marinaldo   �25/06/03�Melhor�Redefinicao das funcoes de Validacao    de���
���            �--------�------�Linhas Ok e Tudo Ok						  ���
���            �--------�------�Utilizacao de GdMontaCols() para carga das���
���            �--------�------�informacoes na GetDados					  ��� 
���MauricioMR  �25/08/03�------� Substituicao de Header por Protheus.ch   ��� 
��|Marinaldo   �21/04/04�Melhor�Tratamento nos Lock dos Registros e Delete|�� 
���Luiz Gustavo|29/11/06�------� Inclusao da funcao MenuDef() para        ���  
���      	   �--------�------� versao 9.12                              ��� 
���Rogerio R.  |26/01/07�------�	Alteracao da funcao Pn200Grava para   ���  
���			   |		�	   �melhorar a performance        			  ���  
���Pedro Eloy  |30/03/07�122063�Ajuste na GdMontaCols,p/ tratar bSeekWhile���  
���Allyson M.  |07/12/10�28122/�Ajuste na gravacao p/ so atualizar o flag ��� 
���            |        �  2010�para I na linha que foi alterada.         ��� 
���Glaucia C.  �06/06/11�12937 �Readequacao das telas para diversas       ��� 
���Messina     �        �2011  �resolucoes                                ��� 
���R.Berti     �29/08/11�TDMJNB�Inclusao P.E. PNA200GRV - apos atualiz.SPI��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

User Function Pona200

Local cFiltraSRA	:= ""	
Local aIndexSRA		:= {}
Local aArea			:= GetArea()
Local aAreaSPI		:= SPI->( GetArea() )

Private bFiltraBrw	:= {|| NIL}
Private cCadastro	:= OemToAnsi(STR0011 ) // "Manuten��o Banco de Horas"

/*
��������������������������������������������������������������Ŀ
� Define array contendo as Rotinas a executar do programa      �
� ----------- Elementos contidos por dimensao ------------     �
� 1. Nome a aparecer no cabecalho                              �
� 2. Nome da Rotina associada                                  �
� 3. Usado pela rotina                                         �
� 4. Tipo de Transa��o a ser efetuada                          �
�    1 - Pesquisa e Posiciona em um Banco de Dados             �
�    2 - Simplesmente Mostra os Campos                         �
�    3 - Inclui registros no Bancos de Dados                   �
�    4 - Altera o registro corrente                            �
�    5 - Remove o registro corrente do Banco de Dados          �
����������������������������������������������������������������*/
Private aRotina	:= MenuDef()
/*
������������������������������������������������������������������������Ŀ
�So executa se o Modo de Acesso do SPI e SRA foram iguais e se este  ulti�
�mo nao estiver vazio.                                                   �
��������������������������������������������������������������������������*/
IF ( ValidArqPon() .and. ChkVazio("SRA") )

	/*
	������������������������������������������������������������������������Ŀ
	� Inicializa o filtro utilizando a funcao FilBrowse                      �
	��������������������������������������������������������������������������*/
	cFiltraRh := CHKRH("PONA200","SRA","1")
	bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
	Eval(bFiltraBrw)
	
	/*
	��������������������������������������������������������������Ŀ
	� Endereca a funcao de BROWSE                                  �
	����������������������������������������������������������������*/
	dbSelectArea("SRA")
	mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

	/*
	������������������������������������������������������������������������Ŀ
	� Deleta o filtro utilizando a funcao FilBrowse                     	 �
	��������������������������������������������������������������������������*/
	EndFilBrw("SRA",aIndexSra)

EndIF

RestArea( aAreaSPI )
RestArea( aArea )

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pona200Atu �Autor � Aldo Marini Junior    � Data � 16.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de (Vis.,Inc.,Alt. e Del. de  dependentes         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � gp020Atu(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Pona200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function Pona200Atu(cAlias,nReg,nOpcx)

Local aArea			:= GetArea()
Local aAreaSRA		:= SRA->( GetArea() )
Local aAreaSPI		:= SPI->( GetArea() )
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGdNoFields	:= {"PI_FILIAL","PI_MAT"}
Local aGdNaoAltera	:= {"PI_FILIAL","PI_MAT"}
Local aGdAltera		:= {}
Local aQueryCond	:= {}
Local aVisual		:= {}
Local cFil			:= SRA->RA_FILIAL
Local cMat      	:= SRA->RA_MAT
Local cNome     	:= SRA->RA_NOME
Local nCnt			:= 0.00
Local nOpcA			:= 0.00
Local oDlg			:= NIL
Local oGet			:= NIL
Local oFont			:= NIL
Local oGroup		:= NIL
Local bSeekWhile	:= {|| SPI->PI_FILIAL + SPI->PI_MAT }
Local aButtons		:= {} //--Array usado no ponto de entrada PNA200BUT
Local bOk     		:= {|| nOpca:=If(nOpcx=5,2,1),If(oGet:TudoOk(),oDlg:End(),nOpca:=0)}
Local bCancel 		:= {|| oDlg:End()}

Private aColsRec	:= {}   //--Array que contem o Recno() dos registros da aCols
Private aColsAnt	:= {}
Private aColsLst	:= {}	
Private aVirtual	:= {}

cAlias := "SPI"

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

Begin Sequence
	
	/*
	��������������������������������������������������������������Ŀ
	� Monta a entrada de dados do arquivo                          �
	����������������������������������������������������������������*/
	Private aTela[0][0]
	Private aGets[0]
	Private aHeader[0]
	Private aCols[0]
	Private nUsado:=0
	
	/*
	��������������������������������������������������������������Ŀ
	� Seta a Ordem do SPI                                          �
	����������������������������������������������������������������*/
	dbSelectArea("SPI")
	SPI->( dbSetOrder(2) )
	
	/*
	��������������������������������������������������������������Ŀ
	� Monta o cabecalho e Detalhe                                  �
	����������������������������������������������������������������*/
	CursorWait()
	
	//"Carregando informa��es do Banco de Horas."###"Aguarde..."
	MsAguarde( { || aCols := GdMontaCols(@aHeader	,;	//01 -> Array com os Campos do Cabecalho da GetDados
										@nUsado		,;	//02 -> Numero de Campos em Uso
										@aVirtual	,;  //03 -> [@]Array com os Campos Virtuais
										@aVisual	,;	//04 -> [@]Array com os Campos Visuais
										"SPI"		,;  //05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
										aGdNoFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
										@aColsRec	,;  //07 -> [@]Array unidimensional contendo os Recnos
										"SPI"		,;  //08 -> Alias do Arquivo Pai
										(cFil+cMat) ,;  //09 -> Chave para o Posicionamento no Alias Filho
										bSeekWhile	,;	// NIL 10 -> Bloco para condicao de Loop While
										NIL			,;	//11 -> Bloco para Skip no Loop While
										NIL			,;	//12 -> Se Havera o Elemento de Delecao no aCols 
										NIL			,;  //13 -> Se cria variaveis Publicas
										NIL			,;  //14 -> Se Sera considerado o Inicializador Padrao
										NIL			,;  //15 -> Lado para o inicializador padrao
										NIL			,;	//16 -> Opcional, Carregar Todos os Campos
										NIL			,;  //17 -> Opcional, Nao Carregar os Campos Virtuais
										aQueryCond	,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
										.F.			,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
										.F.			,; 	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
										.T.		   ),; 	//21 -> Carregar Coluna Fantasma
				},; 
				OemToAnsi( STR0025 ) ,;
				OemToAnsi( STR0026 ) ,;
			 )

	CursorArrow()    
	
	/*
	��������������������������������������������������������������Ŀ
	� Na Inclusao Posiciona o SPI no Final de Arquivo              �
	����������������������������������������������������������������*/
	IF ( Inclui )
		PutFileInEof("SPI")
	EndIF

	/*
	��������������������������������������������������������������Ŀ
	� Verifica os Helps correspondentes                            �
	����������������������������������������������������������������*/
	nCnt	:= Len( aColsRec )
	IF ( ( nCnt > 0 ) .and. ( nOpcx = 3 ) )    	//--Quando Inclusao e existir Registro
		Help(" ",1,"a200CAPO")
		Break
    ElseIF ( ( nCnt = 0 ) .and. ( nOpcx # 3 ) )	//--Quando Nao for Inclusao e nao existir Registro
		Help(" ",1,"a200SAPO")
		Break
	EndIF

	/*
	��������������������������������������������������������������Ŀ
	� Carrega, apenas, os Campos Editaveis            			   �
	����������������������������������������������������������������*/
	CursorWait()
		For nCnt := 1 To nUsado
			IF (;
					( aScan( aVirtual 		, aHeader[ nCnt , 02 ] ) == 0.00 ) .and. ;
			   		( aScan( aVisual  		, aHeader[ nCnt , 02 ] ) == 0.00 ) .and. ;
			   		( aScan( aGdNaoAltera	, aHeader[ nCnt , 02 ] ) == 0.00 ) 	     ;
			  	)
				aAdd( aGdAltera , aHeader[ nCnt , 02 ] )
			EndIF			   
		Next nCnt
	CursorArrow()	

	/*
	��������������������������������������������������������������Ŀ
	� Calcula os Saldos do Banco de Horas	         			   �
	����������������������������������������������������������������*/
	CursorWait()
		//"Calculando o Saldo do Banco de Horas."###"Aguarde..."
		MsAguarde( { || Pona200BhSaldo( cFil , @aCols , aHeader ) } , OemToAnsi( STR0027 ) , OemToAnsi( STR0026 ) )
	CursorArrow()

	/*
	��������������������������������������������������������������Ŀ
	� Faz uma copia do aCols Inicial                  			   �
	����������������������������������������������������������������*/
	CursorWait()
		aColsAnt	:= aClone(aCols)
	CursorArrow()

	//��������������������������������������������������������������Ŀ
	//�P.E. para incluir botao  e alterar os valores dos saldos do BH�
	//����������������������������������������������������������������*/
	IF ExistBlock( "PNA200BUT" ) 
		aButtons := ExecBlock("PNA200BUT",.F.,.F.) 
		IF ValType( aButtons ) <> "A" .AND. Len( aButtons ) == 0
			aButtons := {}
		Endif 
	Endif 
	/*
	��������������������������������������������������������������Ŀ
	� Disponibiliza Dialogo                           			   �
	����������������������������������������������������������������*/
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0011) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL	// "Manuten��o Banco de Horas"
	
		@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup TO ( aObjSize[1,3] ),(( aObjSize[1,4])*0.18 )		LABEL OemToAnsi(STR0020) OF oDlg PIXEL		// "Matricula:"
		oGroup:oFont:= oFont
		@ aObjSize[1,1] , (( aObjSize[1,4])*0.185 ) GROUP oGroup TO aObjSize[1,3],((aObjSize[1,4])*0.87)	LABEL OemToAnsi(STR0013) OF oDlg PIXEL		// "Nome:"
		oGroup:oFont:= oFont
		@ aObjSize[1,1] , ((aObjSize[1,4])*0.875) GROUP oGroup TO  aObjSize[1,3] ,aObjSize[1,4]			LABEL OemToAnsi(STR0012) OF oDlg PIXEL		// "Admiss�o:"
		oGroup:oFont:= oFont

		@ ((aObjSize[1,1]) +10) , ((aObjSize[1,2]) * 2.5)		SAY StrZero(Val(SRA->RA_MAT),TamSx3("RA_MAT    ")[1])	SIZE 050,10 OF oDlg PIXEL FONT oFont
		@ ((aObjSize[1,1]) +10) , ((aObjSize[1,4]) * 0.2)		SAY OemToAnsi(SRA->RA_NOME) 							SIZE 146,10 OF oDlg PIXEL FONT oFont
		@ ((aObjSize[1,1]) +10) , ((aObjSize[1,4]) * 0.89)	SAY Dtoc(SRA->RA_ADMISSA)								SIZE 050,10 OF oDlg PIXEL FONT oFont

    	CursorWait()
    		oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,"U_Pona200LOk" ,"U_Pona200TOk" ,"",If(nOpcx==2.Or.nOpcx==5,Nil,.T.),aGdAltera,1,,9999)
		CursorArrow()
		
    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk , bCancel, , aButtons ) CENTERED

	/*
	��������������������������������������������������������������Ŀ
	� Se nao for Exclusao										   �
	����������������������������������������������������������������*/
	CursorWait()
		IF ( nOpcx # 5 )
			IF ( ( nOpcA == 1 ) .and. ( nOpcx # 2 ) )
				/*
				��������������������������������������������������������������Ŀ
				� Soh grava se Houver Alteracao no aCols. fCompArray()  retorna�
				� .T. se estiver tudo igual ou .F. se houve alteracoes		   �
				����������������������������������������������������������������*/
				IF !( fCompArray( aColsAnt , aCols ) )
					Begin Transaction
						//"Gravando informa��es no Banco de Horas."###"Aguarde..."
						MsAguarde( { || Pn200Grava(cAlias,nOpcx) } , OemToAnsi( STR0028 ) , OemToAnsi( STR0026 ) )
	            	    EvalTrigger()
					End Transaction
				EndIF	
			EndIF
		ElseIF ( ( nOpca = 2 ) .and. ( nOpcx = 5 ) )
			/*
			��������������������������������������������������������������Ŀ
			� Se for Exclusao    										   �
			����������������������������������������������������������������*/
			Begin Transaction
				//"Excluindo informa��es do Banco de Horas."###"Aguarde..."
				MsAguarde( { || Pona200Dele() } , OemToAnsi( STR0029 ) , OemToAnsi( STR0026 ) )
			End Transaction
		EndIF
	CursorArrow()
	
End Sequence

//��������������������������������������������������������������Ŀ
//� Restaura a integridade da janela                             �
//����������������������������������������������������������������
RestArea( aAreaSPI )
RestArea( aAreaSRA )
RestArea( aArea )

Return( MbrChgLoop( .F. ) )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pona200Dele�Autor �Equipe Advanced RH     � Data �25/06/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Deleta os Registro dos Apontamentos                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       �PONA200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Pona200Dele()

Begin Transaction
	SPI->( PonDelRecnos("SPI",aColsRec) )
End Transaction

//��������������������������������������������������������������Ŀ
//� P.E. apos atualizacao tab. SPI                               �
//����������������������������������������������������������������
If ExistBlock ("PNA200GRV")
	ExecBlock("PNA200GRV",.F.,.F.,{5,aHeader,aCols})
EndIf

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pona200BhSaldo�Autor�Marinaldo de Jesus   � Data �25/06/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula os Saldos do Banco de Horas                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       �PONA200													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Pona200BhSaldo( cFil , aCols , aHeader )

Local cPd			:= ""
Local cStatus		:= ""
Local nCols			:= 0.00
Local nHorasN		:= 0.00
Local nHorasV		:= 0.00
Local nSaldoN 		:= 0.00
Local nSaldoV		:= 0.00
Local nSaldoRet		:= 0.00
Local nLenCols		:= 0.00
Local nPosPd		:= GdFieldPos("PI_PD",aHeader)
Local nPosStatus	:= GdFieldPos("PI_STATUS",aHeader)
Local nPosHorasN	:= GdFieldPos("PI_QUANT",aHeader)
Local nPosHorasV	:= GdFieldPos("PI_QUANTV",aHeader)

DEFAULT aCols	:= {}
DEFAULT aHeader	:= {}
DEFAULT nUsado	:= 0.00

nLenCols := Len( aCols )
For nCols := 1 To nLenCols
	
	cPd			:= aCols[ nCols , nPosPd 		]
	cStatus		:= aCols[ nCols , nPosStatus	]
	nHorasN		:= aCols[ nCols , nPosHorasN	]
	nSaldoRet	:= fCalSaldo( cFil , cPd , "N" , cStatus , @nSaldoN , nHorasN )
	GdFieldPut( "PI_SALDO"	, nSaldoRet , nCols , aHeader , aCols )

	If nPosHorasV > 0
		nHorasV		:= aCols[ nCols , nPosHorasV ]
		nSaldoRet	:= fCalSaldo( cFil , cPd , "V" , cStatus , @nSaldoV , nHorasV )
		GdFieldPut( "PI_SALDOV"	, nSaldoRet , nCols , aHeader , aCols )
    Endif
Next nCols

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���                   ROTINAS DE CRITICA DE CAMPOS                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pn200Grava� Autor � Rogerio Ribeiro 		� Data � 26.01.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava no arquivo de Banco de Horas                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       �PONA200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Pn200Grava(cAlias, nOpcx)
	Local lReturn:= .F.
	Local bInsert:=	{|| ;
						FieldPut(FieldPos("PI_FILIAL"),	SRA->RA_FILIAL),;
						FieldPut(FieldPos("PI_MAT"),	SRA->RA_MAT),;
						FieldPut(FieldPos("PI_FLAG"), "I");
					}
					
	Local bUpdate:=	{|| ;
						FieldPut(FieldPos("PI_FLAG"), "I");
					}
	Local bGrava :=	{|lReturn| ;
						GDSaveRecords("SPI", aHeader, {aCols[nCont]}, bInsert, 	bUpdate);
					}
	Local lTudoIgual:= .F.
	Local nCont	   	:= 0
	Local nLenRegs 	:= Len( aColsAnt )
	Local nLenCols 	:= Len( aCols )

	If (nOpcx == 2 .Or. nOpcx == 5)
		Return .T.
	EndIf	
	
	For nCont := 1 To nLenRegs
		//-- Somente compara os campos que podem ser editados.
		lTudoIgual := 	aCols[nCont, 01] == aColsAnt[nCont, 01] .And. ;//Data
						aCols[nCont, 02] == aColsAnt[nCont, 02] .And. ;//Evento      
						aCols[nCont, 04] == aColsAnt[nCont, 04] .And. ;//Centro custo
						aCols[nCont, 05] == aColsAnt[nCont, 05] .And. ;//Horas
						aCols[nCont, 06] == aColsAnt[nCont, 06] .And. ;//Horas valorizadas
						aCols[nCont, 09] == aColsAnt[nCont, 09] .And. ;//Status
						aCols[nCont, 10] == aColsAnt[nCont, 10] .And. ;//Data da baixa
						aCols[nCont, 14] == aColsAnt[nCont, 14]        //Deletada?
        If lTudoIgual
           	Loop
        EndIf
		Eval(bGrava)
	Next nCont

	If ( nCont := nLenRegs ) < nLenCols
		While nCont < nLenCols
			nCont++
			Eval(bGrava)
		End While
	EndIf

	//��������������������������������������������������������������Ŀ
	//� P.E. apos atualizacao tab. SPI                               �
	//����������������������������������������������������������������
	If ExistBlock ("PNA200GRV")
		ExecBlock("PNA200GRV",.F.,.F.,{nOpcx,aHeader,aCols})
	EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pona200LOk� Autor � Marinaldo de Jesus    � Data �25/06/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Linha Ok da GetDados										  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �PONA200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
User Function Pona200LOk( oBrowse , lTudoOk )
         
Local aCposKey	:= {}
Local cStatus	:= ""
Local cMsg		:= ""
Local lLinOk	:= .T.
Local nQuant	:= 0.00

DEFAULT lTudoOk	:= .F.

IF !( ValType( lTudoOk ) == "L" )
	lTudoOk := .F.	
EndIF

CursorWait()
Begin Sequence

	/*
	��������������������������������������������������������������Ŀ
	� Se a Linha da GetDados Nao Estiver Deletada				   �
	����������������������������������������������������������������*/
	IF !( GdDeleted() )

		/*
		��������������������������������������������������������������Ŀ
		� Verifica Itens Duplicados na GetDados						   �
		����������������������������������������������������������������*/
/*		aCposKey := { "PI_DATA" , "PI_PD" , "PI_STATUS" , "PI_CC", "PI_DTBAIX" }
		IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
			Break
		EndIF*/

		/*
		��������������������������������������������������������������Ŀ
		� Obtem o Status do Lancamento                      		   �
		����������������������������������������������������������������*/
		cStatus := GdFieldGet("PI_STATUS")

		/*
		��������������������������������������������������������������Ŀ
		� Verifica Se o Campos Estao Devidamente Preenchidos		   �
		����������������������������������������������������������������*/
		IF ( cStatus == "B" )
			aCposKey := { "PI_DATA" , "PI_PD" , "PI_CC" , "PI_QUANT" , "PI_DTBAIX" }
		Else
			/*
			��������������������������������������������������������������Ŀ
			� Se o Status nao for "B"aixado o Campo PI_DTBAIX devera  estar�
			� em Branco													   �
			����������������������������������������������������������������*/
			IF !( lLinOk := Empty( GdFieldGet( "PI_DTBAIX" ) ) )
				cMsg := STR0023	//"Para Lancamentos sem Baixa o campo: "
				cMsg += aHeader[ GdFieldPos("PI_DTBAIX") , 01 ]
				cMsg += STR0024	//" n�o poder� estar preenchido"
				MsgInfo( OemToAnsi( cMsg ) )
				Break
			EndIF
			aCposKey := { "PI_DATA" , "PI_PD" , "PI_CC" , "PI_QUANT" }
		EndIF	
		IF !( lLinOk := GdNoEmpty( aCposKey ) )
	    	Break
		EndIF

		/*
		��������������������������������������������������������������Ŀ
		� Impede a digita��o de Minutos Inv�lidos					   �
		����������������������������������������������������������������*/
		nQuant := GdFieldGet( "PI_QUANT" )
		IF !( lLinOk	:= ( ( ( nQuant - Int( nQuant ) ) * 100 ) < 60 ) )
			Help(' ', 1, 'THORMAIO59')
			Break
		EndIF

	EndIF
		
End Sequence

CursorArrow()

Return( lLinOk )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pona200TOk� Autor � Marinaldo de Jesus    � Data �25/06/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tudo Ok da GetDados                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Pona200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
User Function Pona200TOk( oBrowse )

Local lTudoOk	:= .T.

Return( lTudoOk )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pn200Valid� Autor � Aldo Marini Junior    � Data � 16.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Critica a data da linha digitada                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
/*User Function Pn200ValDt()

Local lRet	:= .T.
Local nPos1	:= 0

nPos1 := GdFieldPos( "PI_DATA" )

IF n <= Len(aColsAnt)
	IF aCols[n,nPos1] # M->PI_DATA .And. !Empty(aCols[n,nPos1])
	   lRet := .F.
	EndIF
EndIF

Return( lRet )*/

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pn200ValPd� Autor � Aldo Marini Junior    � Data � 16.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Critica o Codigo da linha digitada                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
/*User Function Pn200ValPd()

Local lRet := .T.
Local nPos1 := 0
Local nPos2 := 0

nPos1 := GdFieldPos( "PI_PD" )
nPos2 := GdFieldPos( "PI_DESC" )

IF n <= Len(aColsAnt)
	IF aCols[n,nPos1] # M->PI_PD .And. !Empty(aCols[n,nPos1])
	   lRet := .F.
	EndIF
EndIF

//-- Inclus�o da Descri��o
IF lRet
	aCols[n,nPos2] := PosSP9( M->PI_PD , xFilial("SPI") , "P9_DESC" , 1 , .F. )
EndIF

Return( lRet )*/

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pn200Saldo� Autor � Aldo Marini Junior    � Data � 16.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Totaliza os Saldos dos Eventos	                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
/*User Function Pn200Saldo(nOpc)

Local lRet := .T.
Local nPos0 := 0
Local nPos1 := 0
Local nPos2 := 0
Local nPos3 := 0
Local nPos4 := 0
Local nT    := 0
Local cVar  := &(ReadVar())
Local cTipo	:= ""
Local nVarVal := 0

nPos0 := GdFieldPos("PI_PD")
nPos1 := GdFieldPos("PI_QUANT")
nPos2 := GdFieldPos("PI_SALDO")
nPos3 := GdFieldPos("PI_QUANTV")
nPos4 := GdFieldPos("PI_SALDOV")
nPos5 := GdFieldPos("PI_STATUS")

For nT:=1 to Len(aCols)

	If aCols[n,nUsado+1] <> .F. 
		Loop
	Endif

	nPerc	:= PosSP9( aCols[nT,nPos0] , xFilial("SPI") , "P9_BHPERC"	, 1 , .F. )
	cTipo	:= PosSP9( aCols[nT,nPos0] , xFilial("SPI") , "P9_TIPOCOD"	, 1 , .F. )

	If nOpc == 1 // Atualizacao para Saldos Normais
		If n == nT .And. cVar <> NIL
			aCols[nT,nPos1] := cVar

			nVarVal := fConvHr(Round(fConvHr(cVar,"D")*(nPerc/100),2),"H")
			
			// Atualiza o Percentual de Valorizacao do Evento  
			If nPos3 > 0
				aCols[n,nPos3] := nVarVal
			Endif	

		Endif
	Endif
	
	IF ( cTipo $ "1*3" )
		If nT == 1
			If nOpc == 1 // Atualizacao para Saldos Normais
				aCols[1,nPos2] := IF(aCols[1,nPos5] == "B",0,aCols[1,nPos1])
			Endif  
			If nPos4 > 0 .AND. nPos5 > 0 .AND. nPos3 > 0 
				aCols[1,nPos4] := IF(aCols[1,nPos5] == "B",0,aCols[1,nPos3])
			Endif	
		Else
			If nOpc == 1 // Atualizacao para Saldos Normais
				aCols[nT][nPos2] := __TimeSum(aCols[nT-1][nPos2],IF(aCols[nT,nPos5] == "B",0,aCols[nT][nPos1]))
			Endif
			If nPos4 > 0 .AND. nPos5 > 0 .AND. nPos3 > 0 
				aCols[nT][nPos4] := __TimeSum(aCols[nT-1][nPos4],IF(aCols[nT,nPos5] == "B",0,aCols[nT][nPos3]))
			Endif
		Endif	
	Else
		If nT == 1
			If nOpc == 1 // Atualizacao para Saldos Normais
				aCols[1,nPos2] := IF(aCols[1,nPos5] == "B",0,aCols[1,nPos1]) * (-1)
			Endif 
			If nPos4 > 0 .AND. nPos5 > 0 .AND. nPos3 > 0 
				aCols[1,nPos4] := IF(aCols[1,nPos5] == "B",0,aCols[1,nPos3]) * (-1)
			Endif	
		Else	
			If nOpc == 1 // Atualizacao para Saldos Normais
				aCols[nT][nPos2] := __TimeSub(aCols[nT-1][nPos2],IF(aCols[nT,nPos5] == "B",0,aCols[nT][nPos1]))
			Endif
			If nPos4 > 0 .AND. nPos5 > 0 .AND. nPos3 > 0 
				aCols[nT][nPos4] := __TimeSub(aCols[nT-1][nPos4],IF(aCols[nT,nPos5] == "B",0,aCols[nT][nPos3]))
			Endif
		Endif	
	Endif	
Next nT

Return( .T. ) */

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fCalSaldo � Autor � Marinaldo de Jesus    � Data �25/06/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula os Saldos dos Lanctos do Banco de Horas             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �<Vide Parametros Formais>  		                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�<Vide Parametros Formais>  		                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Pona200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fCalSaldo( cFil , cPd , cTipo , cStatus , nValor , nQuantHr )

Local lTipo1e3 := ( PosSP9( cPd , cFil , "P9_TIPOCOD" , 1 , .F. ) $ "1*3" )

IF ( cStatus <> "B" )
	IF ( lTipo1e3 )
		IF ( cTipo == "N" )	// Horas Normais
			nValor	:=__TimeSum( nValor , nQuantHr )
		Else
			nValor	:=__TimeSum( nValor , nQuantHr )
		EndIF
	Else
		IF ( cTipo == "N" )	// Horas Normais
			nValor	:=__TimeSub( nValor , nQuantHr )
		Else
			nValor	:=__TimeSub( nValor , nQuantHr )
		EndIF
	EndIF
EndIF

Return( nValor )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Almeida     � Data �29/11/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �PONA200                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/

Static Function MenuDef()

Local aRotina		:= {	{ STR0004 , "PesqBrw"	 , 0 , 1, ,.F.},; 	// "Pesquisar"
		 		            { STR0005 , "U_Pona200Atu" , 0 , 2},; 		// "Visualizar"
                     		{ STR0007 , "U_Pona200Atu" , 0 , 3,,,.T.},; 	// "Incluir"
                     		{ STR0009 , "U_Pona200Atu" , 0 , 4},; 		// "Alterar"
                     		{ STR0010 , "U_Pona200Atu" , 0 , 5},; 		// "Excluir"
                     		{ STR0022 , "gpLegend"	 , 0 , 6, ,.F.}} 	// 'Legenda'
                     		
Return aRotina

User Function Pn200CalMp()

	dbSelectArea("SPI")
	SPI->(DbSetOrder(1))
	SPI->(DbGoTop())
	
	While !(SPI->(eof()))
	
		RecLock('SPI',.F.)//Banco de Horas                
			Replace SPI->PI_QUANTMP with fValor(SPI->PI_QUANTV)
		MsUnLock('SPI')		
	
		SPI->(dbSkip())
		
	EndDo  
                     		
Return

Static Function fValor(xValor)

	Local nInteiro := INT(xValor)

	if (xValor-nInteiro) != 0
		xValor := nInteiro+0.5
	endif

/*	xValor := Transform(xValor,"@E 99999999.9")
	xValor := strtokarr(xValor,",")
	
	if len(xValor) == 2

		xValor[1] := Val(xValor[1])	
		xValor[2] := Val(xValor[2])
		if xValor[2] == 3
			xValor[2] := 5
		endif
		
		if xValor[2] != 5
			if xValor[2] > 5
				xValor[2] := 0
				xValor[1] += 1
			else
				xValor[2] := 0
			endif
		endif
		
	elseif len(xValor) == 1
	
		xValor := {Val(xValor[1]),0}
	
	endif
	
	xValor := Val(cValToChar(xValor[1])+"."+cValToChar(xValor[2]))*/
	
Return(xValor)