#INCLUDE "Rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AVALCOT   � Autor � Rodrigo Alves   � Data �  28/11/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Esse programa grava os dados do SIGAPCO da Cotacao para    ���
���          � o pedido de compra                                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
/*/
User Function AVALCOT()

Local nEvento := PARAMIXB[1]

Local aArea := GetArea()

If nEvento == 4
    dbSelectArea('SC7')
    RecLock('SC7',.F.)   
    Replace SC7->C7_XCO     With  SC8->C8_XCO
    Replace SC7->C7_XCLASSE With  SC8->C8_XCLASSE     
    Replace SC7->C7_XOPER   With  SC8->C8_XOPER
    REPLACE SC7->C7_XORCAME WITH  SC8->C8_XORCAME 
    REPLACE SC7->C7_XPCO    WITH  SC8->C8_XPCO 
    REPLACE SC7->C7_XPCO1   WITH  SC8->C8_XPCO1
    REPLACE SC7->C7_DATPRF   WITH  SC8->C8_DTNE 
     
     
           
    
    
    MsUnlock()

EndIf

RestArea(aArea)

Return 

