#INCLUDE "Rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT100GE2  � Autor � Leonardo Moreira   � Data �  17/12/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Esse programa grava os dados do SIGAPCO da NF Entrada para ���
���          � o Contas a Pagar                                           ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
/*/
User Function MT100GE2 ()

Local aArea := GetArea()           


dbSelectArea('SE2')
RecLock('SE2',.F.)   
Replace SE2->E2_XCO     With  SD1->D1_XCO
Replace SE2->E2_XCLASSE With  SD1->D1_XCLASSE     
Replace SE2->E2_XOPER   With  SD1->D1_XOPER
Replace SE2->E2_XPCO    With  SD1->D1_XPCO                   
Replace SE2->E2_CC      With  SD1->D1_CC
Replace SE2->E2_XPCO1    With  SD1->D1_XPCO1 

//If SD1->D1_FIN<>" " 
//Replace SE2->E2_TIPO   With  SD1->D1_FIN 
 
//endif

MsUnlock()

RestArea(aArea)

Return 

