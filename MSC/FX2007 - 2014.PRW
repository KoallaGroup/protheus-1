#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function FX2007()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � GERFLUXO � Autor �Eduardo Carraro        � Data � 01/09/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Rotina para Geracao dos arquivos para o fluxo economico    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para EPC/TSA                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

@ 0,0 TO 180,450 DIALOG oDlg1 TITLE "Gerador do Fluxo Economico"

@ 04,05 TO 55,220
@ 10,10 SAY "Esta rotina tem o intuito de gerar o arquivo SZ0 (Fluxo Economico) para posterior"
@ 20,10 SAY "utilizacao no SigaEIS(Executive Information System). Esta Rotina podera demandar"
@ 30,10 SAY "alguns minutos e nao e' recomendavel interrompe-la. Clique em <OK> para confirmar"
@ 40,10 SAY "ou <Cancela> para Cancelar.Este programa trata apenas todas as filiais."
@ 65,150 BMPBUTTON TYPE 01 ACTION Confirma()// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> @ 65,150 BMPBUTTON TYPE 01 ACTION Execute(Confirma)
@ 65,178 BMPBUTTON TYPE 02 ACTION Cancela()// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> @ 65,178 BMPBUTTON TYPE 02 ACTION Execute(Cancela)

ACTIVATE DIALOG oDlg1 CENTER

Return

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Function Confirma
Static Function Confirma()
*****************************************************************************
* Botao de confirmacao                                                                                e
*
***
If cEmpAnt # '02' .and. cEmpAnt # '03'
	MsgBox("O Fluxo Gerencial so pode ser processado na Empresa 02 ou 03.")
Else
	If !File("CalcFluxo-"+cEmpAnt+".txt")              
	
		MsgBox("O Fluxo Gerencial 2014 vai ser processado  ...")

		//Cria o Arquivo com as informa��es de Quem esta Executando
		nFile:=FCreate("CalcFluxo-"+cEmpAnt+".txt")
		FWrite(nFile,"Usu�rio:"+cUserName+Chr(13)+Chr(10))
		FWrite(nFile,"Inicio do Calculo:"+Dtoc(Date())+" - "+Time()+Chr(13)+Chr(10))
		FClose(nFile)              
	    ExecBlock("GER2007",.F.,.F.) //Rotina de Geracao
        ExecBlock("GER102013",.F.,.F.) //Para gerar com novos grupos a partir de 01/10/2013 - Ricardo NM
		ExecBlock("IMPSC6",.F.,.F.) //Rotina de Geracao de Pedidos
		U_EXEQUERY('2007') //Query de atualiza�ao do dados
		U_EXEQUERY('2008') //Query de atualiza�ao do dados
        U_EXEQUERY('2009') //Query de atualiza�ao do dados 
        U_EXEQUERY('2010') //Query de atualiza�ao do dados
        U_EXEQUERY('2011') //Query de atualiza�ao do dados 
        U_EXEQUERY('2012') //Query de atualiza�ao do dados
        U_EXEQUERY('2013') //Query de atualiza�ao do dados
        U_EXEQUERY('2014') //Query de atualiza�ao do dados
 //       U_EXEQUERY('2015') //Query de atualiza�ao do dados
 		if ExistBlock("GerBcHora")
 			if MsgYesNo("Deseja calcular o banco de horas?")
				U_GerBcHora()
			endif
		endif
		Close(oDlg1)
		If File("Fluxo-"+cEmpAnt+".txt")'
	  		FErase("Fluxo-"+cEmpAnt+".txt")
		Endif
		FWrite(FCreate("Fluxo-"+cEmpAnt+".txt"),"Usu�rio: "+cUserName+Chr(13)+Chr(10)+" Data da Ultima gera��o do Fluxo:"+Dtoc(Date())+" - "+Time())
	  	FErase("CalcFluxo-"+cEmpAnt+".txt")
		MsgBox("O Fluxo Gerencial 2014 processado com sucesso.")
	Else
		MsgBox("O Fluxo Gerencial j� esta sendo processado por "+Chr(13)+Chr(10)+MemoRead("CalcFluxo"+cEmpAnt+".txt"))
	Endif	
EndIf

RETURN


// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> Function Cancela
Static Function Cancela()
*****************************************************************************
* Botao de cancelamento
*
***

Close(oDlg1)

Return