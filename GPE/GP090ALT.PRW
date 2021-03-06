#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"  
#include "Ap5mail.ch"  
                                                                          
/* 
 * @Descri��o
 *			   	Permite realizar o rateio das horas na tabela FIPEPC de acordo com as verbas cadastradas
 *			   	Depende da consulta SZ2_CO que retorna o n�mero do contrato formatado no formato 
 *			   	A0000-00-0000A       
 * @Alterado por: Leandro P J Monteiro 		leandro@cntecnologia.com.br		
 * @Altera��es	17/07/2013 Alterado o fonte para permitir a inser��o de novos registros no FIPEPC 
 * @Altera��es  31/07/2013 Alterado para considerar horas fracionadas
 * @Altera��es  25/10/2013 Alterado para chamar a Fun��o RATFIP01.prw, que � unica entre os lan�amentos
 * 				mensais (SRC) e lan�amentos de Rescis�o(SRR)
 * @Altera��es  03/11/2016 Remo��o de blocos n�o utilizados do PRW. ThiagoSantos
 ****************************************************************************************/
User Function GP090ALT
	
	// VERIFICA SE A MATRICULA EM EDI��O POSSUIR VERBAR PARA RATEIO 
	U_RatFip01("SRC") // SRC - LANCAMENTOS MENSAIS

Return
