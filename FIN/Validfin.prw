#include "rwmake.ch"        
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � Validfin � Autor �Ricardo E. Rodrigues   � Data � 15/07/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao + Rotina para avisar ao usuario sobre a soma do Vr principal  ++
++           + +multa+juros em pagto DARF  onde existe um teste para compa-++
++           + rar soma com o Vr. do titulo                                ++
�������������������������������������������������������������������������Ĵ��
���Uso       + Geracao de CNAB de pagamentos                              ���
��������������������������������������������������������������������������ٱ�
*/

User Function Validfin 
*****************************************************************************
* Rotina de Calculo
********************

ntot 	:= M->E2_VPRINCI + M->E2_MULDARF + M->E2_JURDARF

If ntot <> M->E2_VALOR
   Msgstop ("Vr Principal+Multa e Juros diferem Vr Total, Titulo n�o ser� Pago")
Else   
   creturn := .T.
endif

return()