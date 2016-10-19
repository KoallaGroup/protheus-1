#include "rwmake.ch"        
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � Checkd1  � Autor �Ricardo E. Rodrigues   � Data � 15/07/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao + Rotina para calculo do Check Horizontal posicao 263 a 280 do++
++           + registro detalhe conforme manual unibanco pag 12 e Exemplo  ++
++           + na pagina 44                                                ++
�������������������������������������������������������������������������Ĵ��
���Uso       + Geracao de CNAB de pagamentos                              ���
��������������������������������������������������������������������������ٱ�
*/

User Function Checkd1 
*****************************************************************************
* Rotina de Calculo
********************
nd1		:= strzero(val(alltrim(strtran(str(SE2->E2_VRECEIT,13,2),".",""))),13)
nd2		:= strzero(val(alltrim(strtran(str(SE2->E2_PRECEIT,5,2),".",""))),5)
nd3		:= nd1+nd2 

if len(nd3) > 18
   nd3 := substr(nd3,2,19)	
else
   nd3 := nd3
endif

nd4 	:= strzero(val(alltrim(strtran(str(SE2->E2_SALDO,13,2),".",""))),13)
nd5		:= strzero((val(nd3) + val(nd4)) * 5,18)
creturn := nd5

return(creturn)