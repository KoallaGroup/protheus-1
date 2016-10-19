#Include "Rwmake.ch"

/*
+-----------------------------------------------------------------------------+
| Programa  | MT120LOK | Desenvolvedor | Gilson Lucas Jr  | Data | 24/09/2004 |
|-----------------------------------------------------------------------------|
| Descricao | Ponto de entrada validar se o contrato � ou nao um contrato do  |
|-----------------------------------------------------------------------------|
|tipo pontual                                								  |
|-----------------------------------------------------------------------------|
| Uso       | Especifico EPC Engenharia                                       |
|-----------------------------------------------------------------------------|
|                  Modificacoes desde a construcao inicial                    |
|-----------------------------------------------------------------------------|
| Responsavel  | Data      | Motivo                                           |
|-----------------------------------------------------------------------------|
|              |           |                                                  | 
+--------------+-----------+--------------------------------------------------+
*/

User Function MT120LOK 
/*********************************
*
*
*******************************************************************************/

Local lRet := .T.  

If FunName() <> "MATA122"
   Return(.T.)
EndIf

SZO->(dbSetOrder(1))
SZO->(dbSeek(xFilial("SZO")+GDFieldGet("C7_NUMSC")+GDFieldGet("C7_ITEMSC")+"P"))
    If !SZO->(EOF())
        MsgBox(OemToAnsi("O Contrato selecionado � do tipo PONTUAL. N�o"+ chr(13) +"� permitido fazer AE para este tipo de contrato."),OemToAnsi("Aten��o"),"INFO")
	    lRet := .F.
    EndIf 
Return(lRet)