#Include "Rwmake.ch"
#Include "TopConn.ch"
/*
+-----------------------------------------------------------------------------+
| Programa  |IniPadSFC | Desenvolvedor |                     | Data |         |
|-----------------------------------------------------------------------------|
| Descricao |  Valida a Exclus�o de uma Tarefa                                |
|-----------------------------------------------------------------------------|
| Uso       | Especifico EPC                                                  |
|-----------------------------------------------------------------------------|
|                  Modificacoes desde a construcao inicial                    |
|-----------------------------------------------------------------------------|
| Responsavel  | Data      | Motivo                                           |
|-----------------------------------------------------------------------------|
|              |           |                                                  | 
+--------------+-----------+--------------------------------------------------+
*/

User Function VldTarefa(cProj,cTarefa)
****************************************************************************************************************
* Verifica quantos documentos est�o amarrados a esta tabela para permitir a exclus�o
*
*******
Local lRet   := .T.
Local cQuery := ""

cQuery := " SELECT COUNT(*) NDOCS FROM GEDPMS "
cQuery += " WHERE GED_PROJET='"+cProj+"' AND GED_TAREFA='"+cTarefa+"'"

TcQuery cQuery Alias QVLD New

dbSelectArea("QVLD")
If (QVLD->NDOCS > 0)
	Alert("	Aten��o ! "+Chr(13)+"	Existem documentos vinculados a este projeto/Tarefa no sistema "+Chr(13)+;
    		" Meridian que Impede a Exclus�o desta Tarefa, � necess�rio que este vinculo "+Chr(13)+;
			" seja desfeito atrav�s do sistema Meridian para possibilitar a Exclus�o.")
		 lRet:=.f.
Endif

dbSelectArea("QVLD")
dbCloseArea()

Return(lRet)