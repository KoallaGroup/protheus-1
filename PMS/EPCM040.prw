/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EPCM040   �Autor  �ARNALDO PETRAZZINI  � Data �  17/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � IMPORTACAO DE CONFIRMACOES                                 ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO EPC                                             ���
�������������������������������������������������������������������������ͼ��
���          ALTERACOES REALIZADAS DESDE A CRIACAO                        ���
�������������������������������������������������������������������������͹��
���Data      � Programador  � Descricao das Alteracoes                    ���
�������������������������������������������������������������������������͹��
���24/10/06  � Crislei      � Busca o projeto atraves do codigo do Contra-���
���          �              � to do Controle de Documentos para concatenar���
���          �              � to do Controle de Documentos para concatenar���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

#INCLUDE "AP5MAIL.CH"
#Include "Protheus.ch"

User Function EPCM040()
	Local cDoc 	   := ""
	Local aSay	   := {}
	Local aButton  := {}
	Local aPerg    := {}
	Local cTitulo  := 'Gera��o de Confirma��o e Apontamento Fisico'
	Local cDesc1   := 'Esta Rotina busca as informa��es do sistema de Controle de Documentos Tecnicos.'
	Local cDesc2   := 'buscando o percentual de realiza��o de cada tarefa.'
	Local cPerg	   := 'EPCCON'
	Local cDir	   := GetMv("EX_DIRLOG")	
	Local cDirForm := GetMv("EX_DIRFORM")	
	Local aAreaFF  := AFF->(GetArea())
	Local i
	//Variaveis que recebem os dados dos bdf's
	Local cFormula := ""                                     
	Local dOpera 	:= ""  
	Local nMltA1	:= 0
	Local cContr 	:= SPACE(05)
	Local cNumOs 	:= SPACE(02)
	Local cNumProj  := SPACE(10)
	Local cForm  	:= ""  
	Local nFl   	:= 0
	Local nAVCLI 	:= 0  
	Local cHoraI	:= Time()
	Local cHoraF	:= ""
	Local nSoma		:= 0
	Local nDiv		:= 0
	Local cContrRev  := "" 
	Local cTarefa	:= ""
	Local cTarDOC	:= Space(21)
	//Envio do e-mail
	Local cFile		:= ""
	Local lOk
	Local cErro
	Local cServer	:= GetMv("MV_RELSERV")
	Local cUser		:= GetMv("MV_RELACNT") 
	Local cPasswd	:= GetMv("MV_RELAPSW")
	Local cFrom		:= GetMv("MV_RELFROM")
	Local cTo		:= GetMv("MV_ADMEMAI")
	Local lAuth		:= GetMv("MV_RELAUTH")
	Local cErrF		:= "" // erro no formato
	Local cErrT		:= "" // erro na tarefa
	Local cErrP     := "" // erro no projeto
    Local lCanc		:= .F.
	Local lErroEPC	:= .F.
	
CHKFILE("AFF") 

//�������������������������������������������������������������Ŀ
//� Variaveis utilizadas para par�metros                        �
//� mv_par01               Projeto de:                          �
//� mv_par02               Projeteo Ate:                        �
//� mv_par03               Tarefa de:                           �
//� mv_par04               Tarefa Ate:                          �
//� mv_par05               Recurso de:                          �
//� mv_par06               Recurso Ate:                         �
//� mv_par07               Data de:                             �
//� mv_par08               Data Ate:                            �
//���������������������������������������������������������������

AADD(aPerg,{cPerg,"Contrato de:       ?","C",12,0,"G","","AF8CON","","","","",""})
AADD(aPerg,{cPerg,"Contrato Ate:      ?","C",12,0,"G","","AF8CON","","","","",""})
AADD(aPerg,{cPerg,"Tarefa de:         ?","C",12,0,"G","","AF9EPC","","","","",""})
AADD(aPerg,{cPerg,"Tarefa Ate:        ?","C",12,0,"G","","AF9EPC","","","","",""})
AADD(aPerg,{cPerg,"Recurso de:        ?","C",06,0,"G","","AE8","","","","",""})
AADD(aPerg,{cPerg,"Recurso Ate:       ?","C",06,0,"G","","AE8","","","","",""})
AADD(aPerg,{cPerg,"Data de:           ?","D",08,0,"G","","","","","","",""})
AADD(aPerg,{cPerg,"Data Ate:          ?","D",08,0,"G","","","","","","",""})



Pergunte( cPerg, .F.)

//������������������������������������������
//�Criacao janela do Pergunte , FormBatch()�
//������������������������������������������
aAdd( aSay, cDesc1 ) // Texto explicativo na janela FormBatch.
aAdd( aSay, cDesc2 ) // Texto explicativo na janela FormBatch.
aAdd( aButton, {  5, .T., {|| Pergunte( cPerg, .T.)   }} )// Executa o pergunte
aAdd( aButton, {  1, .T., {|| nOpc := 1, FechaBatch() }} ) // Botao 0k
aAdd( aButton, {  2, .T., {|| FechaBatch(), lCanc := .T. }} )// Botao fecha

FormBatch( cTitulo, aSay, aButton )
// Parametros
//�������������������������������������������������������������Ŀ
//�MV_PAR01 = Parametro que define o projeto inicial da selecao �
//�MV_PAR02 = Parametro que define o projeto final da selecao   �
//�MV_PAR03 = Parametro que define a tarefa inicial da selecao  �
//�MV_PAR04 = Parametro que define a tarefa final da selecao    �
//�MV_PAR05 = Parametro que define o recurso inicial da selecao �
//�MV_PAR06 = Parametro que define o recurso final da selecao   �
//�MV_PAR07 = Parametro que define a data inicial da selecao    �
//�MV_PAR08 = Parametro que define a data final da selecao      �
//���������������������������������������������������������������		
// FORCA A CONVERCAO DE LETRAS MINUSCULAS 
// PARA MAIUSCULAS DOS PARAMETROS.
MV_PAR01 := Upper(MV_PAR01)
MV_PAR02 := Upper(MV_PAR02)
MV_PAR03 := Upper(MV_PAR03)
MV_PAR04 := Upper(MV_PAR04)
MV_PAR05 := Upper(MV_PAR05)
MV_PAR06 := Upper(MV_PAR06)


Do 	Case
	Case Empty(MV_PAR02)  	
		MsgAlert("Parametro : Projeto At� - N�o informado!!","ATEN��O")
		Return(.F.)
	Case Empty(MV_PAR04)  	
		MsgAlert("Parametro : Tarefa Final - N�o informado!!","ATEN��O")
		Return(.F.)
	Case Empty(MV_PAR06)  	
		MsgAlert("Parametro : Recurso Ate - N�o informado!!","ATEN��O")
		Return(.F.)
	Case Empty(MV_PAR07)  	
		MsgAlert("Parametro : Data De - N�o informado!!","ATEN��O")
		Return(.F.)
	Case Empty(MV_PAR08)  	
		MsgAlert("Parametro : Data Ate - N�o informado!!","ATEN��O")
		Return(.F.)
EndCase			

If lCanc
	Return(.F.)
EndIf
	                                                                             
//������������������������������������������������������
//�Abre os arquivos .dbf e cria os indices temporarios.�
//������������������������������������������������������
// Abre o arquivo DOC.dbf
dbUseArea(.T.,"DBFCDX" ,cDir+"\doc.dbf","DOC" , .T., .F.)
   	cArquivo := CriaTrab("DOC",.F.)
	IndRegua( "DOC",cArquivo,"D_COD_CTO",,,OemToAnsi("Criando indices..."))   
// Abre o arquivo REV.dbf
dbUseArea(.T.,"DBFCDX" ,cDir+"\rev.dbf","REV" , .T., .F.)     
	cArquivo :=  CriaTrab("REV",.F.)
	IndRegua( "REV",cArquivo,"D_COD_CTO",,,OemToAnsi("Criando indices.."))     
// Abre o arquivo FORMATO.dbf
dbUseArea(.T.,"DBFCDX" ,cDirForm+"\formato.dbf","FORM" , .T., .F.)
 	cArquivo :=  CriaTrab("FORM",.F.)
	IndRegua( "FORM",cArquivo,"T_COD_FORM",,,OemToAnsi("Criando indices.."))   
//�����������������������������������������Ŀ
//�Chama a funcao de Integracao apontamento �
//�de mao de obra                           �
//	U_EPCRecu() -- CRISLEI - NAO HA NECESSIDADE DE CONSULTAR A FIP PARA ESTA INTEGRACAO
//�������������������������������������������		                                   

//�������������������������������������������������������Ŀ
//� Faz a pesquisa com base nos parametros dentro dos .dbf�
//� Busca o projeto dentro do arquivo dbf				  �	
//���������������������������������������������������������
DBSelectArea("DOC")

If Alltrim(mv_par01) == ""
	DOC->( dbGoTop() )
Else
	DOC->( dbSeek(alltrim(MV_PAR01) ) )
EndIf

/*BEGINDOC
//�����������������������������������������������������������������������Ŀ
//�Posiciona na tabela de PROJETOS atraves do PARAMETRO informado para    �
//�buscar o codigo do Projeto para localizar a tarefa                     �
//� CRISLEI - 25/10/06                                                    �
//�������������������������������������������������������������������������
ENDDOC*/

dbSelectArea("AF8")
dbSetOrder(8) //FILIAL+COD. CONTRATO+OS  
If dbSeek(xFilial("AF8")+AllTrim(MV_PAR01))
   cNumProj := AF8->AF8_PROJET
//   cTarDoc  := AllTrim(cNumProj) + cTarDoc
EndIf	

If !DOC->( Eof() )	
	DBSelectArea("AF9") 
	AF9->( DBSetOrder(1) ) 
	If  AF9->( dbSeek(xFilial("AF9") + alltrim(cNumProj)))//primeiro registro da filial
			While DOC->( !EOF() )                              .AND. ;
			      Alltrim(DOC->D_COD_CTO) >= Alltrim(MV_PAR01) .AND. ;
                  Alltrim(DOC->D_COD_CTO) <= Alltrim(MV_PAR02) 
		 							                		 							 
				// salva os valores dos campos nas variaveis
				cContr	:= DOC->D_COD_CTO // numero do contrato corrente  --- SO O NUMERO DO CONTRATO D_PROJETO = NUMERO DA OS - D_CON_PRO = CONTRATO+OS
				cNumOs  := DOC->D_PROJETO // Numero da OS (Crislei 24/10/06)
				cTarDOC	:= DOC->D_CR_ITEM // tarefa compativel
				cForm	:= DOC->D_COD_FORM // formato corrente       
				nFl		:= DOC->D_NO_FL 
//				nAVCLI	:= DOC->D_AV_CLI  - ESTE CAMPO � DIGITADO PELO USUARIO - NAO CONFIAVEL (CRISLEI)
				nAVCLI	:= DOC->D_AV_EPC 
				
			
				/*BEGINDOC
				//�����������������������������������������������������������������������Ŀ
				//�Posiciona na tabela de PROJETOS atraves do campo Numero do Contrato    �
				//�e concatena o numero do projeto ao codigo da tarefa, a fim de localizar�
				//�a tarefa referente ao Documento atraves do campo AF9_TARCLI            �
				//� CRISLEI - 24/10/06                                                    �
				//�������������������������������������������������������������������������
				ENDDOC*/
			    dbSelectArea("AF8")
 				dbSetOrder(8) //FILIAL+COD. CONTRATO+OS  
				If dbSeek(xFilial("AF8")+cContr+cNumOs)
				   cNumProj := AF8->AF8_PROJET
				   cTarDoc  := AllTrim(cNumProj) + cTarDoc
				EndIf			
				
			//�������������������������������������������������������������������������
			//�Adiciona espaco em branco p/ compatibilizar com o campo DOC->D_COD_CTO �
			//�que possui tamanho de 9 caracteres                                     �
			//	cContr 	+= Space(Len(AF9->AF9_PROJET)-Len(DOC->D_COD_CTO))                                                    
			//�������������������������������������������������������������������������	      			                                            
			
			//	busca a tarefa com base no projeto do arq. dbf				 			 							        
	   			DBSelectArea("AF9")
 				AF9->( DBSetOrder(6) ) //FILIAL+PROJET+TARCLI
				If	AF9->(dbSeek(xFilial("AF9")+ cTarDOC))// tarefa do cliente
			
					While AF9->(!EOF()) .and.	AF9->AF9_TAREFA >= alltrim(MV_PAR03) .AND.;
												AF9->AF9_TAREFA <= alltrim(MV_PAR04)  .AND.;
												AllTrim(AF9->AF9_PROJET) == AllTrim(cNumProj)
//												AllTrim(AF9->AF9_PROJET) == AllTrim(cContr)

						cTarefa := AF9->AF9_TAREFA // recebe tarefa corrente
						
						DBSelectArea("FORM")
						If FORM->(dbSeek(cForm)) // procura o formato da DOC dentro da Formato 
		            		   nMltA1 := FORM->T_MULT_A1 // salva na variavel
						Else
							lErroEpc := .T. // Indica erro ocorrido na importa��o
						    U_DbFecha() // SE NAO ENCONTRAR FORMATO RETORNA E FECHA OS ARQUIVOS DBF
					    	cErrF += "O formato "+cForm+" n�o foi encontrado "+ CRLF
						EndIf
						// Monta a formula
						nSoma += ((nFl*nMltA1)*(nAVCLI/100))
						nDiv  +=  nFl
						
		                // Busca a data da ultima revisao para o projeto
						DBSelectArea("REV") 
						If REV->( dbSeek( cContr) )  	   // procura dentro do REV.dbf 
							dOpera := REV->DTOPERAC   	   // pega a primeira data desse projeto
			 			EndIf 
						//���������������������������������������������������������������������������Ŀ
						//�EXECUTA A GRAVACAO -> SE DADOS JA EXISTEM NA TABELA -> ATUALIZA            �
						//�                      SE DADOS NAO EXISTEM -> INCLUI						  �
						//�����������������������������������������������������������������������������
//						cContrRev:= PmsAF8VER(cContr) // ultima revisao do projeto
						cContrRev:= PmsAF8VER(cNumProj) // ultima revisao do projeto
					
						nFORM	:= (nSoma/nDiv)
						
						/* ::::::::::::::::::::::::::::::::::::::::::
						Codigo original
						DBSelectArea("AFF")
						AFF->( DBSetOrder(1)) // AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA+DTOS(AFF_DATA)
						dbSeek(xFilial("AFF")+ cContr+ cContrRev + cTarefa) //SE ENCONTRAR REGISTRO
						:::::::::::::::::::::::::::::::*/
												
						DBSelectArea("AFF")
						AFF->( DBSetOrder(1)) // AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA+DTOS(AFF_DATA)
						dbSeek(xFilial("AFF")+ cNumProj+ cContrRev + cTarefa + dtos(dOpera)) //SE ENCONTRAR REGISTRO

						RecLock("AFF", Eof() )// GRAVA 	
							AFF_FILIAL	:= xFilial("AFF")
							AFF_PROJET	:= cNumProj //cContr
							AFF_REVISA	:= PmsAF8VER(cNumProj) //PmsAF8VER(cContr)
							AFF_DATA	:= dOpera 
							AFF_TAREFA	:= cTarefa
							AFF_USER	:= "000000"
							AFF_CONFIRM	:= "2"
							AFF_PERC	:= 	nFORM
							AFF_QUANT   := 	nFORM/100
							AFF_FLGDOC	:= .T.
						AFF->( msUnLock() )                
						AF9->(DbSkiP())
					EndDo 
				Else
					lErroEpc := .T. // Indica erro ocorrido na importa��o
					AF9->( DBSetOrder(5) ) //AF9_FILIAL+AF9_PROJET+AF9_TAREFA
					
					If	AF9->(!dbSeek(xFilial("AF9")+ cNumProj))// tarefa do cliente 												
							
							cErrP += Iif(!Alltrim(cNumProj) $ cErrP,"Projeto <b>"+Alltrim(cNumProj)+"</b> n�o foi encontrado. " + CRLF,"")				   
					
					ElseIf !(Alltrim(cTarefa)+" do projeto <b>"+alltrim(cNumProj) $ cErrT)
							
							cErrT += "Tarefa  "+Alltrim(cTarefa)+"</b> do projeto <b>"+alltrim(cNumProj)+"</b> n�o foi encontrada. " + CRLF						
					EndIf						
				EndIf
		DOC->(DbSkip())
		EndDo
	EndIf // If de AF9
	
Else // if de DOC
	lErroEpc := .T. // Indica erro ocorrido na importa��o
	cErrP += "Projeto <b>"+alltrim(cNumProj)+"</b> n�o foi encontrado. " + CRLF		
EndIf// if de DOC 
U_DbFecha() // Fecha os dbf's
RestArea(aAreaFF) 

		//�����������������������������������������Ŀ
		//�Montagem do E-mail para o Administrador. �
		//�������������������������������������������
		cHoraF := Time()  
		cFile  := "Log de Importa��o de Confirma��es / Apontamento" + CRLF + CRLF
  		cFile  += "<html><head></head><body>"
		cFile  += "<font size=1 face=verdana>" 
		cFile  += Replicate("*",55) + CRLF
	   	cFile  += "* EPC - ROTINA DE IMPORTA��O DE CONFIRMA��ES/APONTAMENTO" + CRLF
		cFile  += "* DATA DE PROCESSAMENTO: " + DtoC(dDataBase) + CRLF
		cFile  += "* PARAMETROS DEFINIDOS PELO USUARIO" + CRLF
		cFile  += Replicate("*",55) + CRLF
		cFile  += "* PROJETO DE/ATE: "+" " +alltrim(mv_par01)+ " / " +alltrim(mv_par02) +CRLF
		cFile  += "* TAREFA DE/ATE:	"+" " +alltrim(mv_par03)+ " / " +alltrim(mv_par04) +CRLF
		cFile  += "* RECURSO DE/ATE: "+" " +alltrim(mv_par05)+ " / " +alltrim(mv_par06) +CRLF
		cFile  += "* DATA DE/ATE: "+ DtoC(mv_par07) + " / " +DtoC(mv_par08) +CRLF
		cFile  += Replicate("*",55) + CRLF
		cFile  += "* INICIO DO PROCESSAMENTO: " + cHoraI + CRLF
		cFile  += "* FIM DO PROCESSAMENTO: " + cHoraF + CRLF
		cFile  += "* TEMPO DECORRIDO: " + ElapTime(cHoraI, cHoraF) + CRLF
		cFile  += Replicate("*",55) + CRLF
        If lErroEPC
			cFile  += "<b> ERROS OCORRIDOS NO PROCESSAMENTO: </b>" + CRLF
		Else 
			cFile  += "<b> PROCESSAMENTO FINALIZADO </b> "+ CRLF 
		EndIf	

		If Len(cErrP) > 0
			cFile  += Replicate("-",77) + CRLF
			cFile  += cErrP + CRLF
		EndIf
		
		If Len(cErrT) > 0         
			cFile  += Replicate("-",77) + CRLF
			cFile  += cErrT + CRLF
		EndIf
			
		If Len(cErrF) > 0                        
			cFile  += Replicate("-",77) + CRLF
			cFile  += cErrF + CRLF
		EndIf
		cFile  += Replicate("*",55) + CRLF 
		cFile  += "</body></html>"
		//���������������������������������������������������������
		//�Efetua a conexao ao servidor de envio de e-mail (SMTP) �
		//���������������������������������������������������������
		//Verifica se existe necessidade de autentica��o
		If lAuth
			CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPasswd RESULT lOK
		Else
			CONNECT SMTP SERVER cServer ACCOUNT '' PASSWORD '' RESULT lOK
		EndIf
	
		//Se conexao estabelecida com o servidor
		If lOk	
			cBody := cFile // corpo do email
			//��������������Ŀ
			//�Envia mensagem�
			//����������������  
			cSbjct := "LOG DE IMPORTA��O DE CONFIRMA��ES"
		
			SEND MAIL FROM cFrom TO cTo SUBJECT cSbjct BODY cBody ATTACHMENT cFile

			If !lOk
				GET MAIL ERROR cErro
				MsgAlert("Ocorreu o seguinte erro ao tentar enviar um e-mail ao Adminstrador:"+ CRLF + cErro)
			EndIf
			DISCONNECT SMTP SERVER RESULT lOK
			If !lOk
				GET MAIL ERROR cErro
				MsgAlert("Ocorreu o seguinte erro ao tentar desconectar o Servidor de  e-mails:"+ CRLF + cErro)
			EndIf		
		Else
			//Se n�o foi poss�vel conectar-se ao servidor, obtem o tipo do erro 
			//e mostra uma mensagem de alerta.	 
			GET MAIL ERROR cErro
			MsgAlert("Ocorreu o seguinte erro ao tentar conectar  o  Servidor  de  e-mails:"+ CRLF + cErro)
		EndIf

Return ()	   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DbFecha   �Autor  �ARNALDO PETRAZZINI  � Data �  22/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fecha as areas dos dbfs                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function DbFecha()
	DOC->(DbCloseArea())
	REV->(DbCloseArea())
	FORM->(DbCloseArea()) 
Return()    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � E010RECU �Autor  �Vanessa Ferraz      � Data �  20/10/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Integra a tabela de recursos do Projeto - AE8 - com o     ���
���          �  sistema legado                                            ���
�������������������������������������������������������������������������͹��
���Uso       � EPC                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/    
User Function EPCRecu()
    Local cQuery 	:= ""
    Local lInclui 	:= .F.
    Local cChapa    := ""
    Local aAreaAE8 	:= AE8->( GetArea() )
  	Local nCount	:= 0
	Local cCrono	:= ""
	Local nCusto	:= 0
		
	//����������������������������������������������������������������Ŀ
	//�Seleciona os recursos que fazem parte dos projetos presentes nos�
	//�parametros selecionados.                                        �
	//������������������������������������������������������������������
	cCrono := u_EPCrono()

/*	
	cQuery  :=  "SELECT DISTINCT "
	cQuery 	+=	"A.CHAPA, "
	cQuery 	+=	"B.NOME, B.FUNCAO "
	cQuery 	+=	"FROM FIPEPC A "
	cQuery 	+=	" INNER JOIN PESSOAL B ON "
	cQuery 	+=	"A.CHAPA = B.CHAPA "
	cQuery	+=	"WHERE "
	cQuery	+=	"A.FIPCRONOGRAMA IN (" + cCrono + ") AND "	
	cQuery  +=  "A.CHAPA BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
	cQuery  +=  "A.FIPDATA BETWEEN '" + dtos(mv_par07) + "' AND '" + dtos(mv_par08) + "' "
	cQuery  +=  "ORDER BY "  
	cQuery  +=  "A.CHAPA "
*/

	cQuery  :=  "SELECT DISTINCT "
	cQuery 	+=	"A.CHAPA, "
	cQuery 	+=	"B.RA_NOME, B.RA_CODFUNC "
	cQuery 	+=	"FROM FIPEPC A "
	cQuery 	+=	" INNER JOIN " + RetSqlName("SRA") + " B ON "
	cQuery 	+=	"A.CHAPA = B.RA_MAT "
	cQuery	+=	"WHERE "
	cQuery	+=	"A.FIPCRONOGRAMA IN (" + cCrono + ") AND "	
	cQuery  +=  "A.CHAPA BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
	cQuery  +=  "A.FIPDATA BETWEEN '" + dtos(mv_par07) + "' AND '" + dtos(mv_par08) + "' "
	cQuery  +=  "ORDER BY "  
	cQuery  +=  "A.CHAPA "
	cQuery  +=  "A.FIPEMPRESA = '"+SM0->M0_CODIGO+"' AND "
   	cQuery  := ChangeQuery(cQuery)
   	
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBEXT", .F., .T.)  
 
	TRBEXT->( DbEval( {|| nCount++ } ) ) 	//conta os registros TRBEXT
	ProcRegua(nCount)
    TRBEXT->( DbGotop () )
	AE8-> ( dbSetOrder(1) )				//AE8->AE8_FILIAL + AE8->AE8_RECURS 
	CursorWait()
	
/*	If TRBEXT->( Eof() )
		cMsgEr := "* " + Time() + " - NAO FORAM ENCONTRADOS RECURSOS PARA OS PARAMETROS DEFINIDOS " + CRLF
	EndIf*/
	While !TRBEXT->( Eof() )  

		IncProc(TRBEXT->NOME)
		cChapa := Alltrim(TRBEXT->CHAPA)
			   
		lInclui := ! ( AE8->( dbSeek(xFilial("AE8") + cChapa ) ) )
		
		RecLock("AE8", lInclui)                                     	
		AE8->AE8_FILIAL		:= xFilial("AE8")
		AE8->AE8_RECURS		:= cChapa 						//Fipepc->ID
		AE8->AE8_DESCRI 	:= TRBEXT->RA_NOME          	//Pessoal->NOME
		AE8->AE8_TIPO 		:= "2" 
		AE8->AE8_ACUMUL 	:= "4" 
		AE8->AE8_UMAX 		:= 100.00
		AE8->AE8_SUPALO 	:= "2"
		AE8->AE8_PRODUT 	:= TRBEXT->RA_CODFUNC		  	//Pessoal->FUNCAO
		AE8->AE8_CALEND 	:= "001"		
		AE8->AE8_TPREAL 	:= "2"
		AE8->AE8_VALOR 		:= 0.00			
		AE8->AE8_CODFUN 	:= cChapa 						//Fipepc->ID
		AE8->AE8_ATIVO 		:= "1"
    	AE8->( msUnLock() )
	       
	   	TRBEXT->( dbSkip() )	    	   
	EndDo   
    
    TRBEXT->( dbCloseArea() )
    dbSelectArea("AE8")
    RestArea(aAreaAE8)
    CursorArrow()
Return 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EPCSRANG  �Autor  � Vanessa Iatski     � Data �  17/11/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Seleciona o Range de Cronogramas que farao parte do IN     ���
���          � nos select da tabela FIPEPC                                ���
�������������������������������������������������������������������������͹��
���Uso       � Precisa ter carregado o PERGUNTE antes                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function EPCrono()
	Local cQuery := ""
	Local cCrono := ""
	Local cContr	 := ""
   
  	//Selecionar os projetos que farao parte do select
  	cQuery	:= 	"Select distinct "
	cQuery 	+=	"AF9.AF9_TARCLI, "
	cQuery 	+=	"AF9.AF9_PROJET, "
	cQuery 	+=	"AF9.AF9_REVISA, "
	cQuery 	+=	"AF9.AF9_TAREFA "
	cQuery 	+=	"FROM "
	cQuery 	+=	RetSQLName("AF9") + " AF9 "
	cQuery 	+=	"Where "
	cQuery 	+=	"AF9.AF9_FILIAL = '" + xFilial("AF9") + "' AND "
	cQuery 	+=	"AF9.AF9_PROJET BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' AND "
	cQuery 	+=	"AF9.AF9_TAREFA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND "
	cQuery 	+=	"AF9.D_E_L_E_T_ <> '*' "
	cQuery 	+=	"ORDER BY "
	cQuery 	+=	"AF9.AF9_PROJET, "
	cQuery 	+=	"AF9.AF9_REVISA DESC, "
	cQuery 	+=	"AF9.AF9_TAREFA "
 	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"CRONO", .F., .T.)  
 	cCrono := ""
 	If !CRONO->( Eof() )
		//�����������������������������������������������������������������Ŀ
		//�Monta o parametro com os projetos que serao pesquisados em FIPEPC�
		//�������������������������������������������������������������������
	 	cContr  := ""
	 	While !CRONO->( Eof() )
	 		If cContr != CRONO->AF9_PROJET .And. Alltrim(CRONO->AF9_TARCLI) != ""
	 			cCrono += "'" + Alltrim( CRONO->AF9_TARCLI ) + "',"
	 			cContr := CRONO->AF9_PROJET
	 		EndIf
	 		CRONO->( dbSkip() )
	 	EndDo
		cCrono := SubStr(cCrono, 1, Len(cCrono)-1 )
	EndIf
	CRONO->( dbCloseArea() )
	dbSelectArea("AF9")
Return(cCrono)                    